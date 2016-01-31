# Screen #4, game
#
# TODO:
# - zpropagovat obtiznost do query na server

App.module "Game", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    TIMER_DELAY  = 100
    PENALTY_TIME = undefined
    local_channel = undefined
    _options = undefined
    info = undefined
    progress = undefined
    questions = undefined
    q_layout = undefined

    # --- models & collections

    Progress = Backbone.Model.extend
        defaults:
            total: 0
            current: 0
        initialize: () ->
            that = @
            # progress penalty due to passing wrong tunnel
            local_channel.on 'penalty', (count) ->
                current = that.get('current')
                total = that.get('total')
                current += count
                if current > total
                    current = total
                that.set('current', current)

    Info = Backbone.Model.extend
        defaults:
            question: 1
            total_questions: null
            category: null
            time: 0
        initialize: () ->
            that = @
            # time penalty due to passing wrong tunnel
            local_channel.on 'penalty', (count) ->
                time = that.get('time')
                that.set('time', time + count * 10) # time is stored seconds * 10, so count must be multiplied by same value

    Question = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: null
            question: null
            image: null
            country: null
            category: null
            answer: null

    Questions = Backbone.Collection.extend
        model: Question
        parse: (response, options) ->
            response.results
        initialize: (models, options) ->
            @url = "/api/questions/#{ options.difficulty }-#{ options.category }"

    # --- views

    InfoItemView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <div class="col-md-4 text-left">
                    <p>Otázka č.<%= question %>/<%= total_questions %></p>
                </div>
                <div class="col-md-4 text-center">
                    <p><%= category %></p>
                </div>
                <div class="col-md-4 text-right">
                    <p><%= show_time() %></p>
                </div>
            """)(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)
        initialize: (options) ->
            @model.on 'change', () =>
                @render()
        onDestroy: () ->
            @model.off('change')

    ProgressItemView = Marionette.ItemView.extend
        className: 'progress'
        template: (serialized_model) ->
            _.template("""
                <div class="progress-bar"
                     role="progressbar"
                     aria-valuenow="<%= get_percent() %>"
                     aria-valuemin="0"
                     aria-valuemax="100"
                     style="width: <%= get_percent() %>%;"></div>
            """)(serialized_model)
        templateHelpers: ->
            get_percent: ->
                if @current <= @total
                    (@current / @total) * 100
                else
                    100
        initialize: (options) ->
            @model.on 'change', () =>
                @render()
        onDestroy: () ->
            @model.off('change')

    QuestionItemView = Marionette.ItemView.extend
        tagName: 'div'
        template: (serialized_model) ->
            _.template("<% if (image) {%><img height=\"150\" src=\"<%= image %>\" /><% } %><h1><%= question %></h1>")(serialized_model)
        initialize: (options) ->
            @model.on 'change', () =>
                @render()

            that = @
            # event about tunnel crossing
            window.channel.on 'tunnel', (number) ->
                country = that.model.get('country')
                if "#{number}" == "#{country.sensor}"
                    local_channel.trigger('next', true)
                else
                    local_channel.trigger('penalty', PENALTY_TIME)

            window.channel.on 'debug:good', () ->
                local_channel.trigger('next', true)

            window.channel.on 'debug:bad', () ->
                local_channel.trigger('penalty', PENALTY_TIME)

        onDestroy: () ->
            window.channel.off('debug:bad')
            window.channel.off('debug:good')
            window.channel.off('tunnel')
            @model.off('change')

    QuestionLayout = Marionette.LayoutView.extend
        template: _.template """
            <div class="row">
                <div class="col-md-12" id="info"></div>
            </div>
            <div class="row" style="height:200px">
                <div class="col-md-12 text-center" id="question"></div>
            </div>
            <br/>
            <div class="row">
                <div class="col-md-12" id="progress"></div>
            </div>
        """

        regions:
            info: '#info'
            question: '#question'
            progress: '#progress'

    # --- timer handler

    handler = () ->
        time = info.get('time') + 1
        info.set('time', time)

        current = progress.get('current')
        total = progress.get('total')
        if current >= total
            local_channel.trigger('next', false)
        else
            progress.set('current', current + .1)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Game module'
        console.log options
        _options = options                  # store options (selected gamemode inside)
        PENALTY_TIME = options.gamemode.penalty
        local_channel = Backbone.Radio.channel('game')

        # data for top/bottom of the screen
        info = new Info
            total_questions: options.total_questions
            category: options.gamemode.title

        progress = new Progress
            total: options.gamemode.time
            current: 0

        # data for questions
        questions = new Questions null, 
            difficulty: options.gamemode.difficulty
            category: options.gamemode.category

        questions.on 'sync', () ->
            # layout
            q_layout = new QuestionLayout({el: make_content_wrapper()})
            q_layout.render()

            # info radek nahore
            q_layout.getRegion('info').show(new InfoItemView({model: info}))

            # otazka
            question_view = new QuestionItemView
                model: questions.at(info.get('question') - 1)
            q_layout.getRegion('question').show(question_view)

            # progress bar
            q_layout.getRegion('progress').show(new ProgressItemView({model: progress}))

            local_channel.on 'next', (user_answer) ->
                if user_answer
                    window.sfx.yes.play()
                else
                    window.sfx.no.play()
                question = info.get('question')

                # record user answer
                old_q = questions.at(question - 1)
                old_q.set('answer', user_answer)

                # move to the next question
                question += 1

                if question > options.total_questions
                    # end of the game is near...
                    clear_timer()
                    output = _.extend _options,
                        questions: questions.toJSON()
                        answers: questions.map (i) ->
                            id: i.get('id')
                            answer: i.get('answer')
                        time: info.get('time')
                    window.channel.command('game:close', output)
                else
                    info.set('question', question)
                    progress.set('current', 0)
                    question_view.destroy()

                    # set new question
                    question_view = new QuestionItemView
                        model: questions.at(question - 1)
                    q_layout.getRegion('question').show(question_view)

            # start this screen
            set_timer(handler, TIMER_DELAY)

        questions.fetch()

    Mod.onStop = (options) ->
        clear_timer()
        info = undefined
        progress = undefined
        questions = undefined
        q_layout.destroy()
        local_channel.reset()

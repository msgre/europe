# Screen #6, Game / Hra
#

App.module "Game", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    TIMER_DELAY  = 100
    PENALTY_TIME = undefined
    local_channel = undefined
    _options = undefined
    info = undefined
    questions = undefined
    layout = undefined
    gate_passing_time = undefined

    # --- models & collections

    Info = Backbone.Model.extend
        defaults:
            question: 1
            total_questions: null
            category: null
            time: 0
            total: 0
            current: 0
        initialize: () ->
            that = @
            local_channel.on 'penalty', (count) ->
                window.sfx.gate.play()
                # time penalty due to passing wrong tunnel
                time = that.get('time')

                # progress penalty due to passing wrong tunnel
                current = that.get('current')
                total = that.get('total')
                current += count
                if current > total
                    current = total
                that.set
                    time: time + count * 10 # time is stored seconds * 10, so count must be multiplied by same value
                    current: current

    Question = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: null
            question: null
            image: null
            country: null
            category: null
            answer: null
            image_css_game: null

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
                <h1><img style='-webkit-filter: invert(100%) opacity(70%)' src='<%= icon %>'/><%= category %></h1>
                <div class="bar" style="background-position:<%= (current/total)*1100 %>px 0px">
                    <p><%= question %>/<%= total_questions %></p>
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

    QuestionItemView = Marionette.ItemView.extend
        tagName: 'tr'
        attributes: () ->
            styles = 
            {style: if styles then styles else ''}
        template: (serialized_model) ->
            if serialized_model.image and serialized_model.question
                tmpl = """
                    <td><img style="<%= image_css_game %>" src="<%= image %>" height="781px" /></td>
                    <td class="text"><%= question %></td>
                """
            else if serialized_model.image
                tmpl = """
                    <td><img style="<%= image_css_game %>" src="<%= image %>" /></td>
                """
            else
                tmpl = """
                    <td class='text-only'><%= question %></td>
                """
            _.template(tmpl)(serialized_model)
        initialize: (options) ->
            @model.on 'change', () =>
                @render()

            that = @
            # event about tunnel crossing
            window.channel.on 'tunnel', (event) ->
                now = Date.now()
                country = that.model.get('country')
                if "#{country.board}" of event and event["#{country.board}"] & country.gate
                    local_channel.trigger('next', true)
                    gate_passing_time = now
                else
                    if not gate_passing_time
                        gate_passing_time = now
                    delta = now - gate_passing_time
                    if delta <= _options.options.DUMBNESS_TIME
                        # ignore event (we dont care about gates for while)
                        ''
                    else
                        # timeout
                        local_channel.trigger('penalty', PENALTY_TIME)
                        gate_passing_time = now


            window.channel.on 'debug:good', () ->
                local_channel.trigger('next', true)

            window.channel.on 'debug:bad', () ->
                local_channel.trigger('penalty', PENALTY_TIME)

        onDestroy: () ->
            window.channel.off('debug:bad')
            window.channel.off('debug:good')
            window.channel.off('tunnel')
            @model.off('change')

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header">
                <h1></h1>
                <div class="bar"></div>
            </div>
            <div id="body">
                <table class="game"></table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-b')

        regions:
            info: '#header'
            question: '#body .game'

    # --- timer handler

    handler = () ->
        time = info.get('time') + 1
        info.set('time', time)

        current = info.get('current')
        total = info.get('total')
        if current >= total
            local_channel.trigger('next', false)
        else
            info.set('current', current + .1)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Game module'
        console.log options
        _options = options                  # store options (selected gamemode inside)
        PENALTY_TIME = options.gamemode.penalty
        local_channel = Backbone.Radio.channel('game')

        # data for top/bottom of the screen
        info = new Info
            total_questions: _options.options.QUESTION_COUNT
            category: _options.gamemode.title
            total: _options.gamemode.time
            icon: _options.gamemode.category_icon
            current: 0

        # data for questions
        questions = new Questions null, 
            difficulty: _options.gamemode.difficulty
            category: _options.gamemode.category

        questions.on 'sync', () ->
            # layout
            layout = new ScreenLayout({el: make_content_wrapper()})
            layout.render()

            # info radek nahore
            layout.getRegion('info').show(new InfoItemView({model: info}))

            # otazka
            question_view = new QuestionItemView
                model: questions.at(info.get('question') - 1)
            layout.getRegion('question').show(question_view)

            local_channel.on 'next', (user_answer) ->
                question = info.get('question')

                # record user answer
                old_q = questions.at(question - 1)
                old_q.set('answer', user_answer)

                # move to the next question
                question += 1
                correct_answers = questions.filter (i) ->
                    i.get('answer') == true

                if question > options.options.QUESTION_COUNT
                    # blink LED
                    bad_answers = questions.filter (i) ->
                        i.get('answer') == false
                    good_leds = _.map(correct_answers, (i) -> i.get('country').led)
                    bad_leds = _.map(bad_answers, (i) -> i.get('country').led)
                    if bad_leds.length > 0
                        window.channel.trigger('game:badblink', good_leds, bad_leds)
                    else
                        window.channel.trigger('game:goodblink', good_leds, questions.at(question-2).get('answer') == true)

                    # end of the game is near...
                    clear_timer()
                    output = _.extend _options,
                        questions: questions.toJSON()
                        answers: questions.map (i) ->
                            id: i.get('id')
                            answer: i.get('answer')
                        time: info.get('time')
                    window.channel.trigger('game:close', output)
                else
                    if user_answer
                        window.sfx.yes.play()
                    else
                        window.sfx.no.play()

                    # blink LED
                    leds = _.map(correct_answers, (i) -> i.get('country').led)
                    window.channel.trigger('game:goodblink', leds, questions.at(question-2).get('answer') == true)

                    info.set('question', question)
                    info.set('current', 0)
                    question_view.destroy()

                    # set new question
                    question_view = new QuestionItemView
                        model: questions.at(question - 1)
                    layout.getRegion('question').show(question_view)

            # start this screen
            set_timer(handler, TIMER_DELAY)

        questions.fetch()

    Mod.onStop = (options) ->
        clear_timer()
        info = undefined
        questions.off('sync')
        questions = undefined
        layout.destroy()
        local_channel.off('penalty')
        local_channel.off('next')
        local_channel.reset()

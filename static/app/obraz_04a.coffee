# Obrazovka c.4
#
# Prubeh hry.


# ============================================================================

App = new Marionette.Application()

# ============================================================================


App.module "Game", (Mod, App, Backbone, Marionette, $, _) ->

    # bus --------------------------------------------------------------------

    Mod.channel = Backbone.Wreqr.radio.channel('main')


    # casovac ----------------------------------------------------------------

    Mod.timer_delay = 100
    Mod.timer_id = undefined

    Mod.timer_fn = () ->
        Mod.channel.commands.execute('main', 'tick')

    Mod.clear_timer = () ->
        if Mod.timer_fn != undefined
            window.clearInterval(Mod.timer_id)

    Mod.set_timer = () ->
        Mod.clear_timer()
        Mod.timer_id = window.setInterval(Mod.timer_fn, Mod.timer_delay)


    # modely a kolekce -------------------------------------------------------

    Mod.Progress = Backbone.Model.extend
        defaults:
            total: 0
            current: 0

    Mod.Info = Backbone.Model.extend
        defaults:
            question: 1
            total_questions: null
            category: null
            time: 0

    Mod.Question = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: null
            question: null
            image: null
            country: null
            category: null

    Mod.Questions = Backbone.Collection.extend
        model: Mod.Question
        parse: (response, options) ->
            response.results

        initialize: (category_id) ->
            @url = "/api/questions/#{ category_id }"


    # views ------------------------------------------------------------------

    Mod.InfoItemView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <div class="col-md-4">
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
                elapsed(@time)

        initialize: (options) ->
            @model.on 'change', () =>
                @render()


    Mod.ProgressItemView = Marionette.ItemView.extend
        className: 'progress'
        template: (serialized_model) ->
            _.template("""
            <div class="progress-bar" role="progressbar" aria-valuenow="<%= get_percent() %>" aria-valuemin="0" aria-valuemax="100" style="width: <%= get_percent() %>%;"></div>
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


    Mod.QuestionItemView = Marionette.ItemView.extend
        tagName: 'h1'
        template: (serialized_model) ->
            _.template("<%= display_question() %>")(serialized_model)
        templateHelpers: ->
            display_question: ->
                if @image != null
                    @image
                else
                    @question

        initialize: (options) ->
            @model.on 'change', () =>
                @render()


    Mod.QuestionLayout = Marionette.LayoutView.extend
        el: '#content'
        template: _.template """
            <div class="row">
                <div class="col-md-12" id="info"></div>
            </div>
            <div class="row">
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


# --- inicializace aplikace

App.addInitializer (options) ->

    #category_id = options.category_id   # TODO:
    category_id = 1

    # modul
    Game = App.module("Game")

    # data (set dotazu)
    info = new Game.Info
        total_questions: 10     # TODO: options
        category: 'unknown'     # TODO: options

    progress = new Game.Progress
        total: 10               # TODO: options
        current: 0

    # otazky ze serveru
    questions = new Game.Questions(category_id)
    questions.fetch()
    questions.on 'sync', () ->

        # layout
        q_layout = new Game.QuestionLayout()
        q_layout.render()

        # info radek nahore
        info_view = new Game.InfoItemView({model: info})
        q_layout.getRegion('info').show(info_view)

        # otazka
        question_view = new Game.QuestionItemView({model: questions.at(info.get('question'))})
        q_layout.getRegion('question').show(question_view)

        # progress bar
        progress_view = new Game.ProgressItemView({model: progress})
        q_layout.getRegion('progress').show(progress_view)

        # nastaveni casovace
        Game.channel.commands.setHandler 'main', (msg) ->
            time = info.get('time') + 1
            info.set('time', time)

            current = progress.get('current')
            total = progress.get('total')
            if current >= total
                question = info.get('question') + 1
                info.set('question', question)
                progress.set('current', 0)

                question_view = new Game.QuestionItemView({model: questions.at(question)})
                q_layout.getRegion('question').show(question_view)

            else
                progress.set('current', current + .1)

        Game.set_timer()

App.start()

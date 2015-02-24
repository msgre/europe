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

        initialize: () ->
            that = @

            # progress penalty due to passing wrong tunnel
            Mod.channel.vent.on 'penalty', (count) ->
                current = that.get('current')
                total = that.get('total')
                current += count
                if current > total
                    current = total
                that.set('current', current)

    Mod.Info = Backbone.Model.extend
        defaults:
            question: 1
            total_questions: null
            category: null
            time: 0

        initialize: () ->
            that = @

            # time penalty due to passing wrong tunnel
            Mod.channel.vent.on 'penalty', (count) ->
                time = that.get('time')
                that.set('time', time + count * 10) # TODO: penalta se tyka 2 casti systemu, kazdy jede v jine jednotce; mel bych to nejak sjednotit

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

            that = @
            # event about tunnel crossing
            window.main_channel.vent.on 'tunnel', (number) ->
                country = that.model.get('country')
                if "#{number}" == "#{country.sensor}"
                    Mod.channel.vent.trigger('next')
                else
                    Mod.channel.vent.trigger('penalty', 3)

            window.main_channel.vent.on 'good', (number) ->
                Mod.channel.vent.trigger('next')

            window.main_channel.vent.on 'bad', (number) ->
                Mod.channel.vent.trigger('penalty', 3)

        onBeforeDestroy: () ->
            window.main_channel.vent.off('bad')
            window.main_channel.vent.off('good')
            window.main_channel.vent.off('tunnel')

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


    Mod.on "start", (options) ->

        # data pro horni/dolni linku
        info = new Mod.Info
            total_questions: options.total_questions
            category: options.category.title

        progress = new Mod.Progress
            total: options.total_questions
            current: 0

        # data pro prostredek (otazky ze serveru)
        questions = new Mod.Questions(options.category.id)
        questions.fetch()
        questions.on 'sync', () ->

            # layout
            q_layout = new Mod.QuestionLayout()
            q_layout.render()

            # info radek nahore
            info_view = new Mod.InfoItemView
                model: info
            q_layout.getRegion('info').show(info_view)

            # otazka
            question_view = new Mod.QuestionItemView
                model: questions.at(info.get('question') - 1)
            q_layout.getRegion('question').show(question_view)

            # progress bar
            progress_view = new Mod.ProgressItemView
                model: progress
            q_layout.getRegion('progress').show(progress_view)

            # nastaveni casovace
            Mod.channel.commands.setHandler 'main', (msg) ->
                time = info.get('time') + 1
                info.set('time', time)

                current = progress.get('current')
                total = progress.get('total')
                if current >= total
                    Mod.channel.vent.trigger('next')
                else
                    progress.set('current', current + .1)

            Mod.channel.vent.on 'next', () ->
                question = info.get('question') + 1
                if question > options.total_questions
                    Mod.clear_timer()
                    console.log 'Prechod na obrazovku #5'
                    console.log elapsed(info.get('time'))
                    # TODO: bude se toho mozna muset poslat vic, pokud to nebude v option (napr. kategorie, sada dotazu, apod)
                else
                    info.set('question', question)
                    progress.set('current', 0)

                    question_view.destroy()
                    question_view = new Mod.QuestionItemView
                        model: questions.at(question - 1)
                    q_layout.getRegion('question').show(question_view)

            Mod.set_timer()



# --- inicializace aplikace

# TODO: zatim definovano pouze staticky
options =
    total_questions: 10
    category:
        id: 1
        title: 'Hlavní města'

App.start(options)

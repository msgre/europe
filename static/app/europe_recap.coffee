# Screen #?, recapitulation
#

App.module "Recap", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined
    IDLE_TIMEOUT = 4000
    DIFFICULTY_EASY = 'E'
    DIFFICULTY_HARD = 'H'
    layout = undefined

    # --- models & collections

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

    # --- views

    TitleView = Marionette.ItemView.extend
        tagName: "h3"
        template: (serialized_model) ->
            _.template("<%= title %> / <%= difficulty %>")(serialized_model)

        rerender: (model) ->
            @model = model
            @render()

    RecapItemView = Marionette.ItemView.extend
        tagName: "div"
        className: "col-md-4 text-center well"
        attributes: (a, b, c) ->
            if @model.get('answer')
                {style: "color:green; height:120px"}
            else
                {style: "color:red; height:120px"}
        template: (serialized_model) ->
            _.template("<%= question %><br>Odpověď: <%= country.title %><% if (image) {%><br><img height=\"20\" src=\"<%= image %>\" /><% } %>")(serialized_model)


    BlankView = Marionette.ItemView.extend
        template: "<p>Nahrávám...</p>"

    RecapView = Marionette.CollectionView.extend
        childView: RecapItemView
        emptyView: BlankView

    RecapLayout = Marionette.LayoutView.extend
        template: _.template """
            <div class="row">
                <div class="col-md-12">
                    <h3 id="title"></h3>
                </div>
            </div>
            <div class="row" id="recap">
            </div>
        """

        regions:
            title: '#title'
            recap: '#recap'

    # --- timer handler

    handler = () ->
        window.channel.command('recap:close', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Recap module'
        console.log options
        _options = options
        layout = new RecapLayout
            el: make_content_wrapper()
        layout.render()

        questions = new Questions options.questions, 
            category: options.gamemode.category
            difficulty: options.gamemode.difficulty

        # set views in regions
        title = new Backbone.Model
            title: options.gamemode.title
            difficulty: if options.gamemode.difficulty == DIFFICULTY_EASY then "Jednoduchá obtížnost" else "Složitá obtížnost"
        layout.getRegion('title').show new TitleView
            model: title
        layout.getRegion('recap').show new RecapView
            collection: questions

        # fetch collection results from server
        # results.fetch()

        # set handler on buttons
        window.channel.on 'key', (msg) ->
            set_new_timeout = true

            if msg == 'fire' or msg == 'left' or msg == 'right'
                window.sfx.button2.play()
                set_delay () ->
                    window.channel.command('recap:close', _options)
                , 100
                set_new_timeout = false
            else
                set_new_timeout = false

            if set_new_timeout
                window.sfx.button.play()
                set_delay(handler, IDLE_TIMEOUT)

        # idle
        set_delay(handler, IDLE_TIMEOUT)


    Mod.onStop = () ->
        window.channel.off('key')
        clear_delay()
        layout.destroy()
        layout = undefined

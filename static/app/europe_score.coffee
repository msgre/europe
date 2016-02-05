# Screen #9, Score / Finalni skore
#

App.module "Score", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined
    layout = undefined

    # --- models & collections

    Result = Backbone.Model.extend
        defaults:
            name: undefined
            time: undefined
            category: undefined

    Results = Backbone.Collection.extend
        model: Result
        initialize: (models, options) ->
            @url = "/api/results/#{ options.difficulty }-#{ options.category }"
        parse: (response, options) ->
            response.results

    # --- views

    TitleView = Marionette.ItemView.extend
        tagName: "h3"
        template: (serialized_model) ->
            _.template("<%= title %> / <%= difficulty %>")(serialized_model)

        rerender: (model) ->
            @model = model
            @render()

    CategoryResultItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("""
                <td><%= name %></td>
                <td class="text-right"><%= show_time() %></td>""")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    NoResultsView = Marionette.ItemView.extend
        template: "<p>Nahrávám...</p>"

    CategoryResultView = Marionette.CollectionView.extend
        childView: CategoryResultItemView
        tagName: 'table'
        className: 'table'
        emptyView: NoResultsView

    ScoreLayout = Marionette.LayoutView.extend
        template: _.template """
            <div class="row">
                <div class="col-md-12">
                    <h3 id="title"></h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-3">&nbsp;</div>
                <div class="col-md-6">
                    <div id="results"></div>
                </div>
                <div class="col-md-3">&nbsp;</div>
            </div>
        """

        regions:
            title:   '#title'
            results: '#results'

    # --- timer handler

    handler = () ->
        window.channel.command('score:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Score module'
        console.log options
        _options = options
        layout = new ScoreLayout
            el: make_content_wrapper()
        layout.render()

        # initialize collections of results
        results = new Results null, 
            category: options.gamemode.category
            difficulty: options.gamemode.difficulty

        # set views in regions
        title = new Backbone.Model
            title: options.gamemode.title
            difficulty: if options.gamemode.difficulty == _options.constants.DIFFICULTY_EASY then "Jednoduchá obtížnost" else "Složitá obtížnost"
        layout.getRegion('title').show new TitleView
            model: title
        layout.getRegion('results').show new CategoryResultView
            collection: results

        # fetch collection results from server
        results.fetch()

        # set handler on buttons
        window.channel.on 'key', (msg) ->
            set_new_timeout = true

            if msg == 'fire' or msg == 'left' or msg == 'right'
                window.sfx.button2.play()
                set_delay () ->
                    window.channel.command('score:idle', _options)
                , 100
                set_new_timeout = false
            else
                set_new_timeout = false

            if set_new_timeout
                window.sfx.button.play()
                set_delay(handler, _options.options.IDLE_SCORE)

        # idle
        set_delay(handler, _options.options.IDLE_SCORE)


    Mod.onStop = () ->
        window.channel.off('key')
        clear_delay()
        layout.destroy()
        layout = undefined

# Screen #6, scores
#

App.module "Score", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined

    # --- models & collections

    Result = Backbone.Model.extend
        defaults:
            name: undefined
            time: undefined
            category: undefined
        url: '/api/score'

    Results = Backbone.Collection.extend
        model: Result
        initialize: (category) ->
            if category
                @url = "/api/results/#{ category }"
            else
                @url = "/api/results"
        parse: (response, options) ->
            response.results

    # --- views

    ResultItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("""
                <td class="text-right">?</td>
                <td><%= name %></td>
                <td><%= category %></td>
                <td class="text-right"><%= show_time() %></td>""")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    CategoryResultItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("""
                <td class="text-right">?</td>
                <td><%= name %></td>
                <td class="text-right"><%= show_time() %></td>""")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    ResultView = Marionette.CollectionView.extend
        childView: ResultItemView
        tagName: 'table'
        className: 'table'

        initialize: (options) ->
            @collection.on 'sync', () =>
                console.log @collection
                @render()

        onDestroy: () ->
            @collection.off('sync')

    CategoryResultView = Marionette.CollectionView.extend
        childView: CategoryResultItemView
        tagName: 'table'
        className: 'table'

        initialize: (options) ->
            @collection.on 'sync', () =>
                @render()

        onDestroy: () ->
            @collection.off('sync')

    ResultLayout = Marionette.LayoutView.extend
        template: _.template """
            <div class="row">
                <div class="col-md-6">
                    <h3>Nejlepší celkové výsledky</h3>
                    <div id="total-results">
                    </div>
                </div>
                <div class="col-md-1"></div>
                <div class="col-md-5">
                    <h3>Nejlepší výsledky v kategorii XYZ</h3>
                    <div id="category-results">
                    </div>
                </div>
            </div>
        """

        regions:
            total: '#total-results'
            category: '#category-results'

    # --- timer handler

    # handler = () ->
    #     window.channel.command('gamemode:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log options
        _options = options
        total_results = new Results()
        category_results = new Results(options.category.id)

        result_view = new ResultView
            collection: total_results
        category_view = new CategoryResultView
            collection: category_results

        layout = new ResultLayout
            el: make_content_wrapper()
        layout.render()

        layout.getRegion('total').show(result_view)
        layout.getRegion('category').show(category_view)

        total_results.fetch()
        category_results.fetch()

        #set_delay(handler, IDLE_TIMEOUT)

    Mod.onStop = () ->
        clear_delay()
        view.destroy()

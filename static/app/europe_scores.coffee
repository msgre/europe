# Screen #?, browsable scores
#

App.module "Scores", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined

    # --- models & collections

    Result = Backbone.Model.extend
        defaults:
            name: undefined
            time: undefined
            category: undefined
# TODO: obtiznost a dalsi cypiny (ty asi nejsou treba)

    Results = Backbone.Collection.extend
        model: Result
        initialize: (category) ->
            @url = "/api/results/#{ category }"
        parse: (response, options) ->
            response.results

    # --- views

    CategoryResultItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("""
                <td><%= name %></td>
                <td class="text-right"><%= show_time() %></td>""")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

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
                <div class="col-md-12">
                    <h3>Kategorie ??</h3>
                </div>

                <div class="col-md-6">
                    <h3>Malá obtížnost</h3>
                    <div id="easy-results">
                    </div>
                </div>
                <div class="col-md-1"></div>
                <div class="col-md-5">
                    <h3>Velká obtížnost</h3>
                    <div id="hard-results">
                    </div>
                </div>
            </div>
        """

        regions:
            easy: '#easy-results'
            hard: '#hard-results'

    # --- timer handler

    # TODO:
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

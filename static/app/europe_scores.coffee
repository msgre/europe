# Screen #3, Scores / Vysledky
#

App.module "Scores", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined
    categories = undefined
    layout = undefined
    index = 0

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
            out = []
            last = null
            i = 1
            # add order and flag for showing order
            for item in response.results
                show = last is null or last.time != item.time
                _.extend(item, {show: show, order: i})
                out.push(item)
                last = item
                i += 1
            out

    Category = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: undefined
            title: undefined
            active: false
            order: undefined

    Categories = Backbone.Collection.extend
        model: Category
        comparator: 'order'
        url: '/api/categories'

        parse: (response, options) ->
            response.results

    # --- views

    TitleView = Marionette.ItemView.extend
        tagName: "h3"
        template: (serialized_model) ->
            _.template("<img src='<%= icon %>'><%= title %>")(serialized_model)

        rerender: (model) ->
            @model = model
            @render()

    CategoryResultItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("""
                <td class="text-right"><% if (show) {%><%= order %><% } %></td>
                <td><%= name %></td>
                <td class="text-right"><%= show_time() %></td>""")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    NoResultsView = Marionette.ItemView.extend
        tagName: 'tr'
        template: _.template("<td style='font-weight:400;text-align:left;border-right:none'>Nahrávám…</td>")

    CategoryResultView = Marionette.CollectionView.extend
        childView: CategoryResultItemView
        tagName: 'table'
        className: 'results'
        emptyView: NoResultsView

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="main">
                <div id="header">
                    <h1></h1>
                </div>
                <div id="body">
                    <div class="col">
                        <h2>Jednoduchá úroveň</h2>
                        <div id="easy-results"></div>
                    </div>
                    <div class="col">
                        <h2>Obtížná úroveň</h2>
                        <div id="hard-results"></div>
                    </div>
                    <div class="clear"></div>
                    <table style="margin-top:3em" class="help">
                        <tr>
                            <td>#{SVG.left}&nbsp;#{SVG.right}</td>
                            <td><p>Výběr kategorie</p></td>
                            <td>#{SVG.ok}</td>
                            <td><p>Návrat</p></td>
                        </tr>
                    </table>
                </div>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-a');

        regions:
            title: '#header h1'
            easy:  '#easy-results'
            hard:  '#hard-results'


    # --- timer handler

    handler = () ->
        window.channel.trigger('scores:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Scores module'
        console.log options
        _options = options
        index = 0
        layout = new ScreenLayout
            el: make_content_wrapper()
        layout.render()

        categories = new Categories()
        categories.on 'sync', () ->

            # initialize collections of results
            category = categories.at(index)
            easy_results = new Results null, 
                category: category.get('id')
                difficulty: _options.constants.DIFFICULTY_EASY
            hard_results = new Results null, 
                category: category.get('id')
                difficulty: _options.constants.DIFFICULTY_HARD

            # set views in regions
            layout.getRegion('title').show new TitleView
                model: category

            layout.getRegion('easy').show new CategoryResultView
                collection: easy_results
            layout.getRegion('hard').show new CategoryResultView
                collection: hard_results

            # fetch collection results from server
            easy_results.fetch()
            hard_results.fetch()

            # set handler on buttons (for listing over whole categories)
            window.channel.on 'key', (msg) ->
                old_index = index
                set_new_timeout = true

                if msg == 'left' and index > 0
                    index -= 1
                else if msg == 'right' and index < categories.length - 1
                    index += 1
                else if msg == 'fire'
                    window.sfx.button2.play()
                    set_delay () ->
                        window.channel.trigger('scores:idle', _options)
                    , 100
                    set_new_timeout = false
                else
                    set_new_timeout = false

                if set_new_timeout
                    window.sfx.button.play()
                    set_delay(handler, _options.options.IDLE_SCORES)

                if old_index != index
                    new_category = categories.at(index)
                    # fetch data for newly selected category
                    new_easy_results = new Results null, 
                        category: new_category.get('id')
                        difficulty: _options.constants.DIFFICULTY_EASY
                    new_easy_results.on 'sync', () ->
                        easy_results.reset(new_easy_results.toJSON())
                        new_easy_results.off('sync')
                    new_easy_results.fetch()
                    new_hard_results = new Results null, 
                        category: new_category.get('id')
                        difficulty: _options.constants.DIFFICULTY_HARD
                    new_hard_results.on 'sync', () ->
                        hard_results.reset(new_hard_results.toJSON())
                        hard_results.off('sync')
                    new_hard_results.fetch()

                    # update views
                    layout.getRegion('title').show new TitleView
                        model: new_category

            # idle
            set_delay(handler, _options.options.IDLE_SCORES)

        categories.fetch()

    Mod.onStop = () ->
        window.channel.off('key')
        clear_delay()
        layout.destroy()
        categories.off('sync')
        categories = undefined
        layout = undefined

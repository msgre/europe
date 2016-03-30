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

    # --- views

    InfoView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h1><img src='<%= icon %>'><%= category %></h1>
                <h2><%= difficulty %></h2>
            """)(serialized_model)

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
        template: "<p>Nahrávám...</p>"

    CategoryResultView = Marionette.CollectionView.extend
        childView: CategoryResultItemView
        tagName: 'table'
        className: 'results'
        emptyView: NoResultsView

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header"></div>
            <div id="body"></div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-a');

        regions:
            info:   '#header'
            results: '#body'

    # --- timer handler

    handler = () ->
        window.channel.trigger('score:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Score module'
        console.log options
        _options = options
        layout = new ScreenLayout
            el: make_content_wrapper()
        layout.render()

        # initialize collections of results
        results = new Results null, 
            category: options.gamemode.category
            difficulty: options.gamemode.difficulty

        # set views in regions
        info = new Backbone.Model
            category: options.gamemode.title
            icon: options.gamemode.category_icon
            difficulty: options.gamemode.difficulty_title
        layout.getRegion('info').show new InfoView
            model: info

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
                    window.channel.trigger('score:idle', _options)
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

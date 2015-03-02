# Screen #2, game mode selection
#

App.module "GameMode", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    IDLE_TIMEOUT = 4000
    _options = undefined
    view = undefined

    # --- models & collections

    Category = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: undefined
            title: undefined
            active: false

    Categories = Backbone.Collection.extend
        model: Category
        comparator: 'title'
        url: '/api/categories'

        parse: (response, options) ->
            response.results

        set_active: (index) ->
            if @length < 1
                return
            if not index or index < 0 or index >= @length
                index = 0
            obj = @at(index)
            if obj != undefined
                @each (i) ->
                    if i.get('active')
                        i.set('active', false)
                obj.set('active', true)
            @trigger('change')
            index

    # --- views

    CategoryItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("<td><% if (active) {%> █&nbsp;<% } %></td><td><%= title %></td>")(serialized_model)

    CategoriesView = Marionette.CollectionView.extend
        childView: CategoryItemView
        initialize: (options) ->
            @index = 0
            that = @

            @collection.on 'sync', () =>
                that.index = @collection.set_active(that.index)
                @render()

            @collection.on 'change', () =>
                @render()

            window.channel.on 'key', (msg) ->
                old_index = that.index
                set_new_timeout = true

                if msg == 'up' and that.index > 0
                    that.index -= 1
                else if msg == 'down' and that.index < that.collection.length - 1
                    that.index += 1
                else if msg == 'fire'
                    obj = that.collection.at(that.index)
                    window.channel.command('gamemode:close', _.extend(_options, {category: obj.toJSON()}))
                    set_new_timeout = false
                else
                    set_new_timeout = false

                if set_new_timeout
                    set_delay(handler, IDLE_TIMEOUT)

                if old_index != that.index
                    that.collection.set_active(that.index)

        onDestroy: () ->
            @collection.off('change')
            @collection.off('sync')
            window.channel.off('key')

    # --- timer handler

    handler = () ->
        window.channel.command('gamemode:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        _options = options
        categories = new Categories()
        view = new CategoriesView
            collection: categories
            el: make_content_wrapper()
        categories.fetch()
        set_delay(handler, IDLE_TIMEOUT)

    Mod.onStop = () ->
        clear_delay()
        view.destroy()

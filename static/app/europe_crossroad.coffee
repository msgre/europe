# Screen #2, game mode selection
#

App.module "Crossroad", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    IDLE_TIMEOUT = 4000
    _options = undefined
    view = undefined

    # --- models & collections

    Item = Backbone.Model.extend
        defaults:
            id: undefined
            title: undefined
            order: undefined
            active: false
            classes: undefined

    Items = Backbone.Collection.extend
        model: Item
        comparator: 'order'

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

    ItemView = Marionette.ItemView.extend
        tagName: "div"
        attributes: () ->
            class: 
                "col-md-6 " + @model.get('classes')
        template: (serialized_model) ->
            _.template("<% if (active) {%><u><% } %><%= title %><% if (active) {%></u><% } %>")(serialized_model)

    ItemsView = Marionette.CollectionView.extend
        childView: ItemView
        initialize: (options) ->
            @index = 0
            that = @

            @collection.on 'change', () =>
                @render()

            window.channel.on 'key', (msg) ->
                old_index = that.index
                set_new_timeout = true

                if msg == 'left' and that.index > 0
                    that.index -= 1
                else if msg == 'right' and that.index < that.collection.length - 1
                    that.index += 1
                else if msg == 'fire'
                    window.sfx.button2.play()
                    obj = that.collection.at(that.index)
                    window.channel.command('crossroad:close', _.extend(_options, {crossroad: obj.get('id')}))
                    set_new_timeout = false
                else
                    set_new_timeout = false

                if set_new_timeout
                    window.sfx.button.play()
                    set_delay(handler, IDLE_TIMEOUT)

                if old_index != that.index
                    that.collection.set_active(that.index)

        onDestroy: () ->
            @collection.off('change')
            window.channel.off('key')

    # --- timer handler

    handler = () ->
        window.channel.command('crossroad:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'crossroad'
        _options = options
        items = new Items()
        items.add new Item
            id: "game"
            title: "Hra"
            order: 10
            active: true
            classes: "text-right"
        items.add new Item
            id: "results"
            title: "Výsledky"
            order: 20
            active: false
            classes: "text-left"
        view = new ItemsView
            collection: items
            el: make_content_wrapper()
        view.render()
        set_delay(handler, IDLE_TIMEOUT)

    Mod.onStop = () ->
        clear_delay()
        view.destroy()

# Screen #2, Crossroad / Volba hra-vysledky
#

App.module "Crossroad", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined
    layout = undefined

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
                "button #{@model.get('classes')} #{if @model.get('active') then 'active' else ''}"
        template: (serialized_model) ->
            _.template("<p><img src='<%= icon %>' height='24' /><%= title %></p>")(serialized_model)

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
                    window.channel.trigger('crossroad:close', _.extend(_options, {crossroad: obj.get('id')}))
                    set_new_timeout = false
                else
                    set_new_timeout = false

                if set_new_timeout
                    window.sfx.button.play()
                    set_delay(handler, _options.options.IDLE_CROSSROAD)

                if old_index != that.index
                    that.collection.set_active(that.index)

        onDestroy: () ->
            @collection.off('change')
            window.channel.off('key')

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="body">
                <table class="crossroad">
                    <tr>
                        <td></td>
                    </tr>
                </table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-c');

        regions:
            cell: '.crossroad td'

    # --- timer handler

    handler = () ->
        window.channel.trigger('crossroad:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Crossroad module'
        console.log options
        _options = options
        items = new Items()
        items.add new Item
            id: "game"
            title: "Hra"
            icon: "svg/star-small.svg"
            order: 10
            active: true
            classes: "button-3-4"
        items.add new Item
            id: "results"
            title: "Výsledky"
            icon: "svg/star-small.svg"
            order: 20
            active: false
            classes: "button-1-4"

        layout = new ScreenLayout({el: make_content_wrapper()})
        layout.render()
        layout.getRegion('cell').show(new ItemsView({collection: items}))
        set_delay(handler, _options.options.IDLE_CROSSROAD)

    Mod.onStop = () ->
        clear_delay()
        layout.destroy()

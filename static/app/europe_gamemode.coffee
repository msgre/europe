# Screen #4, Gamemode / Volba kategorie hry
#

App.module "GameMode", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined
    layout = undefined
    difficulties = undefined
    categories = undefined
    choices = undefined
    local_channel = undefined

    # --- models & collections

    Item = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: undefined
            title: undefined
            active: false
            order: 1

    Items = Backbone.Collection.extend
        model: Item
        comparator: 'order'

        initialize: (models, options) ->
            @active_length = null
            if _.isObject(options) and _.has(options, 'enabled')
                @_enabled = options.enabled
            else
                @_enabled = false
            @_enabled_map = null


        parse: (response, options) ->
            response.results

        set_active: (index) ->
            if @get_enabled_length() < 1
                return
            if not index or index < 0 or index >= @get_enabled_length()
                index = 0
            obj = @at_enabled(index)
            if obj != undefined
                @each (i) ->
                    if i.get('active')
                        i.set('active', false)
                obj.set('active', true)
            @trigger('change')
            index

        get_enabled_length: ->
            if @_enabled
                if @active_length == null
                    x = @filter (i) ->
                        not i.get('disabled')
                    @active_length = x.length
            else
                @active_length = @length
            @active_length

        get_enabled_map: ->
            if @_enabled_map != null
                @_enabled_map
            else
                out = {}
                if @_enabled
                    y = 0
                    @each (item, idx) ->
                        if not item.get('disabled')
                            out[y] = idx
                            y = y + 1
                @_enabled_map = out
        
        at_enabled: (index) ->
            if @_enabled
                obj = @at(@get_enabled_map()[index])
            else
                obj = @at(index)
            obj

        unset_active: ->
            @each (i) ->
                i.set('active', false)

    # --- views

    ItemView = Marionette.ItemView.extend
        tagName: "div"
        className: ->
            "button #{ @model.get('classes') } #{ if @model.get('active') then 'active' else '' }"
        template: (serialized_model) ->
            _.template("<p><%= title %></p>")(serialized_model)

    ItemsView = Marionette.CollectionView.extend
        childView: ItemView
        initialize: (options) ->
            @index = 0
            @command = options.command

            @collection.on 'change', () =>
                @render()

        set_key_handler: () ->
            window.channel.on 'key', (msg) =>
                old_index = @index
                set_new_timeout = true
                change_collection = false

                if msg == 'left' and @index > 0
                    @index -= 1
                    change_collection = true
                else if msg == 'right' and @index < @collection.get_enabled_length() - 1
                    @index += 1
                    change_collection = true
                else if msg == 'fire'
                    window.sfx.button2.play()
                    obj = @collection.at_enabled(@index)
                    @disable_keys()
                    local_channel.trigger(@command, obj)
                    set_new_timeout = false
                else
                    set_new_timeout = false

                if set_new_timeout
                    window.sfx.button.play()
                    set_delay(handler, _options.options.IDLE_GAMEMODE)

                if change_collection and old_index != @index
                    @collection.set_active(@index)

        enable_keys: ->
            @set_key_handler()

        disable_keys: ->
            window.channel.off('key')

        onDestroy: ->
            @collection.off('change')
            @disable_keys()

        set_active: ->
            @index = 0
            @collection.set_active(@index)
            @enable_keys()

        reset: ->
            @disable_keys()
            @collection.unset_active()
            @index = 0

    CategoryItemView = Marionette.ItemView.extend
        tagName: "div"
        className: ->
            "button button-1-4 #{ if @model.get('active') then 'active' else '' }"
        template: (serialized_model) ->
            _.template("<p<% if (disabled) {%> class='disabled'<% } %>><img src='<%= icon %>'/><%= title %></p>")(serialized_model)

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="body">
                <table class="gamemode">
                    <tr class="row-1">
                        <td></td>
                    </tr>
                    <tr class="row-2">
                        <td></td>
                    </tr>
                    <tr class="row-3">
                        <td></td>
                    </tr>
                </table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-c');

        regions:
            difficulty: '.row-1 td'
            category:  '.row-2 td'
            choice:  '.row-3 td'

    # --- timer handler

    handler = () ->
        window.channel.trigger('gamemode:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Gamemode module'
        console.log options
        _options = options
        local_channel = Backbone.Radio.channel('gamemode')
        layout = new ScreenLayout
            el: make_content_wrapper()
        layout.render()

        # difficulties collection
        difficulties = new Items
        difficulties.add new Item
            id: _options.constants.DIFFICULTY_EASY
            title: 'Jednoduchá hra'
            active: false
            classes: 'button-2-4'
            order: 1
        difficulties.add new Item
            id: _options.constants.DIFFICULTY_HARD
            title: 'Obtížná hra'
            active: false
            classes: 'button-2-4'
            order: 2

        # choices collection
        choices = new Items
        choices.add new Item
            id: 'ok'
            title: 'Hrát'
            active: false
            classes: 'button-3-4'
            order: 1
        choices.add new Item
            id: 'repeat'
            title: 'Vybrat znovu'
            active: false
            classes: 'button-1-4'
            order: 2


        # init views
        layout.getRegion('difficulty').show new ItemsView
            collection: difficulties
            command: 'category'
        categories = new Items(null, {enabled: true})
        categories.url = '/api/categories'
        layout.getRegion('category').show new ItemsView
            childView: CategoryItemView
            collection: categories
            command: 'choice'
        layout.getRegion('choice').show new ItemsView
            collection: choices
            command: 'done'
        
        categories.fetch()

        
        local_options = {}
        local_channel.on 'category', (obj) ->
            local_options['difficulty'] = obj.get('id')
            local_options['difficulty_title'] = obj.get('title')
            layout.getRegion('category').currentView.set_active()

        local_channel.on 'choice', (obj) ->
            local_options['category'] = obj.get('id')
            local_options['category_icon'] = obj.get('icon')
            local_options['title'] = obj.get('title')
            if local_options.difficulty == _options.constants.DIFFICULTY_EASY
                local_options['time'] = obj.get('time_easy')
                local_options['penalty'] = obj.get('penalty_easy')
            else
                local_options['time'] = obj.get('time_hard')
                local_options['penalty'] = obj.get('penalty_hard')
            layout.getRegion('choice').currentView.set_active()

        local_channel.on 'done', (obj) ->
            if obj.get('id') == 'ok'
                window.channel.trigger('gamemode:close', _.extend(_options, {gamemode: local_options}))
            else
                local_options = {}
                layout.getRegion('difficulty').currentView.reset()
                layout.getRegion('category').currentView.reset()
                layout.getRegion('choice').currentView.reset()
                layout.getRegion('difficulty').currentView.set_active()


        layout.getRegion('difficulty').currentView.set_active()

        set_delay(handler, _options.options.IDLE_GAMEMODE)


    Mod.onStop = () ->
        clear_delay()
        layout.destroy()
        choices = undefined
        categories = undefined
        difficulties = undefined
        local_channel.reset()

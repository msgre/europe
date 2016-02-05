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
        
        unset_active: ->
            @each (i) ->
                i.set('active', false)

    # --- views

    ItemView = Marionette.ItemView.extend
        tagName: "div"
        className: "col-md-6"
        template: (serialized_model) ->
            _.template("<% if (active) {%><u><% } %><%= title %><% if (active) {%></u><% } %>")(serialized_model)

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
                else if msg == 'right' and @index < @collection.length - 1
                    @index += 1
                    change_collection = true
                else if msg == 'fire'
                    window.sfx.button2.play()
                    obj = @collection.at(@index)
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
        className: "col-md-4 text-center well"
        template: (serialized_model) ->
            _.template("<% if (active) {%><u><% } %><%= title %><% if (active) {%></u><% } %>")(serialized_model)

    GameModeLayout = Marionette.LayoutView.extend
        template: _.template """
            <div class="row">
                <div class="col-md-3">&nbsp;</div>
                <div class="col-md-6" id="difficulty"></div>
                <div class="col-md-3">&nbsp;</div>
            </div>
            <br>
            <div class="row">
                <div class="col-md-12" id="category">
                </div>
            </div>
            <br>
            <div class="row">
                <div class="col-md-3">&nbsp;</div>
                <div class="col-md-6" id="choice"></div>
                <div class="col-md-3">&nbsp;</div>
            </div>
        """

        regions:
            difficulty: '#difficulty'
            category:  '#category'
            choice:  '#choice'

    # --- timer handler

    handler = () ->
        window.channel.command('gamemode:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Gamemode module'
        console.log options
        _options = options
        local_channel = Backbone.Radio.channel('gamemode')
        layout = new GameModeLayout
            el: make_content_wrapper()
        layout.render()

        # difficulties collection
        difficulties = new Items
        difficulties.add new Item
            id: _options.constants.DIFFICULTY_EASY
            title: 'Jednoduchá'
            active: false
            order: 1
        difficulties.add new Item
            id: _options.constants.DIFFICULTY_HARD
            title: 'Obtížná'
            active: false
            order: 2

        # choices collection
        choices = new Items
        choices.add new Item
            id: 'ok'
            title: 'Hrát'
            active: false
            order: 1
        choices.add new Item
            id: 'repeat'
            title: 'Vybrat znovu'
            active: false
            order: 2


        # init views
        layout.getRegion('difficulty').show new ItemsView
            collection: difficulties
            command: 'category'
        categories = new Items()
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
            layout.getRegion('category').currentView.set_active()

        local_channel.on 'choice', (obj) ->
            local_options['category'] = obj.get('id')
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
                window.channel.command('gamemode:close', _.extend(_options, {gamemode: local_options}))
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

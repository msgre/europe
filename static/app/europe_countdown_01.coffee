# Screen #3, countdown
#

App.module "Countdown", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    TICK_TIMEOUT = 1100
    _options = undefined
    model = undefined
    view = undefined

    # --- models & collections

    Countdown = Backbone.Model.extend
        defaults:
            number: 3

    # --- views

    CountdownItemView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<h1><%= display_number() %></h1>")(serialized_model)
        templateHelpers: ->
            display_number: ->
                if @number > 0
                    @number
                else
                    'Start!'
        initialize: (options) ->
            @model.on 'change', () =>
                @render()
        onDestroy: () ->
            @model.off('change')

    # --- timer handler

    handler = () ->
        number = model.get('number')
        model.set('number', number - 1)
        if number == 0
            clear_timer()
            window.channel.command('countdown:close', _options)

    # --- module

    Mod.onStart = (options) ->
        _options = options                  # store options (selected gamemode inside)
        model = new Countdown()
        view = new CountdownItemView
            model: model
            el: make_content_wrapper()
        view.render()
        set_timer(handler, TICK_TIMEOUT)

    Mod.onStop = () ->
        clear_timer()
        view.destroy()
        model = undefined

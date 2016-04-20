# Screen #5, Countdown / Odpocet
#

App.module "Countdown", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined
    model = undefined
    layout = undefined

    # --- models & collections

    Countdown = Backbone.Model.extend
        defaults:
            number: 4

    # --- views

    CountdownItemView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<%= display_number() %>")(serialized_model)

        templateHelpers: ->
            display_number: ->
                if @number == 4
                    'Připravit'
                else if @number > 0
                    @number
                else
                    'Start!'
        initialize: (options) ->
            @model.on 'change', () =>
                number = @model.get('number')
                if number > 0
                    window.channel.trigger('countdown:flash')
                else if number == 0
                    window.channel.trigger('countdown:noise')
                @render()
        onDestroy: () ->
            @model.off('change')

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="body">
                <table class="countdown state-4">
                    <tr>
                        <td></td>
                    </tr>
                </table>
            </div>
        """

        initialize: (options) ->
            @model = options.model
            @model.on 'change', () =>
                # dynamic change of table CSS class according to state
                @$el.find('.countdown').attr('class', "countdown state-#{ @model.get('number') }")

        onDestroy: () ->
            @model.off('change')

        onRender: () ->
            $('body').attr('class', 'layout-c');

        regions:
            cell: '.countdown td'

    # --- timer handler

    handler = () ->
        number = model.get('number')
        model.set('number', number - 1)
        if number == 0
            clear_timer()
            window.channel.trigger('countdown:blank')
            window.channel.trigger('countdown:close', _options)
        else
            window.sfx["odpocet#{number}"].play()

    # --- module

    Mod.onStart = (options) ->
        console.log 'Countdown module'
        console.log options
        _options = options                  # store options (selected gamemode inside)
        model = new Countdown()
        layout = new ScreenLayout({el: make_content_wrapper(), model: model})
        layout.render()
        layout.getRegion('cell').show(new CountdownItemView({model: model}))
        set_timer(handler, _options.options.COUNTDOWN_TICK_TIMEOUT)

    Mod.onStop = () ->
        clear_timer()
        layout.destroy()
        model = undefined

# Obrazovka c.3
#
# Odpocet (countdown).


# ============================================================================

App = new Marionette.Application()

# ============================================================================


App.module "Countdown", (Mod, App, Backbone, Marionette, $, _) ->

    # bus --------------------------------------------------------------------

    Mod.channel = Backbone.Wreqr.radio.channel('main')


    # casovac ----------------------------------------------------------------

    Mod.timer_delay = 1100
    Mod.timer_id = undefined

    Mod.timer_fn = () ->
        Mod.channel.commands.execute('main', 'tick')

    Mod.clear_timer = () ->
        if Mod.timer_fn != undefined
            window.clearInterval(Mod.timer_id)

    Mod.set_timer = () ->
        Mod.clear_timer()
        Mod.timer_id = window.setInterval(Mod.timer_fn, Mod.timer_delay)


    # modely a kolekce -------------------------------------------------------

    Mod.Countdown = Backbone.Model.extend
        defaults:
            number: 3

    # views ------------------------------------------------------------------

    Mod.CountdownItemView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<h1><%= display_number() %></h1>")(serialized_model)
        el: '#countdown'
        templateHelpers: ->
            display_number: ->
                if @number > 0
                    @number
                else
                    'Start!'

        initialize: (options) ->
            @model.on 'change', () =>
                @render()


# --- inicializace aplikace

App.addInitializer (options) ->

    # modul
    Countdown = App.module("Countdown")

    # data pro obrazovku
    countdown = new Countdown.Countdown()

    Countdown.channel.commands.setHandler 'main', (msg) ->
        number = countdown.get('number')
        countdown.set('number', number - 1)
        if number == 0
            Countdown.clear_timer()
            console.log 'Presun na obrazovku #4' # TODO:

    countdown_view = new Countdown.CountdownItemView({model: countdown})
    countdown_view.render()

    # spusteni casovace pro vyber kategorie
    Countdown.set_timer()


App.start()

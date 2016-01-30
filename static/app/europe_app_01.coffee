App = new Marionette.Application()


App.on 'start', (global_options) ->
    active_module = null
    that = @

    state_handler = (new_module_name, options) ->
        if active_module != null
            active_module.stop()

        active_module = that.module(new_module_name)
        active_module.start(options)

    # --- intro

    window.channel.comply 'intro:start', (options) ->
        state_handler("Intro", options)

    window.channel.comply 'intro:close', (options) ->
        window.channel.command('crossroad:start', options)

    # --- crossroad

    window.channel.comply 'crossroad:start', (options) ->
        state_handler("Crossroad", options)

    window.channel.comply 'crossroad:idle', (options) ->
        window.channel.command('intro:start', options)

    window.channel.comply 'crossroad:close', (options) ->
        if options.crossroad == 'game'
            window.channel.command('gamemode:start', options)
        else
            # set_delay () ->
            #     # NOTE: without delay, intro immediately recognise keypress and go to crossroad again
            #     window.channel.command('intro:start', options) # TODO: sup na vysledky
            # , 100
            window.channel.command('scores:start', options)

    # --- scores

    window.channel.comply 'scores:start', (options) ->
        state_handler("Scores", options)

    window.channel.comply 'scores:idle', (options) ->
        window.channel.command('intro:start', options)

    window.channel.comply 'scores:close', (options) ->
        window.channel.command('crossroad:start', options)

    # --- gamemode

    window.channel.comply 'gamemode:start', (options) ->
        state_handler("GameMode", options)

    window.channel.comply 'gamemode:idle', (options) ->
        window.channel.command('intro:start', options)

    window.channel.comply 'gamemode:close', (options) ->
        window.channel.command('countdown:start', options)

    # --- countdown

    window.channel.comply 'countdown:start', (options) ->
        state_handler("Countdown", options)

    window.channel.comply 'countdown:close', (options) ->
        window.channel.command('game:start', options)

    # --- game

    window.channel.comply 'game:start', (options) ->
        state_handler("Game", options)

    window.channel.comply 'game:close', (options) ->
        window.channel.command('result:start', options)

    # --- result

    window.channel.comply 'result:start', (options) ->
        state_handler("Result", options)

    window.channel.comply 'result:close', (options) ->
        window.channel.command('score:start', options)

    # --- score

    window.channel.comply 'score:start', (options) ->
        state_handler("Score", options)

    window.channel.comply 'score:close', (options) ->
        console.log 'presun na 7 obrazovku (vysledky)'
        console.log options # tu se prenasi informace o tom jaky mod hry si vybral

    # start!
    window.channel.command('intro:start', global_options)

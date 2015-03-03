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
        window.channel.command('gamemode:start', options)

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

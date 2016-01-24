# Screen #1, intro
#

App.module "Intro", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    TIME_PER_SCREEN = 3000
    view_list = undefined
    view = undefined
    state = undefined

    # --- views

    Intro01 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h1 style="color:navy">Intro 01</h1>
                <p>Chceš začít novou hru? Stiskni kterékoliv tlačítko na panelu a pojďme na to!</p>
            """)(serialized_model)

    Intro02 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h1 style="color:green">Intro 02</h1>
                <p>Chceš začít novou hru? Stiskni kterékoliv tlačítko na panelu a pojďme na to!</p>
            """)(serialized_model)

    Intro03 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h1 style="color:yellow">Intro 03</h1>
                <p>Chceš začít novou hru? Stiskni kterékoliv tlačítko na panelu a pojďme na to!</p>
            """)(serialized_model)

    Intro04 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h1 style="color:red">Intro 04</h1>
                <p>Chceš začít novou hru? Stiskni kterékoliv tlačítko na panelu a pojďme na to!</p>
            """)(serialized_model)

    # --- herr director

    handler = () ->
        if state >= view_list.length
            state = 0
        if view != undefined
            view.destroy()
        view = new view_list[state]({el: make_content_wrapper()})
        view.render()
        state++

    # --- module

    Mod.onStart = (options) ->
        console.log 'intro'
        state = 0
        view_list = [
            Intro01
            Intro02
            Intro03
            Intro04
        ]
        window.channel.on 'keypress', () ->
            console.log 'intro keypress'
            window.sfx.button.play()
            window.channel.command('intro:close', options)
        handler()
        set_timer(handler, TIME_PER_SCREEN)

    Mod.onStop = () ->
        clear_timer()
        window.channel.off('keypress')
        view.destroy()

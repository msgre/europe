# Screen #1, Intro / Uvodni stranka
#

App.module "Intro", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    view_list = undefined
    layout = undefined
    state = undefined
    _options = undefined

    # --- views

    Intro01 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <img src="img/brandenburg.jpg" width="1320" height="600">
            """)(serialized_model)

    Intro02 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <img src="img/brusel.jpg" width="1320" height="600">
            """)(serialized_model)

    Intro03 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <img src="img/london.jpg" width="1320" height="600">
            """)(serialized_model)

    Intro04 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <img src="img/budapest.jpg" width="1320" height="600">
            """)(serialized_model)

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="body">
                <table class="intro">
                    <tr class="row-1">
                        <td class="cell-a1"></td>
                        <td class="cell-a2"></td>
                    </tr>
                    <tr class="row-2">
                        <td class="cell-b1">
                            <div>
                                <h1>Chceš začít novou hru?</h1>
                                <h3>Stiskni kterékoliv tlačítko na panelu!</h3>
                            </div>
                        </td>
                        <td class="cell-b2">
                            <img src="../svg/circle.svg" width="200px">
                        </td>
                    </tr>
                </table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-c');

        regions:
            slideshow: '.cell-a1'
            top: '.cell-a2'

    # --- herr director

    handler = () ->
        if state >= view_list.length
            state = 0
        layout.getRegion('slideshow').show(new view_list[state]())
        state++

    # --- module

    Mod.onStart = (options) ->
        console.log 'Intro module'
        console.log options
        _options = options
        state = 0
        view_list = [
            Intro01
            Intro02
            Intro03
            Intro04
        ]
        layout = new ScreenLayout({el: make_content_wrapper()})
        layout.render()

        window.channel.on 'keypress', () ->
            window.sfx.button.play()
            window.channel.trigger('intro:close', options)
        handler()
        set_timer(handler, _options.options.INTRO_TIME_PER_SCREEN)

    Mod.onStop = () ->
        clear_timer()
        window.channel.off('keypress')
        layout.destroy()
        view_list = undefined
        state = undefined

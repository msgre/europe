# Screen #1, Intro / Uvodni stranka
#

App.module "Intro", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    SLIDESHOW_TIMER = 5000
    layout = undefined
    _options = undefined

    # --- models & collections

    Result = Backbone.Model.extend
        defaults:
            time: undefined
            title: undefined

    Results = Backbone.Collection.extend
        model: Result
        url: "/api/results"
            
        parse: (response, options) ->
            response.results

    # --- views

    HighScoreItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("""<td><%= title %></td>
                <td class="text-right"><%= show_time() %></td>""")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    NoResultsView = Marionette.ItemView.extend
        tagName: 'tr'
        className: 'loading'
        template: _.template("<td>Nahrávám…</td>")

    HighScoreView = Marionette.CollectionView.extend
        childView: HighScoreItemView
        tagName: 'tbody'
        emptyView: NoResultsView

    Slideshow = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <div class="fadein">
                    <img src="img/titul1.png">
                    <img src="img/brandenburg.jpg">
                    <img src="img/titul1.png">
                    <img src="img/brusel.jpg">
                    <img src="img/titul1.png">
                    <img src="img/london.jpg">
                    <img src="img/titul1.png">
                    <img src="img/budapest.jpg">
                </div>
            """)(serialized_model)

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="body">
                <table class="intro">
                    <tr class="row-1">
                        <td class="cell-a1"></td>
                        <td class="cell-a2">
                            <div>
                                <h2>Nejlepší časy</h2>
                                <table></table>
                            </div>
                        </td>
                    </tr>
                    <tr class="row-2">
                        <td class="cell-b1">
                            <div>
                                <h1>Chceš začít novou hru?</h1>
                                <h3>Stiskni kterékoliv tlačítko na panelu</h3>
                            </div>
                        </td>
                        <td class="cell-b2">
                            <img src="svg/logo.svg">
                        </td>
                    </tr>
                </table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-c');

        regions:
            slideshow: '.cell-a1'
            top: '.cell-a2 div table'

    # --- herr director

    handler = () ->
        $('.fadein :first-child').fadeOut().next('img').fadeIn().end().appendTo('.fadein')

    # --- module

    Mod.onStart = (options) ->
        console.log 'Intro module'
        console.log options
        _options = options
        window.channel.trigger('intro:rainbow')

        layout = new ScreenLayout({el: make_content_wrapper()})
        layout.render()
        layout.getRegion('slideshow').show(new Slideshow())

        $('.fadein img:gt(0)').hide()

        results = new Results
        layout.getRegion('top').show new HighScoreView
            collection: results
        results.fetch()

        window.channel.on 'keypress', () ->
            window.sfx.button.play()
            window.channel.trigger('intro:close', options)

        set_timer(handler, _options.options.INTRO_TIME_PER_SCREEN)

    Mod.onStop = () ->
        window.channel.trigger('intro:blank')
        clear_timer()
        window.channel.off('keypress')
        layout.destroy()

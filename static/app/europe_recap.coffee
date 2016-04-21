# Screen #8, Recap / Rekapitulace
#

App.module "Recap", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined
    layout = undefined
    height = undefined

    # --- models & collections

    Question = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: null
            question: null
            image: null
            country: null
            category: null
            answer: null
            image_css_recap: null

    Questions = Backbone.Collection.extend
        model: Question

    # --- views

    InfoView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h1><img src='<%= icon %>'><%= category %></h1>
                <h2><%= difficulty %></h2>
            """)(serialized_model)

    RecapItemView = Marionette.ItemView.extend
        tagName: "div"
        className: ->
            if @model.get('answer')
                out = "good"
            else
                out = "bad"
            "recap #{ out }"
        attributes: ->
            out = 
                style: "height:#{height}px"
            out
        template: (serialized_model) ->
            if serialized_model.image and serialized_model.question
                _.template("""
                    <table class="text" style="height:#{height}px;width:50%">
                        <tr>
                            <td><%= shorten_question(50) %></td>
                        </tr>
                        <tr>
                            <td><%= country.title %></td>
                        </tr>
                    </table>
                    <div style="height:#{height}px;" class="img"><img style="<%= image_css_recap %>" src="<%= image %>" /></div>
                """)(serialized_model)
            else if serialized_model.image
                _.template("""
                    <table class="text" style="height:#{height}px;width:50%">
                        <tr>
                            <td style="vertical-align:middle"><%= country.title %></td>
                        </tr>
                    </table>
                    <div style="height:#{height}px;" class="img"><img style="<%= image_css_recap %>" src="<%= image %>" /></div>
                """)(serialized_model)
            else
                if serialized_model.country.title == serialized_model.question
                    _.template("""
                        <table class="text" style="height:#{height}px;width:100%">
                            <tr>
                                <td style="vertical-align:middle;font-weight:900"><%= country.title %></td>
                            </tr>
                        </table>
                    """)(serialized_model)
                else
                    _.template("""
                        <table class="text" style="height:#{height}px;width:100%">
                            <tr>
                                <td><%= shorten_question(90) %></td>
                            </tr>
                            <tr>
                                <td><%= country.title %></td>
                            </tr>
                        </table>
                    """)(serialized_model)
        templateHelpers: ->
            shorten_question: (length)->
                shorten(@question, length)

    BlankView = Marionette.ItemView.extend
        template: "<p>Nahrávám...</p>"

    RecapView = Marionette.CollectionView.extend
        childView: RecapItemView
        emptyView: BlankView

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header"></div>
            <div id="body"></div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-a');

        regions:
            info: '#header'
            recap: '#body'

    # --- timer handler

    handler = () ->
        window.channel.trigger('recap:close', _options)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Recap module'
        console.log options
        _options = options

        # calculate optimal height of row according to number of answers
        height = calc_optimal_height(Math.ceil(options.answers.length / 2), 20)

        layout = new ScreenLayout
            el: make_content_wrapper()
        layout.render()

        questions = new Questions options.questions, 
            category: options.gamemode.category
            difficulty: options.gamemode.difficulty

        # set views in regions
        info = new Backbone.Model
            category: options.gamemode.title
            icon: options.gamemode.category_icon
            difficulty: options.gamemode.difficulty_title
        layout.getRegion('info').show new InfoView
            model: info

        layout.getRegion('recap').show new RecapView
            collection: questions

        # fetch collection results from server
        # results.fetch()

        # set handler on buttons
        window.channel.on 'key', (msg) ->
            set_new_timeout = true

            if msg == 'fire' or msg == 'left' or msg == 'right'
                window.sfx.button2.play()
                set_delay () ->
                    window.channel.trigger('recap:close', _options)
                , 100
                set_new_timeout = false
            else
                set_new_timeout = false

            if set_new_timeout
                window.sfx.button.play()
                set_delay(handler, _options.options.IDLE_RECAP)

        # idle
        set_delay(handler, _options.options.IDLE_RECAP)


    Mod.onStop = () ->
        window.channel.off('key')
        clear_delay()
        layout.destroy()
        layout = undefined

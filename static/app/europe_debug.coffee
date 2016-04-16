# Debug screen
#
# This screen was used during hardware completation. Each pass of gate is
# recorded and visualized. Keys left/right reset screen, key OK will return
# you to intro screen and discard ?debug option in URL (so game starts in 
# normal mode)

App.module "Debug", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    _options = undefined
    layout = undefined
    country = undefined

    # --- models & collections

    Country = Backbone.Model.extend
        defaults:
            title: ''
            board: ''
            gate: ''
            led: ''
            active: false

    Countries = Backbone.Collection.extend
        model: Country
        comparator: 'title'
        url: '/api/countries'

        parse: (response, options) ->
            response.results

        initialize: () ->
            that = @
            window.channel.on 'tunnel', (event) ->
                passed = that.find (model) ->
                    "#{model.get('board')}" of event and event["#{model.get('board')}"] & model.get('gate')
                if passed
                    passed.set('active', true )
                    country.set({
                        title: passed.get('title')
                        board: passed.get('board')
                        gate: passed.get('gate')
                        led: passed.get('led')
                    })
                    window.channel.trigger('game:goodblink', [passed.led])

    # --- views                                  
                                                
    HeaderView = Marionette.ItemView.extend      
        tagName: "div"
        template: (serialized_model) ->
            if serialized_model.title
                _.template("<h1><%= title %></h1><h2>board=<%= board %>, gate=<%= gate %>, led=<%= led %></h2>")(serialized_model)
            else
                ''
        initialize: () ->
            @model.on 'change', () =>
                @render()
        onDestroy: () ->
            @model.off('change')
        onDomRefresh: () ->
            window.setTimeout ()->
                $('#header-debug').addClass('zmena')
                window.setTimeout ()->
                    $('#header-debug').removeClass('zmena')
                , 500
            , 100

    CountryView = Marionette.ItemView.extend
        tagName: "div"
        className: ->
            "button button-1-4"
        template: (serialized_model) ->
            _.template("<p><%= title %> <span>board=<%= board %>, gate=<%= gate %>, led=<%= led %></span></p>")(serialized_model)
        initialize: () ->
            @model.on 'change', () =>
                @render()
        onRender: () ->
            if @model.get('active')
                @$el.addClass('active')
            else
                @$el.removeClass('active')
        onDestroy: () ->
            @model.off('change')

    CountriesView = Marionette.CollectionView.extend
        tagName: 'td'
        childView: CountryView

    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header-debug">
            </div>
            <div id="body">
                <table class="debug">
                    <tr class="row-2">
                    </tr>
                </table>
            </div>
        """
        regions:
            country: '#header-debug'
            countries: '#body .row-2'

    # --- module

    Mod.onStart = (options) ->
        console.log 'Debug module'
        console.log options
        _options = options

        layout = new ScreenLayout
            el: make_content_wrapper()
        layout.render()

        countries = new Countries
        window.countries = countries
        country = new Country()

        layout.getRegion('country').show new HeaderView
            model: country
        layout.getRegion('countries').show new CountriesView
            collection: countries

        window.channel.on 'key', (msg) ->
            if msg == 'left' or msg == 'right'
                countries.each (model) ->
                    model.set('active', false)
                country.set('title', '')
            if msg == 'fire'
                set_delay () ->
                    window.channel.trigger('debug:close', _options)
                , 100

        countries.fetch()

    Mod.onStop = () ->
        window.channel.off('tunnel')
        layout.destroy()

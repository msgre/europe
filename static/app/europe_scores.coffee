# Screen #?, browsable scores
#
# TODO:
# - nacist kategorie
# - zobrazit vysledky prvni z nich
# - zavesit se na vlevo/vpravo, cyklovat po kategoriich
# - v idealnim pripade cachovat vysledky, aby se pri dalsim prujezdu braly z cache
#   - neni ale nutne
# - dlooouhy timeout, po kterem se vrati na zacatek
# - fire vraci na crossroad
# - staticky text (listuj vlevo/vpravo)
# - mozna prehled kategorii a nad kterou je?

App.module "Scores", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    _options = undefined
    categories = undefined
    DIFFICULTY_EASY = 'E'
    DIFFICULTY_HARD = 'H'

    # --- models & collections

    Result = Backbone.Model.extend
        defaults:
            name: undefined
            time: undefined
            category: undefined

    Results = Backbone.Collection.extend
        model: Result
        initialize: (category, difficulty) ->
            @url = "/api/results/#{ category }?difficulty=#{ difficulty }"
        parse: (response, options) ->
            response.results

    Category = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: undefined
            title: undefined
            active: false
            order: undefined

    Categories = Backbone.Collection.extend
        model: Category
        comparator: 'order'
        url: '/api/categories'

        parse: (response, options) ->
            response.results

        set_active: (index) ->
            if @length < 1
                return
            if not index or index < 0 or index >= @length
                index = 0
            obj = @at(index)
            if obj != undefined
                @each (i) ->
                    if i.get('active')
                        i.set('active', false)
                obj.set('active', true)
            @trigger('change')
            index

    # --- views

    TitleView = Marionette.ItemView.extend
        tagName: "h3"
        template: (serialized_model) ->
            _.template("Kategorie <%= title %>")(serialized_model)

    CategoryResultItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("""
                <td><%= name %></td>
                <td class="text-right"><%= show_time() %></td>""")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    CategoryResultView = Marionette.CollectionView.extend
        childView: CategoryResultItemView
        tagName: 'table'
        className: 'table'

        initialize: (options) ->
            @collection.on 'sync', () =>
                @render()

        onDestroy: () ->
            @collection.off('sync')

    ScoreLayout = Marionette.LayoutView.extend
        template: _.template """
            <div class="row">
                <div class="col-md-12">
                    <h3 id="title"></h3>
                </div>

                <div class="col-md-6">
                    <h3>Malá obtížnost</h3>
                    <div id="easy-results"></div>
                </div>
                <div class="col-md-1"></div>
                <div class="col-md-5">
                    <h3>Velká obtížnost</h3>
                    <div id="hard-results"></div>
                </div>
                <div class="col-md-12">
                    <p>Nápověda: zmáčkni vlevo/vpravo pro zobrazení dalších kategorií s výsledkama, OK pro návrat</p>
                </div>
            </div>
        """

        regions:
            title: '#title'
            easy:  '#easy-results'
            hard:  '#hard-results'

    # --- timer handler

    # TODO:
    # handler = () ->
    #     window.channel.command('gamemode:idle', _options)

    # --- module

    Mod.onStart = (options) ->
        _options = options

        categories = new Categories()
        categories.fetch()
        categories.on 'sync', () ->

            result = categories.at(0)
            easy_results = new Results(result.get('id'), DIFFICULTY_EASY)
            hard_results = new Results(result.get('id'), DIFFICULTY_HARD)

            title_view = new TitleView
                model: result
            easy_view = new CategoryResultView
                collection: easy_results
            hard_view = new CategoryResultView
                collection: hard_results

            layout = new ScoreLayout
                el: make_content_wrapper()
            layout.render()

            layout.getRegion('title').show(title_view)
            layout.getRegion('easy').show(easy_view)
            layout.getRegion('hard').show(hard_view)

            easy_results.fetch()
            hard_results.fetch()

            #set_delay(handler, IDLE_TIMEOUT)

    Mod.onStop = () ->
        clear_delay()
        view.destroy()

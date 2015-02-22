# Obrazovka c.2
#
# Vyber kategorie (jaky typ hry se bude hrat, otazky se vybiraji prave
# podle kategorie).


# ============================================================================

App = new Marionette.Application()

# ============================================================================


App.module "Categories", (Mod, App, Backbone, Marionette, $, _) ->

    # casovac ----------------------------------------------------------------

    Mod.timer_id = undefined
    Mod.timer_delay = 60        # pocet vterin, po kterych se faze vyberu kategorie ukonci (a vrati na uvodni obrazovku)

    Mod.timer_fn = () ->
        console.log 'Ted by se vratila hra na obrazovku #1'
        # TODO: asi nejake vyslani signalu
        # TODO: soucasti jeho obsluhy musi byt unload tohoto modulu

    Mod.clear_timer = () ->
        if Mod.timer_fn != undefined
            window.clearTimeout(Mod.timer_id)

    Mod.set_timer = () ->
        Mod.clear_timer()
        Mod.timer_id = window.setTimeout(Mod.timer_fn, Mod.timer_delay * 1000)


    # modely a kolekce -------------------------------------------------------

    Mod.Category = Backbone.Model.extend
        idAttribute: 'id'
        defaults:
            id: undefined
            title: undefined
            active: false

    Mod.Categories = Backbone.Collection.extend
        model: Mod.Category
        comparator: 'title'
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


    # views ------------------------------------------------------------------

    Mod.CategoryItemView = Marionette.ItemView.extend
        tagName: "tr"
        template: (serialized_model) ->
            _.template("<td><% if (active) {%> █&nbsp;<% } %></td><td><%= title %></td>")(serialized_model)

    Mod.CategoriesView = Marionette.CollectionView.extend
        childView: Mod.CategoryItemView
        el: '#categories'

        initialize: (options) ->
            @index = 0
            that = @

            @collection.on 'sync', () =>
                that.index = @collection.set_active(that.index)
                @render()

            @collection.on 'change', () =>
                @render()

            window.main_channel.commands.setHandler 'main', (msg) ->
                old_index = that.index
                clear_timeout = true

                if msg == 'key-up' and that.index > 0
                    that.index -= 1
                else if msg == 'key-down' and that.index < that.collection.length - 1
                    that.index += 1
                else if msg == 'key-fire'
                    obj = that.collection.at(that.index)
                    console.log "Ted sis vybral kategorii #{ obj.get('title') } (ID=#{ obj.get('id') })"
                else
                    clear_timeout = false

                if clear_timeout
                    Mod.set_timer()

                if old_index != that.index
                    that.collection.set_active(that.index)


# --- inicializace aplikace

App.addInitializer (options) ->

    # modul
    Categories = App.module("Categories")

    # data pro obrazovku
    categories = new Categories.Categories()
    categories_view = new Categories.CategoriesView({collection: categories})
    categories.fetch()

    # spusteni casovace pro vyber kategorie
    Categories.set_timer()


App.start()

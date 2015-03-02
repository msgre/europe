window.channel = Backbone.Radio.channel('main')

make_wrapper = () ->
    el = $('#content').append('<div></div>')
    el.find('div')

# -- aplikace

App = new Marionette.Application()

App.on 'start', () ->
    console.log 'App start'
    mb = @module("ModuleB")

    active_module = null
    that = @

    window.channel.comply 'ma', (options) ->
        console.log 'command **ma**'
        console.log options

        if active_module != null
            active_module.stop()

        active_module = that.module("ModuleA")
        el = make_wrapper()
        active_module.start({el: el})

    window.channel.comply 'mb', (options) ->
        console.log 'command **mb**'
        console.log options

        if active_module != null
            active_module.stop()

        active_module = that.module("ModuleB")
        el = make_wrapper()
        active_module.start({el: el})


# -- moduly

App.module "ModuleA", (Mod, App, Backbone, Marionette, $, _) ->
    Mod.startWithParent = false

    AppLayoutView = Backbone.Marionette.LayoutView.extend
        template: (serialized_model) ->
            _.template('<div id="block1"></div><div id="block2"></div>')(serialized_model)
        regions:
            block1: "#block1"
            block2: "#block2"

    Block1View = Backbone.Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<h1><span style=\"color:red\">A:</span> Toto je Block1View</h1>")(serialized_model)

        onDestroy: () ->
            console.log 'ModuleA Block1View destroy'

    Block2View = Backbone.Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<h1><span style=\"color:red\">A:</span> Toto je Block2View</h1>")(serialized_model)

        onDestroy: () ->
            console.log 'ModuleA Block2View destroy'

    Mod.onBeforeStart = () ->
        console.log 'ModuleA beforeStart'

    Mod.onStart = (options) ->
        console.log 'ModuleA start'
        console.log options
        @layout = new AppLayoutView({el: options.el})
        @layout.render()
        @layout.getRegion('block1').show(new Block1View())
        @layout.getRegion('block2').show(new Block2View())

    Mod.onStop = () ->
        console.log 'ModuleA stop'
        @layout.destroy()


App.module "ModuleB", (Mod, App, Backbone, Marionette, $, _) ->
    Mod.startWithParent = false

    AppLayoutView = Backbone.Marionette.LayoutView.extend
        template: (serialized_model) ->
            _.template('<div id="block1"></div><div id="block2"></div>')(serialized_model)
        regions:
            block1: "#block1"
            block2: "#block2"

    Block1View = Backbone.Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<h1><span style=\"color:green\">B:</span> Toto je Block1View</h1>")(serialized_model)

    Block2View = Backbone.Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<h1><span style=\"color:green\">B:</span> Toto je Block2View</h1>")(serialized_model)

    Mod.onBeforeStart = () ->
        console.log 'ModuleB beforeStart'

    Mod.onStart = (options) ->
        console.log 'ModuleB start'
        @layout = new AppLayoutView({el: options.el})
        @layout.render()
        console.log $('#content').length

        @layout.getRegion('block1').show(new Block1View())
        @layout.getRegion('block2').show(new Block2View())

    Mod.onStop = () ->
        console.log 'ModuleB stop'
        @layout.destroy()

# -- start

App.start()

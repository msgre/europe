# Screen #5, results
#

App.module "Result", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    IDLE_DELAY = 10000
    NAME_MAX_LENGTH = 16
    LETTERS = 'ABCDEFGHIJKLMNOPRSTUVWXYZ 0123456789-._*?!#:()←✔'
    LETTER_BACKSPACE = '←'
    LETTER_ENTER = '✔'
    _options = undefined
    time = undefined
    rank = undefined
    name = undefined
    layout = undefined

    # --- utils

    format_results = (data) ->
        answers = data.answers.map (i) ->
            "#{ i.id }:#{ i.answer }"
        out =
            category: data.category.id
            name: null                      # TODO: zatim bez jmena
            time: data.time
            answers: answers.join(',')

    # --- models & collections

    Time = Backbone.Model.extend
        defaults:
            time: undefined

    Rank = Backbone.Model.extend
        defaults:
            position: undefined
            total: undefined
            top: undefined
            category_position: undefined
            category_total: undefined
            category_top: undefined
        initialize: (category_id, time) ->
            @url = "/api/results/#{ category_id }/#{ time }"

    Name = Backbone.Model.extend
        defaults:
            name: ''
            letter: 'A'

    # --- views

    GreatTimeView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h3>Nový rekord!</h3>
                <h1><%= show_time() %></h1>
            """)(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    BadTimeView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h3>Váš čas</h3>
                <h1><%= show_time() %></h1>
                <br>
                <p>Zmáčkni kterékoliv tlačítko pro pokračování.</p>
            """)(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)
        initialize: () ->
            window.channel.on 'keypress', (msg) ->
                window.channel.command('result:save', null)
        onDestroy: () ->
            window.channel.off('keypress')

    TypewriterView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <p>Tvůj čas se dostal do žebříčku! Zadej jméno svého týmu:</p>
                <h1><span><%= name %></span><span style="background:#000;color:#fff;padding-left:.1em;padding-right:.1em"><%= letter %></span></h1>
                <p><%= show_alphabet() %></p>
                <p><em>Tlačítky nahoru/dolů vybírej písmena, tlačítkem OK vyber konkrétní znak.<br/>Symbolem #{ LETTER_BACKSPACE } smažeš předchozí znak, symbolem #{ LETTER_ENTER } jméno uložíš.<br/>Délka jména maximálně #{ NAME_MAX_LENGTH } znaků.</em></p>
            """)(serialized_model)
        templateHelpers: ->
            show_alphabet: ->
                index = LETTERS.indexOf(@letter)
                "#{ LETTERS.substring(0, index) }<span style=\"background:#000;color:#fff;\">#{@letter}</span>#{ LETTERS.substring(index+1) }"
        initialize: () ->
            that = @
            @model.on 'change', () ->
                that.render()

            window.channel.on 'key', (msg) ->
                clear_delay()

                letter = that.model.get('letter')
                index = LETTERS.indexOf(letter)
                _name = that.model.get('name')

                if msg == 'up' and index > 0
                    index -= 1
                    that.model.set('letter', LETTERS[index])
                else if msg == 'down' and index < (LETTERS.length - 1)
                    index += 1
                    that.model.set('letter', LETTERS[index])
                else if msg == 'fire'
                    if letter == LETTER_BACKSPACE and _name.length > 0
                        that.model.set('name', _name.substring(0, _name.length - 1))
                    else if letter == LETTER_ENTER and _name.length > 0
                        window.channel.command('result:save', _name)
                    else if _name.length < NAME_MAX_LENGTH
                        that.model.set('name', "#{ _name }#{ letter }")
                        if that.model.get('name').length == NAME_MAX_LENGTH
                            window.channel.command('result:save', _name)

                set_delay(handler, IDLE_DELAY)

        onDestroy: () ->
            window.channel.off('key')
            @model.off('change')


    ResultLayout = Marionette.LayoutView.extend
        template: _.template """
            <div class="row">
                <div class="col-md-12" id="time">
                </div>
            </div>
            <div class="row">
                <div class="col-md-12" id="typewriter">
                </div>
            </div>
            <div class="row">
                <div class="col-md-12" id="score">
                </div>
            </div>
        """

        regions:
            time: '#time'
            typewriter: '#typewriter'
            score: '#score'

    # --- timer handler

    handler = () ->
        _name = name.get('name')
        if _name.length < 1
            _name = null
        window.channel.command('result:save', _name)

    # --- module

    Mod.onStart = (options) ->
        _options = options

        # put results data into models
        time = new Time({time: options.time})
        rank = new Rank(options.category.id, options.time)
        name = new Name()

        # render basic layout
        layout = new ResultLayout
            el: make_content_wrapper()
        layout.render()

        # get rank of player score from server
        rank.on 'sync', () ->
            #if rank.get('top') or rank.get('category_top')
            if 1
                layout.getRegion('time').show(new GreatTimeView({model: time}))
                layout.getRegion('typewriter').show(new TypewriterView({model: name}))
            else
                layout.getRegion('time').show(new BadTimeView({model: time}))

        # save results to server
        window.channel.comply 'result:save', (_name) ->
            clear_delay()
            # TODO: tohle chybi udelat -- odeslani dat na server
            # a jakmile to bude tak zavolat close
            # return hodnota by mohla obsahovat alespon ID zaznamu, at to na dalsi obrazovce muzu v tabulce zvyraznit...
            console.log 'ulozeni dat'
            console.log _options
            console.log _name
            window.channel.command('result:close')

        set_delay(handler, IDLE_DELAY)

        # run!
        rank.fetch()

    Mod.onStop = () ->
        clear_delay()
        time = undefined
        rank = undefined
        layout.destroy()
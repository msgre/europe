# Screen #7, Result / Vysledek, Zadani jmena
#

App.module "Result", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    NAME_MAX_LENGTH = 16
    LETTERS = 'ABCDEFGHIJKLMNOPRSTUVWXYZ 0123456789←✔'
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
        initialize: (attributes, options) ->
            @url = "/api/results/#{ options.difficulty }-#{ options.category }/#{ options.time }"

    Name = Backbone.Model.extend
        defaults:
            name: ''
            letter: 'A'

    Score = Backbone.Model.extend
        defaults:
            name: undefined
            time: undefined
            category: undefined
            difficulty: undefined
            questions: undefined
        url: '/api/score'

    # --- views

    InfoView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h1><img src='<%= icon %>'><%= category %></h1>
                <h2><%= difficulty %></h2>
            """)(serialized_model)

    GreatTimeView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<%= show_time() %>")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    # TODO: pro obrazovku se spatnym casem nemame obrazovku!
    BadTimeView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<%= show_time() %>")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)
        initialize: () ->
            window.channel.on 'keypress', (msg) ->
                window.channel.command('result:save', null)
        onDestroy: () ->
            window.channel.off('keypress')

    TypewriterView1 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <%= show_name() %><span class="selected"><%= letter %></span><%= show_empty() %>
            """)(serialized_model)
        templateHelpers: ->
            show_name: ->
                out = ""
                for i in [0...@name.length]
                    out += "<span class='chosen'>#{ @name.charAt(i) }</span>"
                out
            show_empty: ->
                rest = NAME_MAX_LENGTH - @name.length
                out = ""
                if rest > 1
                    for i in [1...rest]
                        out += "<span class='empty'>␣</span>"
                out
        initialize: () ->
            console.log 'TypewriterView1'
            that = @
            @model.on 'change', () ->
                that.render()

            window.channel.on 'key', (msg) ->
                clear_delay()

                if msg == 'fire'
                    window.sfx.button2.play()
                    letter = that.model.get('letter')
                    _name = that.model.get('name')

                    if letter == LETTER_BACKSPACE
                        if _name.length > 0
                            that.model.set('name', _name.substring(0, _name.length - 1))
                    else if letter == LETTER_ENTER
                        if _name.length > 0
                            window.channel.command('result:save', _name)
                            return
                    else if _name.length < NAME_MAX_LENGTH
                        that.model.set('name', "#{ _name }#{ letter }")
                        _name = that.model.get('name')
                        if _name.length == NAME_MAX_LENGTH
                            window.channel.command('result:save', _name)
                            return

                set_delay(handler, _options.options.IDLE_RESULT)

        onDestroy: () ->
            window.channel.off('key')
            @model.off('change')


    TypewriterView2 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<%= show_alphabet() %>")(serialized_model)
        templateHelpers: ->
            show_alphabet: ->
                index = LETTERS.indexOf(@letter)
                "#{ LETTERS.substring(0, index) }<span class='selected'>#{@letter}</span>#{ LETTERS.substring(index+1) }"
        initialize: () ->
            console.log 'TypewriterView2'
            that = @
            @model.on 'change', () ->
                that.render()

            window.channel.on 'key', (msg) ->
                clear_delay()

                letter = that.model.get('letter')
                index = LETTERS.indexOf(letter)

                if msg == 'left' and index > 0
                    window.sfx.button.play()
                    index -= 1
                    that.model.set('letter', LETTERS[index])
                else if msg == 'right' and index < (LETTERS.length - 1)
                    window.sfx.button.play()
                    index += 1
                    that.model.set('letter', LETTERS[index])

                set_delay(handler, _options.options.IDLE_RESULT)

        onDestroy: () ->
            window.channel.off('key')
            @model.off('change')


    ScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header"></div>
            <div id="body">
                <table class="result">
                    <tr class="row-1">
                        <td colspan="2">
                            <h1>Nový rekord!</h1>
                            <h2></h2>
                            <p>Tvůj čas se dostal do žebříčku. Zadej jméno svého týmu.</p>
                        </td>
                    </tr>
                    <tr class="row-2">
                        <td class="typewriter"></td>
                        <td class="help" rowspan="2">
                            <div>
                                <p>Tlačítky nahoru/dolů vybírej písmena,
                                tlačítkem OK vyber konkrétní znak.<br/>Symbolem
                                #{ LETTER_BACKSPACE } smažeš předchozí znak,
                                symbolem #{ LETTER_ENTER } jméno
                                uložíš.<br/>Délka jména maximálně 
                                #{ NAME_MAX_LENGTH } znaků.</p>
                            </div>
                        </td>
                    </tr>
                    <tr class="row-3">
                        <td colspan="2"></td>
                    </tr>
                </table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-a');

        regions:
            info: '#header'
            time: '#body .row-1 h2'
            input: '.row-2 .typewriter'
            alphabet: '.row-3 td'

    # --- timer handler

    handler = () ->
        _name = name.get('name')
        if _name.length < 1
            _name = null
        window.channel.command('result:save', _name)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Result module'
        console.log options
        _options = options
        window.sfx.surprise.play()

        # put results data into models
        time = new Time({time: options.time})
        rank = new Rank null, 
            difficulty: options.gamemode.difficulty
            category: options.gamemode.category
            time: options.time
        name = new Name()

        # render basic layout
        layout = new ScreenLayout
            el: make_content_wrapper()
        layout.render()
        layout.getRegion('info').show(new InfoView({model: new Backbone.Model({'category': options.gamemode.title, 'icon': options.gamemode.category_icon, 'difficulty': options.gamemode.difficulty_title})}))

        # get rank of player score from server
        rank.on 'sync', () ->
            if rank.get('top')
                layout.getRegion('time').show(new GreatTimeView({model: time}))
                layout.getRegion('input').show(new TypewriterView1({model: name}))
                layout.getRegion('alphabet').show(new TypewriterView2({model: name}))
            else
                layout.getRegion('time').show(new BadTimeView({model: time}))

        # save results to server
        window.channel.comply 'result:save', (_name) ->
            clear_delay()
            questions = _.map _options.answers, (i) ->
                {question: i.id, correct: i.answer}
            score = new Score
                name: _name
                time: _options.time
                category: _options.gamemode.category
                difficulty: _options.gamemode.difficulty
                questions: questions
            score.save()
            score.on 'sync', () ->
                window.channel.command('result:close', _options)
                score.off('sync')

        set_delay(handler, _options.options.IDLE_RESULT)

        # run!
        rank.fetch()

    Mod.onStop = () ->
        clear_delay()
        time = undefined
        rank = undefined
        score = undefined
        layout.destroy()

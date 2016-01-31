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
            questions: undefined
        url: '/api/score'

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
                <div class="row">
                    <div class="col-md-3">&nbsp;</div>
                    <div class="col-md-6 text-left">
                        <h1><span><%= name %></span><span style="background:#000;color:#fff;padding-left:.1em;padding-right:.1em"><%= letter %></span><span style="color:#ccc"><%= show_empty() %></span></h1>
                    </div>
                    <div class="col-md-3">&nbsp;</div>
                </div>
                <p><%= show_alphabet() %></p>
                <p><em>Tlačítky nahoru/dolů vybírej písmena, tlačítkem OK vyber konkrétní znak.<br/>Symbolem #{ LETTER_BACKSPACE } smažeš předchozí znak, symbolem #{ LETTER_ENTER } jméno uložíš.<br/>Délka jména maximálně #{ NAME_MAX_LENGTH } znaků.</em></p>
            """)(serialized_model)
        templateHelpers: ->
            show_alphabet: ->
                index = LETTERS.indexOf(@letter)
                "#{ LETTERS.substring(0, index) }<span style=\"background:#000;color:#fff;\">#{@letter}</span>#{ LETTERS.substring(index+1) }"
            show_empty: ->
                rest = NAME_MAX_LENGTH - @name.length
                out = ""
                if rest > 1
                    for i in [1...rest]
                        out += "␣"
                out
        initialize: () ->
            that = @
            @model.on 'change', () ->
                that.render()

            window.channel.on 'key', (msg) ->
                clear_delay()

                letter = that.model.get('letter')
                index = LETTERS.indexOf(letter)
                _name = that.model.get('name')

                if msg == 'left' and index > 0
                    window.sfx.button.play()
                    index -= 1
                    that.model.set('letter', LETTERS[index])
                else if msg == 'right' and index < (LETTERS.length - 1)
                    window.sfx.button.play()
                    index += 1
                    that.model.set('letter', LETTERS[index])
                else if msg == 'fire'
                    window.sfx.button2.play()
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
        layout = new ResultLayout
            el: make_content_wrapper()
        layout.render()

        # get rank of player score from server
        rank.on 'sync', () ->
            if rank.get('top')
                layout.getRegion('time').show(new GreatTimeView({model: time}))
                layout.getRegion('typewriter').show(new TypewriterView({model: name}))
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
                window.channel.command('result:close', _options) # TODO: asi bych mel do _options jeste neco pridat
                score.off('sync')

        set_delay(handler, IDLE_DELAY)

        # run!
        rank.fetch()

    Mod.onStop = () ->
        clear_delay()
        time = undefined
        rank = undefined
        score = undefined
        layout.destroy()

# Screen #7, Result / Vysledek, Zadani jmena
#

App.module "Result", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    NAME_MAX_LENGTH = 20 + 1
    LETTER_BACKSPACE = '←'
    LETTER_ENTER = '✔'

    LETTERS = [
        {key:'A', value:'A'},
        {key:'Á', value:'Á'},
        {key:'B', value:'B'},
        {key:'C', value:'C'},
        {key:'Č', value:'Č'},
        {key:'D', value:'D'},
        {key:'Ď', value:'Ď'},
        {key:'E', value:'E'},
        {key:'É', value:'É'},
        {key:'Ě', value:'Ě'},
        {key:'F', value:'F'},
        {key:'G', value:'G'},
        {key:'H', value:'H'},
        {key:'I', value:'I'},
        {key:'Í', value:'Í'},
        {key:'J', value:'J'},
        {key:'K', value:'K'},
        {key:'L', value:'L'},
        {key:'M', value:'M'},
        {key:'N', value:'N'},
        {key:'Ň', value:'Ň'},
        {key:'O', value:'O'},
        {key:'Ó', value:'Ó'},
        {key:'P', value:'P'},
        {key:'Q', value:'Q'},
        {key:'R', value:'R'},
        {key:'Ř', value:'Ř'},
        {key:'S', value:'S'},
        {key:'Š', value:'Š'},
        {key:'T', value:'T'},
        {key:'Ť', value:'Ť'},
        {key:'U', value:'U'},
        {key:'Ú', value:'Ú'},
        {key:'Ů', value:'Ů'},
        {key:'V', value:'V'},
        {key:'W', value:'W'},
        {key:'X', value:'X'},
        {key:'Y', value:'Y'},
        {key:'Ý', value:'Ý'},
        {key:'Z', value:'Z'},
        {key:'Ž', value:'Ž'},
        {key:' ', value:'&nbsp;'},
        {key:'0', value:'0'},
        {key:'1', value:'1'},
        {key:'2', value:'2'},
        {key:'3', value:'3'},
        {key:'4', value:'4'},
        {key:'5', value:'5'},
        {key:'6', value:'6'},
        {key:'7', value:'7'},
        {key:'8', value:'8'},
        {key:'9', value:'9'},
        {key:LETTER_BACKSPACE, value:SVG.delete},
        {key:LETTER_ENTER, value:SVG.check},
    ]
            
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
            name: null
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
            @url = "/api/results/#{ options.difficulty }-#{ options.category }/#{ options.time }/#{ options.correct }"

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

    BadTimeView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<%= show_time() %>")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)
        initialize: () ->
            window.channel.on 'keypress', (msg) ->
                window.channel.trigger('result:save', null)
        onDestroy: () ->
            window.channel.off('keypress')

    TypewriterView1 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <table><tr><%= show_name() %><td class="selected"><%= show_letter() %></td><%= show_empty() %></tr></table>
            """)(serialized_model)
        templateHelpers: ->
            show_letter: ->
                x = _.filter LETTERS, (i) =>
                    i.key == @letter
                x[0].value
            show_name: ->
                out = ""
                for i in [0...@name.length]
                    out += "<td>#{ @name.charAt(i) }</td>"
                out
            show_empty: ->
                rest = NAME_MAX_LENGTH - @name.length
                out = ""
                if rest > 1
                    for i in [1...rest]
                        out += "<td class='empty'>#{SVG.space}</td>"
                out
        initialize: () ->
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
                            window.channel.trigger('result:save', _name)
                            return
                    else if _name.length < NAME_MAX_LENGTH - 1
                        that.model.set('name', "#{ _name }#{ letter }")
                        _name = that.model.get('name')

                set_delay(handler, _options.options.IDLE_RESULT)

        onDestroy: () ->
            window.channel.off('key')
            @model.off('change')


    TypewriterView2 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<table><tr><%= show_alphabet() %></tr></table>")(serialized_model)
        templateHelpers: ->
            show_alphabet: ->
                letter = @letter
                out = ("<td#{ if LETTERS[i].key == letter then ' class=\"selected\"' else '' }>#{LETTERS[i].value}</td>" for i in [0...LETTERS.length])
                out.join('')
        initialize: () ->
            that = @
            @model.on 'change', () ->
                that.render()

            window.channel.on 'key', (msg) ->
                clear_delay()

                letter = that.model.get('letter')
                _temp = LETTERS.map (i) ->
                    i.key == letter
                index = _temp.indexOf(true)

                if msg == 'left'
                    if index > 0
                        index -= 1
                    else
                        index = LETTERS.length - 1
                    window.sfx.button.play()
                    that.model.set('letter', LETTERS[index].key)
                else if msg == 'right'
                    if index < (LETTERS.length - 1)
                        index += 1
                    else
                        index = 0
                    window.sfx.button.play()
                    that.model.set('letter', LETTERS[index].key)

                set_delay(handler, _options.options.IDLE_RESULT)

        onDestroy: () ->
            window.channel.off('key')
            @model.off('change')


    GoodScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header"></div>
            <div id="body">
                <table class="result good-result">
                    <tr class="row-1">
                        <td>
                            <h1>#{SVG.rekord}Nový rekord!</h1>
                            <h2></h2>
                            <p style="text-transform:uppercase;">Tvůj čas se dostal do žebříčku nejlepších. Zadej jméno svého týmu.</p>
                        </td>
                    </tr>
                    <tr class="row-2">
                        <td class="typewriter"></td>
                    </tr>
                    <tr class="row-3">
                        <td></td>
                    </tr>
                    <tr class="row-4">
                        <td>
                            <table class="help">
                                <tr>
                                    <td>#{SVG.left}&nbsp;#{SVG.right}</td>
                                    <td><p>Výběr znaku</p></td>
                                    <td>#{SVG.ok}</td>
                                    <td><p>Potvrzení výběru</p></td>
                                    <td>#{SVG.delete}</td>
                                    <td><p>Mazání znaku</p></td>
                                    <td>#{SVG.check}</td>
                                    <td><p>Uložení jména</p></td>
                                </tr>
                            </table>
                        </td>
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

    BadScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header"></div>
            <div id="body">
                <table class="result bad-result">
                    <tr class="row-1">
                        <td>
                            <h1><img src="svg/rekord.svg" />Dosažený čas</h1>
                            <h2></h2>
                        </td>
                    </tr>
                </table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-a');

        regions:
            info: '#header'
            time: '#body .row-1 h2'

    # --- timer handler

    handler = () ->
        _name = name.get('name')
        if _name.length < 1
            _name = null
        window.channel.trigger('result:save', _name)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Result module'
        console.log options
        _options = options

        # put results data into models
        time = new Time({time: options.time})
        correct = _.filter options.answers, (i) ->
            i.answer
        name = new Name()
        rank = new Rank null, 
            difficulty: options.gamemode.difficulty
            category: options.gamemode.category
            time: options.time
            correct: correct.length
        rank.fetch()
            
        # save results to server
        window.channel.on 'result:save', (_name) ->
            clear_delay()
            questions = _.map _options.answers, (i) ->
                {question: i.id, correct: i.answer}
            score = new Score
                name: _name
                time: _options.time
                category: _options.gamemode.category
                difficulty: _options.gamemode.difficulty
                questions: questions
                top: if _name then true else false
            score.save()
            score.on 'sync', () ->
                window.channel.trigger('result:close', _options)
                score.off('sync')

        # get rank of player score from server
        rank.on 'sync', () ->
            if rank.get('top')
                window.sfx.surprise.play()
                # render basic layout
                layout = new GoodScreenLayout
                    el: make_content_wrapper()
                layout.render()
                layout.getRegion('info').show(new InfoView({model: new Backbone.Model({'category': options.gamemode.title, 'icon': options.gamemode.category_icon, 'difficulty': options.gamemode.difficulty_title})}))

                layout.getRegion('time').show(new GreatTimeView({model: time}))
                layout.getRegion('input').show(new TypewriterView1({model: name}))
                layout.getRegion('alphabet').show(new TypewriterView2({model: name}))
            else
                window.sfx.notsurprise.play()
                # render basic layout
                layout = new BadScreenLayout
                    el: make_content_wrapper()
                layout.render()
                layout.getRegion('info').show(new InfoView({model: new Backbone.Model({'category': options.gamemode.title, 'icon': options.gamemode.category_icon, 'difficulty': options.gamemode.difficulty_title})}))

                layout.getRegion('time').show(new BadTimeView({model: time}))

        set_delay(handler, _options.options.IDLE_RESULT)


    Mod.onStop = () ->
        clear_delay()
        time = undefined
        rank.off('sync')
        rank = undefined
        score = undefined
        layout.destroy()
        window.channel.off('result:save')

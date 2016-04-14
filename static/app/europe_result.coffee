# Screen #7, Result / Vysledek, Zadani jmena
#

App.module "Result", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    NAME_MAX_LENGTH = 16 + 1
    LETTER_BACKSPACE = '←'
    LETTER_ENTER = '✔'
    # TODO: dodat finalni podobu SVG symbolu
    SVG = 
        rekord: '<svg width="80px" height="58px" viewBox="0 0 40 29" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <!-- Generator: Sketch 3.6 (26304) - http://www.bohemiancoding.com/sketch --> <title>rekord</title> <desc>Created with Sketch.</desc> <defs></defs> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <g id="ikony" transform="translate(-1.000000, -1.000000)" fill="#FFFFFF"> <g id="rekord" transform="translate(0.820513, 0.599998)"> <path d="M20.1025641,5.49700405 C13.4292103,5.49700405 8,10.8547773 8,17.4403239 C8,24.0258704 13.4292103,29.3836437 20.1025641,29.3836437 C26.7759179,29.3836437 32.2051282,24.0258704 32.2051282,17.4403239 C32.2051282,10.8547773 26.7759179,5.49700405 20.1025641,5.49700405 L20.1025641,5.49700405 Z M20.1025641,27.9504453 C14.2299159,27.9504453 9.45230769,23.2357004 9.45230769,17.4403239 C9.45230769,11.6449474 14.2299159,6.93020243 20.1025641,6.93020243 C25.9752123,6.93020243 30.7528205,11.6449474 30.7528205,17.4403239 C30.7528205,23.2357004 25.9752123,27.9504453 20.1025641,27.9504453 L20.1025641,27.9504453 Z" id="Shape"></path> <path d="M27.2271015,16.7237247 L20.795799,16.7237247 L20.795799,8.33664777 C20.795799,7.95876113 20.4854892,7.65253441 20.1025641,7.65253441 C19.719639,7.65253441 19.4088451,7.95876113 19.4088451,8.33664777 L19.4088451,17.4403239 C19.4088451,17.6815789 19.5361641,17.8927368 19.7273846,18.0145587 C19.8479262,18.1029393 19.9960615,18.1569231 20.1582359,18.1569231 L27.2271015,18.1569231 C27.6279385,18.1569231 27.9532554,17.8363644 27.9532554,17.4403239 C27.9532554,17.0442834 27.6279385,16.7237247 27.2271015,16.7237247 L27.2271015,16.7237247 Z" id="Shape"></path> <rect id="Rectangle-path" x="18.0054318" y="2.3248583" width="4.19523282" height="2.46796761"></rect> </g> </g> </g> </svg>'
        todo: '<svg width="40px" height="29px" viewBox="0 0 40 29" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <!-- Generator: Sketch 3.6 (26304) - http://www.bohemiancoding.com/sketch --> <title>rekord</title> <desc>Created with Sketch.</desc> <defs></defs> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <g id="ikony" transform="translate(-1.000000, -1.000000)" fill="#000000"> <g id="rekord" transform="translate(0.820513, 0.599998)"> <path d="M20.1025641,5.49700405 C13.4292103,5.49700405 8,10.8547773 8,17.4403239 C8,24.0258704 13.4292103,29.3836437 20.1025641,29.3836437 C26.7759179,29.3836437 32.2051282,24.0258704 32.2051282,17.4403239 C32.2051282,10.8547773 26.7759179,5.49700405 20.1025641,5.49700405 L20.1025641,5.49700405 Z M20.1025641,27.9504453 C14.2299159,27.9504453 9.45230769,23.2357004 9.45230769,17.4403239 C9.45230769,11.6449474 14.2299159,6.93020243 20.1025641,6.93020243 C25.9752123,6.93020243 30.7528205,11.6449474 30.7528205,17.4403239 C30.7528205,23.2357004 25.9752123,27.9504453 20.1025641,27.9504453 L20.1025641,27.9504453 Z" id="Shape"></path> <path d="M27.2271015,16.7237247 L20.795799,16.7237247 L20.795799,8.33664777 C20.795799,7.95876113 20.4854892,7.65253441 20.1025641,7.65253441 C19.719639,7.65253441 19.4088451,7.95876113 19.4088451,8.33664777 L19.4088451,17.4403239 C19.4088451,17.6815789 19.5361641,17.8927368 19.7273846,18.0145587 C19.8479262,18.1029393 19.9960615,18.1569231 20.1582359,18.1569231 L27.2271015,18.1569231 C27.6279385,18.1569231 27.9532554,17.8363644 27.9532554,17.4403239 C27.9532554,17.0442834 27.6279385,16.7237247 27.2271015,16.7237247 L27.2271015,16.7237247 Z" id="Shape"></path> <rect id="Rectangle-path" x="18.0054318" y="2.3248583" width="4.19523282" height="2.46796761"></rect> </g> </g> </g> </svg>'
        delete: '<svg width="25px" height="25px" viewBox="0 0 30 30" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <!-- Generator: Sketch 3.6 (26304) - http://www.bohemiancoding.com/sketch --> <title>Shape</title> <desc>Created with Sketch.</desc> <defs></defs> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <path d="M18.5997584,15.0016544 L28.8016193,4.79850663 C30.1277647,3.47686537 30.3954389,1.59413784 29.4013124,0.600011381 C28.4020384,-0.395401976 26.5251019,-0.122580216 25.2028172,1.20356518 L15.0009563,11.3989916 L4.79845196,1.20292173 C3.47809759,-0.123223663 1.59408317,-0.395401976 0.602530495,0.599367933 C-0.394169757,1.5934944 -0.126495577,3.47686537 1.20222361,4.79786318 L11.4015107,15.001011 L1.20158016,25.1990111 C-0.126495577,26.5264434 -0.394169757,28.4072406 0.601887047,29.4000802 C1.59343972,30.3948501 3.47809759,30.1239587 4.79780851,28.7991002 L15.0009563,18.5978827 L25.2028172,28.7991002 C26.5257453,30.1239587 28.4026818,30.3942066 29.4013124,29.4000802 C30.3954389,28.4072406 30.1277647,26.5264434 28.8016193,25.1990111 L18.5997584,15.0016544 L18.5997584,15.0016544 Z" id="Shape" fill="#000000"></path> </g> </svg>'
        save: '<svg width="33px" height="25px" viewBox="0 0 40 30" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <!-- Generator: Sketch 3.6 (26304) - http://www.bohemiancoding.com/sketch --> <title>Shape</title> <desc>Created with Sketch.</desc> <defs></defs> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <path d="M39.3713362,0.634626715 C38.3163068,-0.417746889 36.316465,-0.131580944 34.9128575,1.27269046 L13.2645033,22.9177248 L5.09516276,14.7457284 C3.68690761,13.341457 1.69171349,13.0526352 0.636684058,14.1070007 C-0.41768142,15.164686 -0.132843391,17.1598801 1.27142801,18.5668073 L11.352304,28.6496752 C11.352304,28.6496752 11.7838768,29.0779282 12.3110595,29.6051109 C12.8389062,30.1316297 13.6947482,30.1316297 14.2232589,29.6051109 L15.1760387,28.6496752 L38.7312806,5.09244146 C40.1395358,3.6875061 40.4257017,1.69164803 39.3713362,0.634626715 L39.3713362,0.634626715 Z" id="Shape" fill="#000000"></path> </g> </svg>'
    LETTERS = [
        {key:'A', value:'A'},
        {key:'B', value:'B'},
        {key:'C', value:'C'},
        {key:'D', value:'D'},
        {key:'E', value:'E'},
        {key:'F', value:'F'},
        {key:'G', value:'G'},
        {key:'H', value:'H'},
        {key:'I', value:'I'},
        {key:'J', value:'J'},
        {key:'K', value:'K'},
        {key:'L', value:'L'},
        {key:'M', value:'M'},
        {key:'N', value:'N'},
        {key:'O', value:'O'},
        {key:'P', value:'P'},
        {key:'Q', value:'Q'},
        {key:'R', value:'R'},
        {key:'S', value:'S'},
        {key:'T', value:'T'},
        {key:'U', value:'U'},
        {key:'V', value:'V'},
        {key:'W', value:'W'},
        {key:'X', value:'X'},
        {key:'Y', value:'Y'},
        {key:'Z', value:'Z'},
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
        {key:LETTER_ENTER, value:SVG.save},
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
                        out += "<td class='empty'>␣</td>"
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

                if msg == 'left' and index > 0
                    window.sfx.button.play()
                    index -= 1
                    that.model.set('letter', LETTERS[index].key)
                else if msg == 'right' and index < (LETTERS.length - 1)
                    window.sfx.button.play()
                    index += 1
                    that.model.set('letter', LETTERS[index].key)

                set_delay(handler, _options.options.IDLE_RESULT)

        onDestroy: () ->
            window.channel.off('key')
            @model.off('change')


    GoodScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header"></div>
            <div id="body">
                <table class="result">
                    <tr class="row-1">
                        <td colspan="2">
                            <h1 style="color:red">#{SVG.rekord}Nový rekord!</h1>
                            <h2></h2>
                            <p>Tvůj čas se dostal do žebříčku. Zadej jméno svého týmu.</p>
                        </td>
                    </tr>
                    <tr class="row-2">
                        <td class="typewriter"></td>
                        <td class="help" rowspan="2">
                            <table>
                                <tr>
                                    <td>#{SVG.todo}#{SVG.todo}</td>
                                    <td><p>Výběr znaku</p></td>
                                </tr>
                                <tr>
                                    <td>#{SVG.todo}</td>
                                    <td><p>Potvrzení výběru</p></td>
                                </tr>
                                <tr>
                                    <td>#{SVG.delete}</td>
                                    <td><p>Mazání znaku</p></td>
                                </tr>
                                <tr>
                                    <td>#{SVG.save}</td>
                                    <td><p>Uložení jména</p></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr class="row-3">
                        <td colspan="2"></td>
                    </tr>
                    <tr class="row-4">
                        <td colspan="2"><p>Délka jména maximálně #{NAME_MAX_LENGTH-1} znaků</p></td>
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
                <table class="result">
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
        window.sfx.surprise.play()

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
                # render basic layout
                layout = new GoodScreenLayout
                    el: make_content_wrapper()
                layout.render()
                layout.getRegion('info').show(new InfoView({model: new Backbone.Model({'category': options.gamemode.title, 'icon': options.gamemode.category_icon, 'difficulty': options.gamemode.difficulty_title})}))

                layout.getRegion('time').show(new GreatTimeView({model: time}))
                layout.getRegion('input').show(new TypewriterView1({model: name}))
                layout.getRegion('alphabet').show(new TypewriterView2({model: name}))
            else
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

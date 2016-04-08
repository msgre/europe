App = new Marionette.Application()


App.on 'start', (global_options) ->
    active_module = null
    that = @
    final_global_options = undefined

    state_handler = (new_module_name, options) ->
        if active_module != null
            active_module.stop()

        active_module = that.module(new_module_name)
        active_module.start(options)

        
    # --- websockety, crossbar.io
    wsuri = "ws://#{document.location.hostname}:8082/ws"  # TODO: natvrdo port, nevim ale jak to zobecnit, vytahnout ven
    connection = new autobahn.Connection({url: wsuri, realm: "realm1"})

    connection.onopen = (session, details) ->
        console.log("Connected to server through websockets...")
        window.eu_session = session # TODO:

        on_gate = (args) ->
            value = args[0]
            console.log("gate passing")
            console.log(value)
            window.channel.trigger('tunnel', value)

        session.subscribe('com.europe.gate', on_gate).then(
            (sub) ->
                console.log("subscribed to topic 'com.europe.gate'")
            , (err) ->
                console.log("failed to subscribe to topic 'com.europe.gate'", err)
        )

        on_keyboard = (args) ->
            value = args[0]
            console.log("on_keyboard() event received")
            console.log(value)

            if value & 1
                window.channel.trigger('key', 'left')
            else if value & 2
                window.channel.trigger('key', 'right')
            else if value & 4
                window.channel.trigger('key', 'fire')

            window.channel.trigger('keypress')

        session.subscribe('com.europe.keyboard', on_keyboard).then(
            (sub) ->
                console.log("subscribed to topic 'com.europe.keyboard'")
            , (err) ->
                console.log("failed to subscribe to topic 'com.europe.keyboard'", err)
        )

        window.channel.on 'game:start', (options) ->
            session.publish('com.europe.start', [1])

        window.channel.on 'game:close', (options) ->
            session.publish('com.europe.stop', [1])

        window.channel.on 'game:goodblink', (leds, blink) ->
            if blink
                session.publish('com.europe.blink', [_.initial(leds), 28912, [_.last(leds)], 28912])
            else
                session.publish('com.europe.blink', [leds, 28912, [], 28912])

        window.channel.on 'game:badblink', (good_leds, bad_leds) ->
            session.publish('com.europe.blink', [good_leds, 28912, bad_leds, 32512])

        window.channel.on 'countdown:flash', (options) ->
            session.publish('com.europe.flash', [1])

        window.channel.on 'countdown:noise', (options) ->
            session.publish('com.europe.noise', [1])

        window.channel.on 'countdown:blank', (options) ->
            session.publish('com.europe.blank', [1])

        window.channel.on 'intro:rainbow', (options) ->
            session.publish('com.europe.rainbow', [1])

        window.channel.on 'intro:blank', (options) ->
            session.publish('com.europe.blank', [1])

    connection.onclose = (reason, details) ->
        # TODO: tohle by mohlo byt osetrene nejak specialne
        # napr. nejakym error overlayem, timeoutem a refreshem stranky
        # uz se mi parkrat stalo, ze backend padnul
        console.log("Websocket connection to backend lost: " + reason)

    connection.open()

    # --- intro

    window.channel.on 'intro:start', (options) ->
        state_handler("Intro", options)

    window.channel.on 'intro:close', (options) ->
        window.channel.trigger('crossroad:start', options)

    # --- crossroad

    window.channel.on 'crossroad:start', (options) ->
        state_handler("Crossroad", options)

    window.channel.on 'crossroad:idle', (options) ->
        window.channel.trigger('intro:start', options)

    window.channel.on 'crossroad:close', (options) ->
        if options.crossroad == 'game'
            window.channel.trigger('gamemode:start', options)
        else
            # set_delay () ->
            #     # NOTE: without delay, intro immediately recognise keypress and go to crossroad again
            #     window.channel.trigger('intro:start', options) # TODO: sup na vysledky
            # , 100
            window.channel.trigger('scores:start', options)

    # --- scores

    window.channel.on 'scores:start', (options) ->
        state_handler("Scores", options)

    window.channel.on 'scores:idle', (options) ->
        window.channel.trigger('intro:start', options)

    window.channel.on 'scores:close', (options) ->
        window.channel.trigger('crossroad:start', options)

    # --- gamemode

    window.channel.on 'gamemode:start', (options) ->
        state_handler("GameMode", options)

    window.channel.on 'gamemode:idle', (options) ->
        window.channel.trigger('intro:start', options)

    window.channel.on 'gamemode:close', (options) ->
        window.channel.trigger('countdown:start', options)

    # --- countdown

    window.channel.on 'countdown:start', (options) ->
        state_handler("Countdown", options)

    window.channel.on 'countdown:close', (options) ->
        window.channel.trigger('game:start', options)

    # --- game

    window.channel.on 'game:start', (options) ->
        state_handler("Game", options)

    window.channel.on 'game:close', (options) ->
        window.channel.trigger('result:start', options)

    # --- result

    window.channel.on 'result:start', (options) ->
        state_handler("Result", options)

    window.channel.on 'result:close', (options) ->
        window.channel.trigger('recap:start', options)

    # --- result

    window.channel.on 'recap:start', (options) ->
        state_handler("Recap", options)

    window.channel.on 'recap:close', (options) ->
        window.channel.trigger('score:start', options)

    # --- score

    window.channel.on 'score:start', (options) ->
        state_handler("Score", options)

    window.channel.on 'score:idle', (options) ->
        window.channel.trigger('intro:start', _.clone(final_global_options))


    # fetch global options from server (and then start)
    ServerOptions = Backbone.Collection.extend
        model: Backbone.Model
        url: '/api/options'
        parse: (response, options) ->
            response.results
    server_options = new ServerOptions
    server_options.on 'sync', ->
        _options = _.object(server_options.map (i) -> [i.get('key'), parseInt(i.get('value'))])
        _global_options = _.extend({options: _options}, {constants: {DIFFICULTY_EASY: 'E', DIFFICULTY_HARD: 'H'}}) 
        final_global_options = _.extend(_global_options, global_options) 

        # debug settings
        debug = false
        if window.location.search
            state = window.location.search.substr(1)
            questions = [{"id":137,"question":"Ve které zemi se nachází město Atény?","difficulty":"E","image":"/foto-4_3.jpg","country":{"id":39,"title":"Řecko","sensor":"39"},"category":{"id":1,"title":"Hlavní města","time_easy":30,"penalty_easy":3,"time_hard":10,"penalty_hard":3},"answer":false},{"id":107,"question":"Ve které zemi se nachází město Podgorica?","difficulty":"E","image":"/foto-4_3.jpg","country":{"id":9,"title":"Černá Hora","sensor":"9"},"category":{"id":1,"title":"Hlavní města","time_easy":30,"penalty_easy":3,"time_hard":10,"penalty_hard":3},"answer":true},{"id":108,"question":"Ve které zemi se nachází město Praha?","difficulty":"E","image":"/foto-4_3.jpg","country":{"id":10,"title":"Česko","sensor":"10"},"category":{"id":1,"title":"Hlavní města","time_easy":30,"penalty_easy":3,"time_hard":10,"penalty_hard":3},"answer":true},{"id":142,"question":"Ve které zemi se nachází město Bělehrad?","difficulty":"E","image":"/foto-4_3.jpg","country":{"id":44,"title":"Srbsko","sensor":"44"},"category":{"id":1,"title":"Hlavní města","time_easy":30,"penalty_easy":3,"time_hard":10,"penalty_hard":3},"answer":true},{"id":100,"question":"Ve které zemi se nachází město Andorra la Vella?","difficulty":"E","image":"/foto-4_3.jpg","country":{"id":2,"title":"Andora","sensor":"2"},"category":{"id":1,"title":"Hlavní města","time_easy":30,"penalty_easy":3,"time_hard":10,"penalty_hard":3},"answer":true},{"id":110,"question":"Ve které zemi se nachází město Talin?","difficulty":"E","image":null,"country":{"id":12,"title":"Estonsko","sensor":"12"},"category":{"id":1,"title":"Hlavní města","time_easy":30,"penalty_easy":3,"time_hard":10,"penalty_hard":3},"answer":true},{"id":125,"question":"Ve které zemi se nachází město Skopje?","difficulty":"E","image":null,"country":{"id":27,"title":"Makedonie","sensor":"27"},"category":{"id":1,"title":"Hlavní města","time_easy":30,"penalty_easy":3,"time_hard":10,"penalty_hard":3},"answer":true},{"id":120,"question":"Ve které zemi se nachází město Vaduz?","difficulty":"E","image":"/foto-4_3.jpg","country":{"id":22,"title":"Lichtenštejnsko","sensor":"22"},"category":{"id":1,"title":"Hlavní města","time_easy":30,"penalty_easy":3,"time_hard":10,"penalty_hard":3},"answer":true}]
            initials =
                a:
                    crossroad: "results"
                b:
                    crossroad: "game"
                c:
                    crossroad: "game"
                    gamemode:
                        category: 1
                        category_icon: 'svg/star.svg'
                        difficulty: 'E'
                        difficulty_title: 'Jednoduchá hra'
                        penalty: 3
                        time: 30
                        title: 'Hlavní města'
                d:
                    crossroad: "game"
                    gamemode:
                        category: 1
                        category_icon: 'svg/star.svg'
                        difficulty: 'E'
                        difficulty_title: 'Jednoduchá hra'
                        penalty: 3
                        time: 30
                        title: 'Hlavní města'
                    questions: questions
                    answers: [
                        {id: 137, answer: false}
                        {id: 107, answer: true}
                        {id: 108, answer: true}
                        {id: 142, answer: true}
                        {id: 100, answer: true}
                        {id: 110, answer: true}
                        {id: 125, answer: true}
                        {id: 120, answer: true}
                    ]
                    time: 84
            states = 
                intro: null
                crossroad: null
                scores: 'a'
                gamemode: 'b'
                countdown: 'c'
                game: 'c'
                result: 'd'
                recap: 'd'
                score: 'd'

            if state of states
                debug = true
                # tweak options to "infinite" timeouts
                _infinity = 100000
                debug_data = 
                    constants:
                        DIFFICULTY_EASY: "E"
                        DIFFICULTY_HARD: "H"
                    options:
                        COUNTDOWN_TICK_TIMEOUT : 1100
                        IDLE_CROSSROAD: 4000 * _infinity
                        IDLE_GAMEMODE: 4000 * _infinity
                        IDLE_RECAP: 10000 * _infinity
                        IDLE_RESULT: 10000 * _infinity
                        IDLE_SCORE: 10000 * _infinity
                        IDLE_SCORES: 10000 * _infinity
                        INTRO_TIME_PER_SCREEN: 3000
                        QUESTION_COUNT: 8
                        RESULT_COUNT: 10
                # add missing keys to initial options
                if states[state]
                    for key of initials[states[state]]
                        debug_data[key] = initials[states[state]][key]
                # launch game
                console.log "Final debug options, state #{state}"
                console.log debug_data
                window.channel.trigger("#{state}:start", debug_data)
    
        # normal settings
        if not debug
            # normal launch (no debug)
            console.log "Normal game launch (no debug)"
            window.channel.trigger('intro:start', _.clone(final_global_options))

        # initiate delayed rainbow on start, due to slow websocket initiation
        # (without this code event 'intro.rainbow' is launched before websocket links is created)
        handler = () ->
            window.channel.trigger('intro:rainbow')
        set_delay(handler, 1500)

    server_options.fetch()

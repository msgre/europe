// Generated by CoffeeScript 1.10.0
var App;

App = new Marionette.Application();

App.on('start', function(global_options) {
  var ServerOptions, active_module, connection, final_global_options, server_options, state_handler, that, wsuri;
  active_module = null;
  that = this;
  final_global_options = void 0;
  state_handler = function(new_module_name, options) {
    if (active_module !== null) {
      active_module.stop();
    }
    active_module = that.module(new_module_name);
    return active_module.start(options);
  };
  wsuri = "ws://" + document.location.hostname + ":8082/ws";
  connection = new autobahn.Connection({
    url: wsuri,
    realm: "realm1"
  });
  connection.onopen = function(session, details) {
    var on_gate, on_keyboard;
    console.log("Connected to server through websockets...");
    window.eu_session = session;
    on_gate = function(args) {
      var value;
      value = args[0];
      console.log("gate passing");
      console.log(value);
      return window.channel.trigger('tunnel', value);
    };
    session.subscribe('com.europe.gate', on_gate).then(function(sub) {
      return console.log("subscribed to topic 'com.europe.gate'");
    }, function(err) {
      return console.log("failed to subscribe to topic 'com.europe.gate'", err);
    });
    on_keyboard = function(args) {
      var value;
      value = args[0];
      console.log("on_keyboard() event received");
      console.log(value);
      if (value & 1) {
        window.channel.trigger('key', 'left');
      } else if (value & 2) {
        window.channel.trigger('key', 'right');
      } else if (value & 4) {
        window.channel.trigger('key', 'fire');
      }
      return window.channel.trigger('keypress');
    };
    session.subscribe('com.europe.keyboard', on_keyboard).then(function(sub) {
      return console.log("subscribed to topic 'com.europe.keyboard'");
    }, function(err) {
      return console.log("failed to subscribe to topic 'com.europe.keyboard'", err);
    });
    window.channel.on('game:start', function(options) {
      return session.publish('com.europe.start', [1]);
    });
    window.channel.on('game:close', function(options) {
      return session.publish('com.europe.stop', [1]);
    });
    window.channel.on('game:goodblink', function(leds, blink) {
      if (blink) {
        return session.publish('com.europe.blink', [_.initial(leds), 28912, [_.last(leds)], 28912]);
      } else {
        return session.publish('com.europe.blink', [leds, 28912, [], 28912]);
      }
    });
    window.channel.on('game:badblink', function(good_leds, bad_leds) {
      return session.publish('com.europe.blink', [good_leds, 28912, bad_leds, 32512]);
    });
    window.channel.on('countdown:flash', function(options) {
      return session.publish('com.europe.flash', [1]);
    });
    window.channel.on('countdown:noise', function(options) {
      return session.publish('com.europe.noise', [1]);
    });
    window.channel.on('countdown:blank', function(options) {
      return session.publish('com.europe.blank', [1]);
    });
    window.channel.on('intro:rainbow', function(options) {
      return session.publish('com.europe.rainbow', [1]);
    });
    return window.channel.on('intro:blank', function(options) {
      return session.publish('com.europe.blank', [1]);
    });
  };
  connection.onclose = function(reason, details) {
    return console.log("Websocket connection to backend lost: " + reason);
  };
  connection.open();
  window.channel.on('intro:start', function(options) {
    return state_handler("Intro", options);
  });
  window.channel.on('intro:close', function(options) {
    return window.channel.trigger('crossroad:start', options);
  });
  window.channel.on('crossroad:start', function(options) {
    return state_handler("Crossroad", options);
  });
  window.channel.on('crossroad:idle', function(options) {
    return window.channel.trigger('intro:start', options);
  });
  window.channel.on('crossroad:close', function(options) {
    if (options.crossroad === 'game') {
      return window.channel.trigger('gamemode:start', options);
    } else {
      return window.channel.trigger('scores:start', options);
    }
  });
  window.channel.on('scores:start', function(options) {
    return state_handler("Scores", options);
  });
  window.channel.on('scores:idle', function(options) {
    return window.channel.trigger('intro:start', options);
  });
  window.channel.on('scores:close', function(options) {
    return window.channel.trigger('crossroad:start', options);
  });
  window.channel.on('gamemode:start', function(options) {
    return state_handler("GameMode", options);
  });
  window.channel.on('gamemode:idle', function(options) {
    return window.channel.trigger('intro:start', options);
  });
  window.channel.on('gamemode:close', function(options) {
    return window.channel.trigger('countdown:start', options);
  });
  window.channel.on('countdown:start', function(options) {
    return state_handler("Countdown", options);
  });
  window.channel.on('countdown:close', function(options) {
    return window.channel.trigger('game:start', options);
  });
  window.channel.on('game:start', function(options) {
    return state_handler("Game", options);
  });
  window.channel.on('game:close', function(options) {
    return window.channel.trigger('result:start', options);
  });
  window.channel.on('result:start', function(options) {
    return state_handler("Result", options);
  });
  window.channel.on('result:close', function(options) {
    return window.channel.trigger('recap:start', options);
  });
  window.channel.on('recap:start', function(options) {
    return state_handler("Recap", options);
  });
  window.channel.on('recap:close', function(options) {
    return window.channel.trigger('score:start', options);
  });
  window.channel.on('score:start', function(options) {
    return state_handler("Score", options);
  });
  window.channel.on('score:idle', function(options) {
    return window.channel.trigger('intro:start', final_global_options);
  });
  ServerOptions = Backbone.Collection.extend({
    model: Backbone.Model,
    url: '/api/options',
    parse: function(response, options) {
      return response.results;
    }
  });
  server_options = new ServerOptions;
  server_options.on('sync', function() {
    var _global_options, _infinity, _options, debug, debug_data, handler, initials, key, questions, state, states;
    _options = _.object(server_options.map(function(i) {
      return [i.get('key'), parseInt(i.get('value'))];
    }));
    _global_options = _.extend({
      options: _options
    }, {
      constants: {
        DIFFICULTY_EASY: 'E',
        DIFFICULTY_HARD: 'H'
      }
    });
    final_global_options = _.extend(_global_options, global_options);
    debug = false;
    if (window.location.search) {
      state = window.location.search.substr(1);
      questions = [
        {
          "id": 137,
          "question": "Ve které zemi se nachází město Atény?",
          "difficulty": "E",
          "image": "/foto-4_3.jpg",
          "country": {
            "id": 39,
            "title": "Řecko",
            "sensor": "39"
          },
          "category": {
            "id": 1,
            "title": "Hlavní města",
            "time_easy": 30,
            "penalty_easy": 3,
            "time_hard": 10,
            "penalty_hard": 3
          },
          "answer": false
        }, {
          "id": 107,
          "question": "Ve které zemi se nachází město Podgorica?",
          "difficulty": "E",
          "image": "/foto-4_3.jpg",
          "country": {
            "id": 9,
            "title": "Černá Hora",
            "sensor": "9"
          },
          "category": {
            "id": 1,
            "title": "Hlavní města",
            "time_easy": 30,
            "penalty_easy": 3,
            "time_hard": 10,
            "penalty_hard": 3
          },
          "answer": true
        }, {
          "id": 108,
          "question": "Ve které zemi se nachází město Praha?",
          "difficulty": "E",
          "image": "/foto-4_3.jpg",
          "country": {
            "id": 10,
            "title": "Česko",
            "sensor": "10"
          },
          "category": {
            "id": 1,
            "title": "Hlavní města",
            "time_easy": 30,
            "penalty_easy": 3,
            "time_hard": 10,
            "penalty_hard": 3
          },
          "answer": true
        }, {
          "id": 142,
          "question": "Ve které zemi se nachází město Bělehrad?",
          "difficulty": "E",
          "image": "/foto-4_3.jpg",
          "country": {
            "id": 44,
            "title": "Srbsko",
            "sensor": "44"
          },
          "category": {
            "id": 1,
            "title": "Hlavní města",
            "time_easy": 30,
            "penalty_easy": 3,
            "time_hard": 10,
            "penalty_hard": 3
          },
          "answer": true
        }, {
          "id": 100,
          "question": "Ve které zemi se nachází město Andorra la Vella?",
          "difficulty": "E",
          "image": "/foto-4_3.jpg",
          "country": {
            "id": 2,
            "title": "Andora",
            "sensor": "2"
          },
          "category": {
            "id": 1,
            "title": "Hlavní města",
            "time_easy": 30,
            "penalty_easy": 3,
            "time_hard": 10,
            "penalty_hard": 3
          },
          "answer": true
        }, {
          "id": 110,
          "question": "Ve které zemi se nachází město Talin?",
          "difficulty": "E",
          "image": null,
          "country": {
            "id": 12,
            "title": "Estonsko",
            "sensor": "12"
          },
          "category": {
            "id": 1,
            "title": "Hlavní města",
            "time_easy": 30,
            "penalty_easy": 3,
            "time_hard": 10,
            "penalty_hard": 3
          },
          "answer": true
        }, {
          "id": 125,
          "question": "Ve které zemi se nachází město Skopje?",
          "difficulty": "E",
          "image": null,
          "country": {
            "id": 27,
            "title": "Makedonie",
            "sensor": "27"
          },
          "category": {
            "id": 1,
            "title": "Hlavní města",
            "time_easy": 30,
            "penalty_easy": 3,
            "time_hard": 10,
            "penalty_hard": 3
          },
          "answer": true
        }, {
          "id": 120,
          "question": "Ve které zemi se nachází město Vaduz?",
          "difficulty": "E",
          "image": "/foto-4_3.jpg",
          "country": {
            "id": 22,
            "title": "Lichtenštejnsko",
            "sensor": "22"
          },
          "category": {
            "id": 1,
            "title": "Hlavní města",
            "time_easy": 30,
            "penalty_easy": 3,
            "time_hard": 10,
            "penalty_hard": 3
          },
          "answer": true
        }
      ];
      initials = {
        a: {
          crossroad: "results"
        },
        b: {
          crossroad: "game"
        },
        c: {
          crossroad: "game",
          gamemode: {
            category: 1,
            category_icon: 'svg/star.svg',
            difficulty: 'E',
            difficulty_title: 'Jednoduchá hra',
            penalty: 3,
            time: 30,
            title: 'Hlavní města'
          }
        },
        d: {
          crossroad: "game",
          gamemode: {
            category: 1,
            category_icon: 'svg/star.svg',
            difficulty: 'E',
            difficulty_title: 'Jednoduchá hra',
            penalty: 3,
            time: 30,
            title: 'Hlavní města'
          },
          questions: questions,
          answers: [
            {
              id: 137,
              answer: false
            }, {
              id: 107,
              answer: true
            }, {
              id: 108,
              answer: true
            }, {
              id: 142,
              answer: true
            }, {
              id: 100,
              answer: true
            }, {
              id: 110,
              answer: true
            }, {
              id: 125,
              answer: true
            }, {
              id: 120,
              answer: true
            }
          ],
          time: 84
        }
      };
      states = {
        intro: null,
        crossroad: null,
        scores: 'a',
        gamemode: 'b',
        countdown: 'c',
        game: 'c',
        result: 'd',
        recap: 'd',
        score: 'd'
      };
      if (state in states) {
        debug = true;
        _infinity = 100000;
        debug_data = {
          constants: {
            DIFFICULTY_EASY: "E",
            DIFFICULTY_HARD: "H"
          },
          options: {
            COUNTDOWN_TICK_TIMEOUT: 1100,
            IDLE_CROSSROAD: 4000 * _infinity,
            IDLE_GAMEMODE: 4000 * _infinity,
            IDLE_RECAP: 10000 * _infinity,
            IDLE_RESULT: 10000 * _infinity,
            IDLE_SCORE: 10000 * _infinity,
            IDLE_SCORES: 10000 * _infinity,
            INTRO_TIME_PER_SCREEN: 3000,
            QUESTION_COUNT: 8,
            RESULT_COUNT: 10
          }
        };
        if (states[state]) {
          for (key in initials[states[state]]) {
            debug_data[key] = initials[states[state]][key];
          }
        }
        console.log("Final debug options, state " + state);
        console.log(debug_data);
        window.channel.trigger(state + ":start", debug_data);
      }
    }
    if (!debug) {
      console.log("Normal game launch (no debug)");
      window.channel.trigger('intro:start', final_global_options);
    }
    handler = function() {
      return window.channel.trigger('intro:rainbow');
    };
    return set_delay(handler, 1500);
  });
  return server_options.fetch();
});

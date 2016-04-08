// Generated by CoffeeScript 1.10.0
App.module("Result", function(Mod, App, Backbone, Marionette, $, _) {
  var BadTimeView, GreatTimeView, InfoView, LETTERS, LETTER_BACKSPACE, LETTER_ENTER, NAME_MAX_LENGTH, Name, Rank, Score, ScreenLayout, Time, TypewriterView1, TypewriterView2, _options, format_results, handler, layout, name, rank, time;
  Mod.startWithParent = false;
  NAME_MAX_LENGTH = 16;
  LETTERS = 'ABCDEFGHIJKLMNOPRSTUVWXYZ 0123456789←✔';
  LETTER_BACKSPACE = '←';
  LETTER_ENTER = '✔';
  _options = void 0;
  time = void 0;
  rank = void 0;
  name = void 0;
  layout = void 0;
  format_results = function(data) {
    var answers, out;
    answers = data.answers.map(function(i) {
      return i.id + ":" + i.answer;
    });
    return out = {
      category: data.category.id,
      name: null,
      time: data.time,
      answers: answers.join(',')
    };
  };
  Time = Backbone.Model.extend({
    defaults: {
      time: void 0
    }
  });
  Rank = Backbone.Model.extend({
    defaults: {
      position: void 0,
      total: void 0,
      top: void 0
    },
    initialize: function(attributes, options) {
      return this.url = "/api/results/" + options.difficulty + "-" + options.category + "/" + options.time;
    }
  });
  Name = Backbone.Model.extend({
    defaults: {
      name: '',
      letter: 'A'
    }
  });
  Score = Backbone.Model.extend({
    defaults: {
      name: void 0,
      time: void 0,
      category: void 0,
      difficulty: void 0,
      questions: void 0
    },
    url: '/api/score'
  });
  InfoView = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<h1><img src='<%= icon %>'><%= category %></h1>\n<h2><%= difficulty %></h2>")(serialized_model);
    }
  });
  GreatTimeView = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<%= show_time() %>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        show_time: function() {
          return display_elapsed(this.time);
        }
      };
    }
  });
  BadTimeView = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<%= show_time() %>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        show_time: function() {
          return display_elapsed(this.time);
        }
      };
    },
    initialize: function() {
      return window.channel.on('keypress', function(msg) {
        return window.channel.trigger('result:save', null);
      });
    },
    onDestroy: function() {
      return window.channel.off('keypress');
    }
  });
  TypewriterView1 = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<%= show_name() %><span class=\"selected\"><%= letter %></span><%= show_empty() %>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        show_name: function() {
          var i, j, out, ref;
          out = "";
          for (i = j = 0, ref = this.name.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
            out += "<span class='chosen'>" + (this.name.charAt(i)) + "</span>";
          }
          return out;
        },
        show_empty: function() {
          var i, j, out, ref, rest;
          rest = NAME_MAX_LENGTH - this.name.length;
          out = "";
          if (rest > 1) {
            for (i = j = 1, ref = rest; 1 <= ref ? j < ref : j > ref; i = 1 <= ref ? ++j : --j) {
              out += "<span class='empty'>␣</span>";
            }
          }
          return out;
        }
      };
    },
    initialize: function() {
      var that;
      console.log('TypewriterView1');
      that = this;
      this.model.on('change', function() {
        return that.render();
      });
      return window.channel.on('key', function(msg) {
        var _name, letter;
        clear_delay();
        if (msg === 'fire') {
          window.sfx.button2.play();
          letter = that.model.get('letter');
          _name = that.model.get('name');
          if (letter === LETTER_BACKSPACE) {
            if (_name.length > 0) {
              that.model.set('name', _name.substring(0, _name.length - 1));
            }
          } else if (letter === LETTER_ENTER) {
            if (_name.length > 0) {
              window.channel.trigger('result:save', _name);
              return;
            }
          } else if (_name.length < NAME_MAX_LENGTH) {
            that.model.set('name', "" + _name + letter);
            _name = that.model.get('name');
            if (_name.length === NAME_MAX_LENGTH) {
              window.channel.trigger('result:save', _name);
              return;
            }
          }
        }
        return set_delay(handler, _options.options.IDLE_RESULT);
      });
    },
    onDestroy: function() {
      window.channel.off('key');
      return this.model.off('change');
    }
  });
  TypewriterView2 = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<%= show_alphabet() %>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        show_alphabet: function() {
          var index;
          index = LETTERS.indexOf(this.letter);
          return (LETTERS.substring(0, index)) + "<span class='selected'>" + this.letter + "</span>" + (LETTERS.substring(index + 1));
        }
      };
    },
    initialize: function() {
      var that;
      console.log('TypewriterView2');
      that = this;
      this.model.on('change', function() {
        return that.render();
      });
      return window.channel.on('key', function(msg) {
        var index, letter;
        clear_delay();
        letter = that.model.get('letter');
        index = LETTERS.indexOf(letter);
        if (msg === 'left' && index > 0) {
          window.sfx.button.play();
          index -= 1;
          that.model.set('letter', LETTERS[index]);
        } else if (msg === 'right' && index < (LETTERS.length - 1)) {
          window.sfx.button.play();
          index += 1;
          that.model.set('letter', LETTERS[index]);
        }
        return set_delay(handler, _options.options.IDLE_RESULT);
      });
    },
    onDestroy: function() {
      window.channel.off('key');
      return this.model.off('change');
    }
  });
  ScreenLayout = Marionette.LayoutView.extend({
    template: _.template("<div id=\"header\"></div>\n<div id=\"body\">\n    <table class=\"result\">\n        <tr class=\"row-1\">\n            <td colspan=\"2\">\n                <h1>Nový rekord!</h1>\n                <h2></h2>\n                <p>Tvůj čas se dostal do žebříčku. Zadej jméno svého týmu.</p>\n            </td>\n        </tr>\n        <tr class=\"row-2\">\n            <td class=\"typewriter\"></td>\n            <td class=\"help\" rowspan=\"2\">\n                <div>\n                    <p>Tlačítky nahoru/dolů vybírej písmena,\n                    tlačítkem OK vyber konkrétní znak.<br/>Symbolem\n                    " + LETTER_BACKSPACE + " smažeš předchozí znak,\n                    symbolem " + LETTER_ENTER + " jméno\n                    uložíš.<br/>Délka jména maximálně \n                    " + NAME_MAX_LENGTH + " znaků.</p>\n                </div>\n            </td>\n        </tr>\n        <tr class=\"row-3\">\n            <td colspan=\"2\"></td>\n        </tr>\n    </table>\n</div>"),
    onRender: function() {
      return $('body').attr('class', 'layout-a');
    },
    regions: {
      info: '#header',
      time: '#body .row-1 h2',
      input: '.row-2 .typewriter',
      alphabet: '.row-3 td'
    }
  });
  handler = function() {
    var _name;
    _name = name.get('name');
    if (_name.length < 1) {
      _name = null;
    }
    return window.channel.trigger('result:save', _name);
  };
  Mod.onStart = function(options) {
    console.log('Result module');
    console.log(options);
    _options = options;
    window.sfx.surprise.play();
    time = new Time({
      time: options.time
    });
    rank = new Rank(null, {
      difficulty: options.gamemode.difficulty,
      category: options.gamemode.category,
      time: options.time
    });
    name = new Name();
    layout = new ScreenLayout({
      el: make_content_wrapper()
    });
    layout.render();
    layout.getRegion('info').show(new InfoView({
      model: new Backbone.Model({
        'category': options.gamemode.title,
        'icon': options.gamemode.category_icon,
        'difficulty': options.gamemode.difficulty_title
      })
    }));
    rank.on('sync', function() {
      if (rank.get('top')) {
        layout.getRegion('time').show(new GreatTimeView({
          model: time
        }));
        layout.getRegion('input').show(new TypewriterView1({
          model: name
        }));
        return layout.getRegion('alphabet').show(new TypewriterView2({
          model: name
        }));
      } else {
        return layout.getRegion('time').show(new BadTimeView({
          model: time
        }));
      }
    });
    window.channel.on('result:save', function(_name) {
      var questions, score;
      clear_delay();
      questions = _.map(_options.answers, function(i) {
        return {
          question: i.id,
          correct: i.answer
        };
      });
      score = new Score({
        name: _name,
        time: _options.time,
        category: _options.gamemode.category,
        difficulty: _options.gamemode.difficulty,
        questions: questions
      });
      score.save();
      return score.on('sync', function() {
        window.channel.trigger('result:close', _options);
        return score.off('sync');
      });
    });
    set_delay(handler, _options.options.IDLE_RESULT);
    return rank.fetch();
  };
  return Mod.onStop = function() {
    var score;
    clear_delay();
    time = void 0;
    rank.off('sync');
    rank = void 0;
    score = void 0;
    layout.destroy();
    return window.channel.off('result:save');
  };
});

// Generated by CoffeeScript 1.10.0
App.module("Game", function(Mod, App, Backbone, Marionette, $, _) {
  var Info, InfoItemView, PENALTY_TIME, Question, QuestionItemView, Questions, ScreenLayout, TIMER_DELAY, _options, handler, info, layout, local_channel, questions;
  Mod.startWithParent = false;
  TIMER_DELAY = 100;
  PENALTY_TIME = void 0;
  local_channel = void 0;
  _options = void 0;
  info = void 0;
  questions = void 0;
  layout = void 0;
  Info = Backbone.Model.extend({
    defaults: {
      question: 1,
      total_questions: null,
      category: null,
      time: 0,
      total: 0,
      current: 0
    },
    initialize: function() {
      var that;
      that = this;
      return local_channel.on('penalty', function(count) {
        var current, time, total;
        time = that.get('time');
        current = that.get('current');
        total = that.get('total');
        current += count;
        if (current > total) {
          current = total;
        }
        return that.set({
          time: time + count * 10,
          current: current
        });
      });
    }
  });
  Question = Backbone.Model.extend({
    idAttribute: 'id',
    defaults: {
      id: null,
      question: null,
      image: null,
      country: null,
      category: null,
      answer: null
    }
  });
  Questions = Backbone.Collection.extend({
    model: Question,
    parse: function(response, options) {
      return response.results;
    },
    initialize: function(models, options) {
      return this.url = "/api/questions/" + options.difficulty + "-" + options.category;
    }
  });
  InfoItemView = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<h1><%= category %></h1>\n<div class=\"bar\" style=\"background-position:<%= (current/total)*1100 %>px 0px\">\n    <p><%= question %>/<%= total_questions %></p>\n    <p><%= show_time() %></p>\n</div>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        show_time: function() {
          return display_elapsed(this.time);
        }
      };
    },
    initialize: function(options) {
      return this.model.on('change', (function(_this) {
        return function() {
          return _this.render();
        };
      })(this));
    },
    onDestroy: function() {
      return this.model.off('change');
    }
  });
  QuestionItemView = Marionette.ItemView.extend({
    tagName: 'tr',
    template: function(serialized_model) {
      var tmpl;
      if (serialized_model.image && serialized_model.question) {
        tmpl = "<td><img src=\"<%= image %>\" height=\"781px\" /></td>\n<td class=\"text\"><%= question %><br><small><%= country.board  %>/<%= country.gate  %></small></td>";
      } else if (serialized_model.image) {
        tmpl = "<td><img src=\"<%= image %>\" /><br><small><%= country.board  %>/<%= country.gate  %></small></td>";
      } else {
        tmpl = "<td><%= question %><br><small><%= country.board  %>/<%= country.gate  %></small></td>";
      }
      return _.template(tmpl)(serialized_model);
    },
    initialize: function(options) {
      var that;
      this.model.on('change', (function(_this) {
        return function() {
          return _this.render();
        };
      })(this));
      that = this;
      window.channel.on('tunnel', function(event) {
        var country;
        country = that.model.get('country');
        if (("" + country.board) in event && event["" + country.board] & country.gate) {
          return local_channel.trigger('next', true);
        } else {
          return local_channel.trigger('penalty', PENALTY_TIME);
        }
      });
      window.channel.on('debug:good', function() {
        return local_channel.trigger('next', true);
      });
      return window.channel.on('debug:bad', function() {
        return local_channel.trigger('penalty', PENALTY_TIME);
      });
    },
    onDestroy: function() {
      window.channel.off('debug:bad');
      window.channel.off('debug:good');
      window.channel.off('tunnel');
      return this.model.off('change');
    }
  });
  ScreenLayout = Marionette.LayoutView.extend({
    template: _.template("<div id=\"header\">\n    <h1></h1>\n    <div class=\"bar\"></div>\n</div>\n<div id=\"body\">\n    <table class=\"game\"></table>\n</div>"),
    onRender: function() {
      return $('body').attr('class', 'layout-b');
    },
    regions: {
      info: '#header',
      question: '#body .game'
    }
  });
  handler = function() {
    var current, time, total;
    time = info.get('time') + 1;
    info.set('time', time);
    current = info.get('current');
    total = info.get('total');
    if (current >= total) {
      return local_channel.trigger('next', false);
    } else {
      return info.set('current', current + .1);
    }
  };
  Mod.onStart = function(options) {
    console.log('Game module');
    console.log(options);
    _options = options;
    PENALTY_TIME = options.gamemode.penalty;
    local_channel = Backbone.Radio.channel('game');
    info = new Info({
      total_questions: _options.options.QUESTION_COUNT,
      category: _options.gamemode.title,
      total: _options.gamemode.time,
      current: 0
    });
    questions = new Questions(null, {
      difficulty: _options.gamemode.difficulty,
      category: _options.gamemode.category
    });
    questions.on('sync', function() {
      var question_view;
      layout = new ScreenLayout({
        el: make_content_wrapper()
      });
      layout.render();
      layout.getRegion('info').show(new InfoItemView({
        model: info
      }));
      question_view = new QuestionItemView({
        model: questions.at(info.get('question') - 1)
      });
      layout.getRegion('question').show(question_view);
      local_channel.on('next', function(user_answer) {
        var bad_answers, bad_leds, correct_answers, good_leds, leds, old_q, output, question;
        if (user_answer) {
          window.sfx.yes.play();
        } else {
          window.sfx.no.play();
        }
        question = info.get('question');
        old_q = questions.at(question - 1);
        old_q.set('answer', user_answer);
        question += 1;
        correct_answers = questions.filter(function(i) {
          return i.get('answer') === true;
        });
        if (question > options.options.QUESTION_COUNT) {
          bad_answers = questions.filter(function(i) {
            return i.get('answer') === false;
          });
          good_leds = _.map(correct_answers, function(i) {
            return i.get('country').led;
          });
          bad_leds = _.map(bad_answers, function(i) {
            return i.get('country').led;
          });
          if (bad_leds.length > 0) {
            window.channel.trigger('game:badblink', good_leds, bad_leds);
          } else {
            window.channel.trigger('game:goodblink', good_leds, questions.at(question - 2).get('answer') === true);
          }
          clear_timer();
          output = _.extend(_options, {
            questions: questions.toJSON(),
            answers: questions.map(function(i) {
              return {
                id: i.get('id'),
                answer: i.get('answer')
              };
            }),
            time: info.get('time')
          });
          return window.channel.trigger('game:close', output);
        } else {
          leds = _.map(correct_answers, function(i) {
            return i.get('country').led;
          });
          window.channel.trigger('game:goodblink', leds, questions.at(question - 2).get('answer') === true);
          info.set('question', question);
          info.set('current', 0);
          question_view.destroy();
          question_view = new QuestionItemView({
            model: questions.at(question - 1)
          });
          return layout.getRegion('question').show(question_view);
        }
      });
      return set_timer(handler, TIMER_DELAY);
    });
    return questions.fetch();
  };
  return Mod.onStop = function(options) {
    clear_timer();
    info = void 0;
    questions = void 0;
    layout.destroy();
    return local_channel.reset();
  };
});

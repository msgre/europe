//@ sourceMappingURL=obraz_04a.map
// Generated by CoffeeScript 1.6.1
var App;

App = new Marionette.Application();

App.module("Game", function(Mod, App, Backbone, Marionette, $, _) {
  Mod.channel = Backbone.Wreqr.radio.channel('main');
  Mod.timer_delay = 100;
  Mod.timer_id = void 0;
  Mod.timer_fn = function() {
    return Mod.channel.commands.execute('main', 'tick');
  };
  Mod.clear_timer = function() {
    if (Mod.timer_fn !== void 0) {
      return window.clearInterval(Mod.timer_id);
    }
  };
  Mod.set_timer = function() {
    Mod.clear_timer();
    return Mod.timer_id = window.setInterval(Mod.timer_fn, Mod.timer_delay);
  };
  Mod.Progress = Backbone.Model.extend({
    defaults: {
      total: 0,
      current: 0
    }
  });
  Mod.Info = Backbone.Model.extend({
    defaults: {
      question: 1,
      total_questions: null,
      category: null,
      time: 0
    }
  });
  Mod.Question = Backbone.Model.extend({
    idAttribute: 'id',
    defaults: {
      id: null,
      question: null,
      image: null,
      country: null,
      category: null
    }
  });
  Mod.Questions = Backbone.Collection.extend({
    model: Mod.Question,
    parse: function(response, options) {
      return response.results;
    },
    initialize: function(category_id) {
      return this.url = "/api/questions/" + category_id;
    }
  });
  Mod.InfoItemView = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<div class=\"col-md-4\">\n    <p>Otázka č.<%= question %>/<%= total_questions %></p>\n</div>\n<div class=\"col-md-4 text-center\">\n    <p><%= category %></p>\n</div>\n<div class=\"col-md-4 text-right\">\n    <p><%= show_time() %></p>\n</div>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        show_time: function() {
          return elapsed(this.time);
        }
      };
    },
    initialize: function(options) {
      var _this = this;
      return this.model.on('change', function() {
        return _this.render();
      });
    }
  });
  Mod.ProgressItemView = Marionette.ItemView.extend({
    className: 'progress',
    template: function(serialized_model) {
      return _.template("<div class=\"progress-bar\" role=\"progressbar\" aria-valuenow=\"<%= get_percent() %>\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width: <%= get_percent() %>%;\"></div>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        get_percent: function() {
          if (this.current <= this.total) {
            return (this.current / this.total) * 100;
          } else {
            return 100;
          }
        }
      };
    },
    initialize: function(options) {
      var _this = this;
      return this.model.on('change', function() {
        return _this.render();
      });
    }
  });
  Mod.QuestionItemView = Marionette.ItemView.extend({
    tagName: 'h1',
    template: function(serialized_model) {
      return _.template("<%= display_question() %>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        display_question: function() {
          if (this.image !== null) {
            return this.image;
          } else {
            return this.question;
          }
        }
      };
    },
    initialize: function(options) {
      var _this = this;
      return this.model.on('change', function() {
        return _this.render();
      });
    }
  });
  return Mod.QuestionLayout = Marionette.LayoutView.extend({
    el: '#content',
    template: _.template("<div class=\"row\">\n    <div class=\"col-md-12\" id=\"info\"></div>\n</div>\n<div class=\"row\">\n    <div class=\"col-md-12 text-center\" id=\"question\"></div>\n</div>\n<br/>\n<div class=\"row\">\n    <div class=\"col-md-12\" id=\"progress\"></div>\n</div>"),
    regions: {
      info: '#info',
      question: '#question',
      progress: '#progress'
    }
  });
});

App.addInitializer(function(options) {
  var Game, category_id, info, progress, questions;
  category_id = 1;
  Game = App.module("Game");
  info = new Game.Info({
    total_questions: 10,
    category: 'unknown'
  });
  progress = new Game.Progress({
    total: 10,
    current: 0
  });
  questions = new Game.Questions(category_id);
  questions.fetch();
  return questions.on('sync', function() {
    var info_view, progress_view, q_layout, question_view;
    q_layout = new Game.QuestionLayout();
    q_layout.render();
    info_view = new Game.InfoItemView({
      model: info
    });
    q_layout.getRegion('info').show(info_view);
    question_view = new Game.QuestionItemView({
      model: questions.at(info.get('question'))
    });
    q_layout.getRegion('question').show(question_view);
    progress_view = new Game.ProgressItemView({
      model: progress
    });
    q_layout.getRegion('progress').show(progress_view);
    Game.channel.commands.setHandler('main', function(msg) {
      var current, question, time, total;
      time = info.get('time') + 1;
      info.set('time', time);
      current = progress.get('current');
      total = progress.get('total');
      if (current >= total) {
        question = info.get('question') + 1;
        info.set('question', question);
        progress.set('current', 0);
        question_view = new Game.QuestionItemView({
          model: questions.at(question)
        });
        return q_layout.getRegion('question').show(question_view);
      } else {
        return progress.set('current', current + .1);
      }
    });
    return Game.set_timer();
  });
});

App.start();

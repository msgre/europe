// Generated by CoffeeScript 1.10.0
App.module("Score", function(Mod, App, Backbone, Marionette, $, _) {
  var CategoryResultItemView, CategoryResultView, NoResultsView, Result, Results, ScoreLayout, TitleView, _options, handler, layout;
  Mod.startWithParent = false;
  _options = void 0;
  layout = void 0;
  Result = Backbone.Model.extend({
    defaults: {
      name: void 0,
      time: void 0,
      category: void 0
    }
  });
  Results = Backbone.Collection.extend({
    model: Result,
    initialize: function(models, options) {
      return this.url = "/api/results/" + options.difficulty + "-" + options.category;
    },
    parse: function(response, options) {
      return response.results;
    }
  });
  TitleView = Marionette.ItemView.extend({
    tagName: "h3",
    template: function(serialized_model) {
      return _.template("<%= title %> / <%= difficulty %>")(serialized_model);
    },
    rerender: function(model) {
      this.model = model;
      return this.render();
    }
  });
  CategoryResultItemView = Marionette.ItemView.extend({
    tagName: "tr",
    template: function(serialized_model) {
      return _.template("<td><%= name %></td>\n<td class=\"text-right\"><%= show_time() %></td>")(serialized_model);
    },
    templateHelpers: function() {
      return {
        show_time: function() {
          return display_elapsed(this.time);
        }
      };
    }
  });
  NoResultsView = Marionette.ItemView.extend({
    template: "<p>Nahrávám...</p>"
  });
  CategoryResultView = Marionette.CollectionView.extend({
    childView: CategoryResultItemView,
    tagName: 'table',
    className: 'table',
    emptyView: NoResultsView
  });
  ScoreLayout = Marionette.LayoutView.extend({
    template: _.template("<div class=\"row\">\n    <div class=\"col-md-12\">\n        <h3 id=\"title\"></h3>\n    </div>\n</div>\n<div class=\"row\">\n    <div class=\"col-md-3\">&nbsp;</div>\n    <div class=\"col-md-6\">\n        <div id=\"results\"></div>\n    </div>\n    <div class=\"col-md-3\">&nbsp;</div>\n</div>"),
    regions: {
      title: '#title',
      results: '#results'
    }
  });
  handler = function() {
    return window.channel.command('score:idle', _options);
  };
  Mod.onStart = function(options) {
    var results, title;
    console.log('Score module');
    console.log(options);
    _options = options;
    layout = new ScoreLayout({
      el: make_content_wrapper()
    });
    layout.render();
    results = new Results(null, {
      category: options.gamemode.category,
      difficulty: options.gamemode.difficulty
    });
    title = new Backbone.Model({
      title: options.gamemode.title,
      difficulty: options.gamemode.difficulty === _options.constants.DIFFICULTY_EASY ? "Jednoduchá obtížnost" : "Složitá obtížnost"
    });
    layout.getRegion('title').show(new TitleView({
      model: title
    }));
    layout.getRegion('results').show(new CategoryResultView({
      collection: results
    }));
    results.fetch();
    window.channel.on('key', function(msg) {
      var set_new_timeout;
      set_new_timeout = true;
      if (msg === 'fire' || msg === 'left' || msg === 'right') {
        window.sfx.button2.play();
        set_delay(function() {
          return window.channel.command('score:idle', _options);
        }, 100);
        set_new_timeout = false;
      } else {
        set_new_timeout = false;
      }
      if (set_new_timeout) {
        window.sfx.button.play();
        return set_delay(handler, _options.options.IDLE_SCORE);
      }
    });
    return set_delay(handler, _options.options.IDLE_SCORE);
  };
  return Mod.onStop = function() {
    window.channel.off('key');
    clear_delay();
    layout.destroy();
    return layout = void 0;
  };
});

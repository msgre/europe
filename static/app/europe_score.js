// Generated by CoffeeScript 1.10.0
App.module("Score", function(Mod, App, Backbone, Marionette, $, _) {
  var CategoryResultItemView, CategoryResultView, InfoView, NoResultsView, Result, Results, ScreenLayout, _options, handler, layout;
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
      var i, item, j, last, len, out, ref, show;
      out = [];
      last = null;
      i = 1;
      ref = response.results;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        show = last === null || last.time !== item.time;
        _.extend(item, {
          show: show,
          order: i
        });
        out.push(item);
        last = item;
        i += 1;
      }
      return out;
    }
  });
  InfoView = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<h1><img src='<%= icon %>'><%= category %></h1>\n<h2><%= difficulty %></h2>")(serialized_model);
    }
  });
  CategoryResultItemView = Marionette.ItemView.extend({
    tagName: "tr",
    template: function(serialized_model) {
      return _.template("<td class=\"text-right\"><% if (show) {%><%= order %><% } %></td>\n<td><%= name %></td>\n<td class=\"text-right\"><%= show_time() %></td>")(serialized_model);
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
    className: 'results',
    emptyView: NoResultsView
  });
  ScreenLayout = Marionette.LayoutView.extend({
    template: _.template("<div id=\"header\"></div>\n<div id=\"body\"></div>"),
    onRender: function() {
      return $('body').attr('class', 'layout-a');
    },
    regions: {
      info: '#header',
      results: '#body'
    }
  });
  handler = function() {
    return window.channel.trigger('score:idle', _options);
  };
  Mod.onStart = function(options) {
    var info, results;
    console.log('Score module');
    console.log(options);
    _options = options;
    layout = new ScreenLayout({
      el: make_content_wrapper()
    });
    layout.render();
    results = new Results(null, {
      category: options.gamemode.category,
      difficulty: options.gamemode.difficulty
    });
    info = new Backbone.Model({
      category: options.gamemode.title,
      icon: options.gamemode.category_icon,
      difficulty: options.gamemode.difficulty_title
    });
    layout.getRegion('info').show(new InfoView({
      model: info
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
          return window.channel.trigger('score:idle', _options);
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

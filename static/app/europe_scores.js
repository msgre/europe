// Generated by CoffeeScript 1.10.0
App.module("Scores", function(Mod, App, Backbone, Marionette, $, _) {
  var Categories, Category, CategoryResultItemView, CategoryResultView, NoResultsView, Result, Results, ScreenLayout, TitleView, _options, categories, handler, index, layout;
  Mod.startWithParent = false;
  _options = void 0;
  categories = void 0;
  layout = void 0;
  index = 0;
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
  Category = Backbone.Model.extend({
    idAttribute: 'id',
    defaults: {
      id: void 0,
      title: void 0,
      active: false,
      order: void 0
    }
  });
  Categories = Backbone.Collection.extend({
    model: Category,
    comparator: 'order',
    url: '/api/categories',
    parse: function(response, options) {
      return response.results;
    }
  });
  TitleView = Marionette.ItemView.extend({
    tagName: "h3",
    template: function(serialized_model) {
      return _.template("<%= title %>")(serialized_model);
    },
    rerender: function(model) {
      this.model = model;
      return this.render();
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
    template: "<p>Tuto kategorii a obtížnost zatím nikdo nehrál.</p>"
  });
  CategoryResultView = Marionette.CollectionView.extend({
    childView: CategoryResultItemView,
    tagName: 'table',
    className: 'results',
    emptyView: NoResultsView
  });
  ScreenLayout = Marionette.LayoutView.extend({
    template: _.template("<div id=\"main\">\n    <div id=\"header\">\n        <h1></h1>\n    </div>\n    <div id=\"body\">\n        <div class=\"col\">\n            <h2>Jednoduchá úroveň</h2>\n            <div id=\"easy-results\"></div>\n        </div>\n        <div class=\"col\">\n            <h2>Obtížná úroveň</h2>\n            <div id=\"hard-results\"></div>\n        </div>\n        <div class=\"clear\"></div>\n        <p class=\"help\">Nápověda: zmáčkni vlevo/vpravo pro zobrazení dalších kategorií s výsledkama, OK pro návrat</p>\n    </div>\n</div>"),
    onRender: function() {
      return $('body').attr('class', 'layout-a');
    },
    regions: {
      title: '#header h1',
      easy: '#easy-results',
      hard: '#hard-results'
    }
  });
  handler = function() {
    return console.log('scores:idle');
  };
  Mod.onStart = function(options) {
    console.log('Scores module');
    console.log(options);
    _options = options;
    index = 0;
    layout = new ScreenLayout({
      el: make_content_wrapper()
    });
    layout.render();
    categories = new Categories();
    categories.on('sync', function() {
      var category, easy_results, hard_results;
      category = categories.at(index);
      easy_results = new Results(null, {
        category: category.get('id'),
        difficulty: _options.constants.DIFFICULTY_EASY
      });
      hard_results = new Results(null, {
        category: category.get('id'),
        difficulty: _options.constants.DIFFICULTY_HARD
      });
      layout.getRegion('title').show(new TitleView({
        model: category
      }));
      layout.getRegion('easy').show(new CategoryResultView({
        collection: easy_results
      }));
      layout.getRegion('hard').show(new CategoryResultView({
        collection: hard_results
      }));
      easy_results.fetch();
      hard_results.fetch();
      window.channel.on('key', function(msg) {
        var new_category, new_easy_results, new_hard_results, old_index, set_new_timeout;
        old_index = index;
        set_new_timeout = true;
        if (msg === 'left' && index > 0) {
          index -= 1;
        } else if (msg === 'right' && index < categories.length - 1) {
          index += 1;
        } else if (msg === 'fire') {
          window.sfx.button2.play();
          set_delay(function() {
            return window.channel.command('scores:idle', _options);
          }, 100);
          set_new_timeout = false;
        } else {
          set_new_timeout = false;
        }
        if (set_new_timeout) {
          window.sfx.button.play();
          set_delay(handler, _options.options.IDLE_SCORES);
        }
        if (old_index !== index) {
          new_category = categories.at(index);
          new_easy_results = new Results(null, {
            category: new_category.get('id'),
            difficulty: _options.constants.DIFFICULTY_EASY
          });
          new_easy_results.on('sync', function() {
            return easy_results.reset(new_easy_results.toJSON());
          });
          new_easy_results.fetch();
          new_hard_results = new Results(null, {
            category: new_category.get('id'),
            difficulty: _options.constants.DIFFICULTY_HARD
          });
          new_hard_results.on('sync', function() {
            return hard_results.reset(new_hard_results.toJSON());
          });
          new_hard_results.fetch();
          return layout.getRegion('title').show(new TitleView({
            model: new_category
          }));
        }
      });
      return set_delay(handler, _options.options.IDLE_SCORES);
    });
    return categories.fetch();
  };
  return Mod.onStop = function() {
    window.channel.off('key');
    clear_delay();
    layout.destroy();
    categories = void 0;
    return layout = void 0;
  };
});

// Generated by CoffeeScript 1.10.0
App.module("Intro", function(Mod, App, Backbone, Marionette, $, _) {
  var HighScoreItemView, HighScoreView, NoResultsView, Result, Results, SLIDESHOW_TIMER, ScreenLayout, Slideshow, _options, handler, layout;
  Mod.startWithParent = false;
  SLIDESHOW_TIMER = 5000;
  layout = void 0;
  _options = void 0;
  Result = Backbone.Model.extend({
    defaults: {
      time: void 0,
      title: void 0
    }
  });
  Results = Backbone.Collection.extend({
    model: Result,
    url: "/api/results",
    parse: function(response, options) {
      return response.results;
    }
  });
  HighScoreItemView = Marionette.ItemView.extend({
    tagName: "tr",
    template: function(serialized_model) {
      return _.template("<td><%= title %></td>\n<td class=\"text-right\"><%= show_time() %></td>")(serialized_model);
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
    tagName: 'tr',
    className: 'loading',
    template: _.template("<td>Nahrávám…</td>")
  });
  HighScoreView = Marionette.CollectionView.extend({
    childView: HighScoreItemView,
    tagName: 'tbody',
    emptyView: NoResultsView
  });
  Slideshow = Marionette.ItemView.extend({
    template: function(serialized_model) {
      return _.template("<div class=\"fadein\">\n    <img src=\"img/titul1.png\">\n    <img src=\"img/brandenburg.jpg\">\n    <img src=\"img/titul1.png\">\n    <img src=\"img/brusel.jpg\">\n    <img src=\"img/titul1.png\">\n    <img src=\"img/london.jpg\">\n    <img src=\"img/titul1.png\">\n    <img src=\"img/budapest.jpg\">\n</div>")(serialized_model);
    }
  });
  ScreenLayout = Marionette.LayoutView.extend({
    template: _.template("<div id=\"body\">\n    <table class=\"intro\">\n        <tr class=\"row-1\">\n            <td class=\"cell-a1\"></td>\n            <td class=\"cell-a2\">\n                <div>\n                    <h2>Nejlepší časy</h2>\n                    <table></table>\n                </div>\n            </td>\n        </tr>\n        <tr class=\"row-2\">\n            <td class=\"cell-b1\">\n                <div>\n                    <h1>Chceš začít novou hru?</h1>\n                    <h3>Stiskni kterékoliv tlačítko na panelu</h3>\n                </div>\n            </td>\n            <td class=\"cell-b2\">\n                <img src=\"svg/logo.svg\">\n            </td>\n        </tr>\n    </table>\n</div>"),
    onRender: function() {
      return $('body').attr('class', 'layout-c');
    },
    regions: {
      slideshow: '.cell-a1',
      top: '.cell-a2 div table'
    }
  });
  handler = function() {
    return $('.fadein :first-child').fadeOut().next('img').fadeIn().end().appendTo('.fadein');
  };
  Mod.onStart = function(options) {
    var results;
    console.log('Intro module');
    console.log(options);
    _options = options;
    window.channel.trigger('intro:rainbow');
    layout = new ScreenLayout({
      el: make_content_wrapper()
    });
    layout.render();
    layout.getRegion('slideshow').show(new Slideshow());
    $('.fadein img:gt(0)').hide();
    results = new Results;
    layout.getRegion('top').show(new HighScoreView({
      collection: results
    }));
    results.fetch();
    window.channel.on('keypress', function() {
      window.sfx.button.play();
      return window.channel.trigger('intro:close', options);
    });
    return set_timer(handler, _options.options.INTRO_TIME_PER_SCREEN);
  };
  return Mod.onStop = function() {
    window.channel.trigger('intro:blank');
    clear_timer();
    window.channel.off('keypress');
    return layout.destroy();
  };
});

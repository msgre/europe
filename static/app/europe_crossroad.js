// Generated by CoffeeScript 1.10.0
App.module("Crossroad", function(Mod, App, Backbone, Marionette, $, _) {
  var IDLE_TIMEOUT, Item, ItemView, Items, ItemsView, _options, handler, view;
  Mod.startWithParent = false;
  IDLE_TIMEOUT = 4000;
  _options = void 0;
  view = void 0;
  Item = Backbone.Model.extend({
    defaults: {
      id: void 0,
      title: void 0,
      order: void 0,
      active: false,
      classes: void 0
    }
  });
  Items = Backbone.Collection.extend({
    model: Item,
    comparator: 'order',
    set_active: function(index) {
      var obj;
      if (this.length < 1) {
        return;
      }
      if (!index || index < 0 || index >= this.length) {
        index = 0;
      }
      obj = this.at(index);
      if (obj !== void 0) {
        this.each(function(i) {
          if (i.get('active')) {
            return i.set('active', false);
          }
        });
        obj.set('active', true);
      }
      this.trigger('change');
      return index;
    }
  });
  ItemView = Marionette.ItemView.extend({
    tagName: "div",
    attributes: function() {
      return {
        "class": "col-md-6 " + this.model.get('classes')
      };
    },
    template: function(serialized_model) {
      return _.template("<% if (active) {%><u><% } %><%= title %><% if (active) {%></u><% } %>")(serialized_model);
    }
  });
  ItemsView = Marionette.CollectionView.extend({
    childView: ItemView,
    initialize: function(options) {
      var that;
      this.index = 0;
      that = this;
      this.collection.on('change', (function(_this) {
        return function() {
          return _this.render();
        };
      })(this));
      return window.channel.on('key', function(msg) {
        var obj, old_index, set_new_timeout;
        old_index = that.index;
        set_new_timeout = true;
        if (msg === 'up' && that.index > 0) {
          that.index -= 1;
        } else if (msg === 'down' && that.index < that.collection.length - 1) {
          that.index += 1;
        } else if (msg === 'fire') {
          window.sfx.button2.play();
          obj = that.collection.at(that.index);
          window.channel.command('crossroad:close', _.extend(_options, {
            crossroad: obj.get('id')
          }));
          set_new_timeout = false;
        } else {
          set_new_timeout = false;
        }
        if (set_new_timeout) {
          window.sfx.button.play();
          set_delay(handler, IDLE_TIMEOUT);
        }
        if (old_index !== that.index) {
          return that.collection.set_active(that.index);
        }
      });
    },
    onDestroy: function() {
      this.collection.off('change');
      return window.channel.off('key');
    }
  });
  handler = function() {
    return window.channel.command('crossroad:idle', _options);
  };
  Mod.onStart = function(options) {
    var items;
    console.log('crossroad');
    _options = options;
    items = new Items();
    items.add(new Item({
      id: "game",
      title: "Hra",
      order: 10,
      active: true,
      classes: "text-right"
    }));
    items.add(new Item({
      id: "results",
      title: "Výsledky",
      order: 20,
      active: false,
      classes: "text-left"
    }));
    view = new ItemsView({
      collection: items,
      el: make_content_wrapper()
    });
    view.render();
    return set_delay(handler, IDLE_TIMEOUT);
  };
  return Mod.onStop = function() {
    clear_delay();
    return view.destroy();
  };
});

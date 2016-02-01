// Generated by CoffeeScript 1.10.0
App.module("GameMode", function(Mod, App, Backbone, Marionette, $, _) {
  var CategoryItemView, GameModeLayout, Item, ItemView, Items, ItemsView, _options, categories, choices, difficulties, handler, layout, local_channel;
  Mod.startWithParent = false;
  _options = void 0;
  layout = void 0;
  difficulties = void 0;
  categories = void 0;
  choices = void 0;
  local_channel = void 0;
  Item = Backbone.Model.extend({
    idAttribute: 'id',
    defaults: {
      id: void 0,
      title: void 0,
      active: false,
      order: 1
    }
  });
  Items = Backbone.Collection.extend({
    model: Item,
    comparator: 'order',
    parse: function(response, options) {
      return response.results;
    },
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
    },
    unset_active: function() {
      return this.each(function(i) {
        return i.set('active', false);
      });
    }
  });
  ItemView = Marionette.ItemView.extend({
    tagName: "div",
    className: "col-md-6",
    template: function(serialized_model) {
      return _.template("<% if (active) {%><u><% } %><%= title %><% if (active) {%></u><% } %>")(serialized_model);
    }
  });
  ItemsView = Marionette.CollectionView.extend({
    childView: ItemView,
    initialize: function(options) {
      this.index = 0;
      this.command = options.command;
      return this.collection.on('change', (function(_this) {
        return function() {
          return _this.render();
        };
      })(this));
    },
    set_key_handler: function() {
      return window.channel.on('key', (function(_this) {
        return function(msg) {
          var change_collection, obj, old_index, set_new_timeout;
          old_index = _this.index;
          set_new_timeout = true;
          change_collection = false;
          if (msg === 'left' && _this.index > 0) {
            _this.index -= 1;
            change_collection = true;
          } else if (msg === 'right' && _this.index < _this.collection.length - 1) {
            _this.index += 1;
            change_collection = true;
          } else if (msg === 'fire') {
            window.sfx.button2.play();
            obj = _this.collection.at(_this.index);
            _this.disable_keys();
            local_channel.trigger(_this.command, obj);
            set_new_timeout = false;
          } else {
            set_new_timeout = false;
          }
          if (set_new_timeout) {
            window.sfx.button.play();
            set_delay(handler, _options.options.IDLE_GAMEMODE);
          }
          if (change_collection && old_index !== _this.index) {
            return _this.collection.set_active(_this.index);
          }
        };
      })(this));
    },
    enable_keys: function() {
      return this.set_key_handler();
    },
    disable_keys: function() {
      return window.channel.off('key');
    },
    onDestroy: function() {
      this.collection.off('change');
      return this.disable_keys();
    },
    set_active: function() {
      this.index = 0;
      this.collection.set_active(this.index);
      return this.enable_keys();
    },
    reset: function() {
      this.disable_keys();
      this.collection.unset_active();
      return this.index = 0;
    }
  });
  CategoryItemView = Marionette.ItemView.extend({
    tagName: "div",
    className: "col-md-4 text-center well",
    template: function(serialized_model) {
      return _.template("<% if (active) {%><u><% } %><%= title %><% if (active) {%></u><% } %>")(serialized_model);
    }
  });
  GameModeLayout = Marionette.LayoutView.extend({
    template: _.template("<div class=\"row\">\n    <div class=\"col-md-3\">&nbsp;</div>\n    <div class=\"col-md-6\" id=\"difficulty\"></div>\n    <div class=\"col-md-3\">&nbsp;</div>\n</div>\n<br>\n<div class=\"row\">\n    <div class=\"col-md-12\" id=\"category\">\n    </div>\n</div>\n<br>\n<div class=\"row\">\n    <div class=\"col-md-3\">&nbsp;</div>\n    <div class=\"col-md-6\" id=\"choice\"></div>\n    <div class=\"col-md-3\">&nbsp;</div>\n</div>"),
    regions: {
      difficulty: '#difficulty',
      category: '#category',
      choice: '#choice'
    }
  });
  handler = function() {
    return window.channel.command('gamemode:idle', _options);
  };
  Mod.onStart = function(options) {
    var local_options;
    console.log('Gamemode module');
    console.log(options);
    _options = options;
    local_channel = Backbone.Radio.channel('gamemode');
    layout = new GameModeLayout({
      el: make_content_wrapper()
    });
    layout.render();
    difficulties = new Items;
    difficulties.add(new Item({
      id: _options.constants.DIFFICULTY_EASY,
      title: 'Jednoduchá',
      active: false,
      order: 1
    }));
    difficulties.add(new Item({
      id: _options.constants.DIFFICULTY_HARD,
      title: 'Obtížná',
      active: false,
      order: 2
    }));
    choices = new Items;
    choices.add(new Item({
      id: 'ok',
      title: 'Hrát',
      active: false,
      order: 1
    }));
    choices.add(new Item({
      id: 'repeat',
      title: 'Vybrat znovu',
      active: false,
      order: 2
    }));
    layout.getRegion('difficulty').show(new ItemsView({
      collection: difficulties,
      command: 'category'
    }));
    categories = new Items();
    categories.url = '/api/categories';
    layout.getRegion('category').show(new ItemsView({
      childView: CategoryItemView,
      collection: categories,
      command: 'choice'
    }));
    layout.getRegion('choice').show(new ItemsView({
      collection: choices,
      command: 'done'
    }));
    categories.fetch();
    local_options = {};
    local_channel.on('category', function(obj) {
      local_options['difficulty'] = obj.get('id');
      return layout.getRegion('category').currentView.set_active();
    });
    local_channel.on('choice', function(obj) {
      local_options['category'] = obj.get('id');
      local_options['title'] = obj.get('title');
      if (local_options.difficulty === _options.constants.DIFFICULTY_EASY) {
        local_options['time'] = obj.get('time_easy');
        local_options['penalty'] = obj.get('penalty_easy');
      } else {
        local_options['time'] = obj.get('time_hard');
        local_options['penalty'] = obj.get('penalty_hard');
      }
      return layout.getRegion('choice').currentView.set_active();
    });
    local_channel.on('done', function(obj) {
      if (obj.get('id') === 'ok') {
        return window.channel.command('gamemode:close', _.extend(_options, {
          gamemode: local_options
        }));
      } else {
        local_options = {};
        layout.getRegion('difficulty').currentView.reset();
        layout.getRegion('category').currentView.reset();
        layout.getRegion('choice').currentView.reset();
        return layout.getRegion('difficulty').currentView.set_active();
      }
    });
    layout.getRegion('difficulty').currentView.set_active();
    return set_delay(handler, _options.options.IDLE_GAMEMODE);
  };
  return Mod.onStop = function() {
    clear_delay();
    layout.destroy();
    choices = void 0;
    categories = void 0;
    difficulties = void 0;
    return local_channel.reset();
  };
});

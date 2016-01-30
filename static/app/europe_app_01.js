// Generated by CoffeeScript 1.10.0
var App;

App = new Marionette.Application();

App.on('start', function(global_options) {
  var active_module, state_handler, that;
  active_module = null;
  that = this;
  state_handler = function(new_module_name, options) {
    if (active_module !== null) {
      active_module.stop();
    }
    active_module = that.module(new_module_name);
    return active_module.start(options);
  };
  window.channel.comply('intro:start', function(options) {
    return state_handler("Intro", options);
  });
  window.channel.comply('intro:close', function(options) {
    return window.channel.command('crossroad:start', options);
  });
  window.channel.comply('crossroad:start', function(options) {
    return state_handler("Crossroad", options);
  });
  window.channel.comply('crossroad:idle', function(options) {
    return window.channel.command('intro:start', options);
  });
  window.channel.comply('crossroad:close', function(options) {
    if (options.crossroad === 'game') {
      return window.channel.command('gamemode:start', options);
    } else {
      return window.channel.command('scores:start', options);
    }
  });
  window.channel.comply('scores:start', function(options) {
    return state_handler("Scores", options);
  });
  window.channel.comply('scores:idle', function(options) {
    return window.channel.command('intro:start', options);
  });
  window.channel.comply('scores:close', function(options) {
    return window.channel.command('crossroad:start', options);
  });
  window.channel.comply('gamemode:start', function(options) {
    return state_handler("GameMode", options);
  });
  window.channel.comply('gamemode:idle', function(options) {
    return window.channel.command('intro:start', options);
  });
  window.channel.comply('gamemode:close', function(options) {
    return window.channel.command('countdown:start', options);
  });
  window.channel.comply('countdown:start', function(options) {
    return state_handler("Countdown", options);
  });
  window.channel.comply('countdown:close', function(options) {
    return window.channel.command('game:start', options);
  });
  window.channel.comply('game:start', function(options) {
    return state_handler("Game", options);
  });
  window.channel.comply('game:close', function(options) {
    return window.channel.command('result:start', options);
  });
  window.channel.comply('result:start', function(options) {
    return state_handler("Result", options);
  });
  window.channel.comply('result:close', function(options) {
    return window.channel.command('recap:start', options);
  });
  window.channel.comply('recap:start', function(options) {
    return state_handler("Recap", options);
  });
  window.channel.comply('recap:close', function(options) {
    return window.channel.command('score:start', options);
  });
  window.channel.comply('score:start', function(options) {
    return state_handler("Score", options);
  });
  window.channel.comply('score:idle', function(options) {
    return window.channel.command('intro:start', global_options);
  });
  return window.channel.command('intro:start', global_options);
});

// Generated by CoffeeScript 1.6.2
(function() {
  var CYCLE_COUNT, CYCLE_INTERVAL, STATS_UPDATE_INTERVAL, TemplateSource,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Backbone.Store.prototype.clear = function() {
    var collection, model, relation, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;

    _ref = this._collections;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      collection = _ref[_i];
      collection.unbind('relational:remove', collection._modelRemovedFromCollection);
      collection.unbind('relational:add', collection._relatedModelAdded);
      collection.unbind('relational:remove', collection._relatedModelRemoved);
      _ref1 = _.clone(collection.models);
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        model = _ref1[_j];
        if (!(model instanceof Backbone.RelationalModel)) {
          continue;
        }
        this.unregister(model);
        model._queue = null;
        _ref2 = model._relations;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          relation = _ref2[_k];
          if (relation.related) {
            relation.related.unbind('relational:add', relation.handleAddition);
            relation.related.unbind('relational:remove', relation.handleRemoval);
            relation.related.unbind('relational:reset', relation.handleReset);
            model.unbind('relational:change:' + relation.key, relation.onChange);
          }
          relation.destroy();
        }
        model._relations = [];
        model._previousAttributes = {};
      }
      collection.models = [];
    }
    this._collections = [];
    return this._reverseRelations = [];
  };

  TemplateSource = (function() {
    function TemplateSource(template_text, binding_context) {
      this.template_text = template_text;
      this.binding_context = binding_context != null ? binding_context : {};
    }

    TemplateSource.prototype.text = function() {
      if (arguments.length > 0) {
        throw 'kbi.TemplateSource: unexpected writing to template source';
      }
      return this.template_text;
    };

    return TemplateSource;

  })();

  window.TemplateEngine = (function(_super) {
    __extends(TemplateEngine, _super);

    function TemplateEngine() {
      this.allowTemplateRewriting = false;
      this.templates = {};
    }

    TemplateEngine.prototype.makeTemplateSource = function(template_name) {
      if (this.templates.hasOwnProperty(template_name)) {
        return new TemplateSource(this.templates[template_name]);
      }
      return TemplateEngine.__super__.makeTemplateSource.apply(this, arguments);
    };

    return TemplateEngine;

  })(ko.nativeTemplateEngine);

  ko.setTemplateEngine(window.template_engine = new TemplateEngine());

  STATS_UPDATE_INTERVAL = 1000;

  CYCLE_COUNT = 20;

  CYCLE_INTERVAL = 10;

  window.toFixed = function(value, precision) {
    var power;

    power = Math.pow(10, precision || 0);
    return String(Math.round(value * power) / power);
  };

  window.StatisticsViewModel = (function() {
    function StatisticsViewModel() {
      _.bindAll(this, 'open', 'close', 'clear', 'resetBaselineMemory', 'updateIfOpened');
      kb.statistics = new kb.Statistics();
      this.is_opened = ko.observable(false);
      this.observable_stats = ko.observable('none');
      this.model_events_stats = ko.observable('none');
      this.memory_stats_available = ko.observable(!!this._getHeapSize());
      this.memory_start = ko.observable(this._getHeapSize());
      this.memory_current = ko.observable(this.memory_start());
      this.memory_delta = ko.observable(0);
      this.cycle_count = ko.observable(CYCLE_COUNT);
      this.cycle_interval = ko.observable(CYCLE_INTERVAL);
      this.memory_cycle_start = ko.observable(this._getHeapSize());
      this.memory_cycle_current = ko.observable(this.memory_cycle_start());
      this.memory_cycle_delta = ko.observable(0);
      setTimeout(this.updateIfOpened, STATS_UPDATE_INTERVAL);
    }

    StatisticsViewModel.prototype.open = function() {
      if (app.mode_menu_is_opened) {
        app.mode_menu_is_opened(false);
      }
      this.app_restore_url = window.location.hash === '#no_app' ? '' : window.location.hash;
      this.is_opened(true);
      this.observable_stats(kb.statistics.registeredStatsString('None'));
      return this.model_events_stats(kb.statistics.modelEventsStatsString());
    };

    StatisticsViewModel.prototype.close = function() {
      this.is_opened(false);
      if (window.location.hash === '#no_app') {
        return window.location.hash = this.app_restore_url;
      }
    };

    StatisticsViewModel.prototype.clear = function() {
      kb.statistics.clear();
      return this.model_events_stats(kb.statistics.modelEventsStatsString());
    };

    StatisticsViewModel.prototype.cyclePages = function() {
      var available_urls, cycle_count, loadNextPage, urls,
        _this = this;

      this.cycling_pages = true;
      this.memory_cycle_start(this._getHeapSize());
      if (window.location.hash === '#no_app') {
        window.location.hash = this.app_restore_url;
      }
      available_urls = ['', 'things'].concat(_.map(app.collections.things.models, function(test) {
        return "things/" + test.id;
      }));
      urls = [];
      cycle_count = this.cycle_count();
      while (cycle_count-- > 0) {
        urls = urls.concat(available_urls);
      }
      urls = _.shuffle(urls);
      loadNextPage = function() {
        var url;

        _this.updateStats();
        if (!urls.length) {
          _this.cycling_pages = false;
          return;
        }
        url = urls.shift();
        window.location.hash = url;
        return _.delay(loadNextPage, _this.cycle_interval());
      };
      return loadNextPage();
    };

    StatisticsViewModel.prototype.resetBaselineMemory = function() {
      return this.memory_start(this._getHeapSize());
    };

    StatisticsViewModel.prototype.updateIfOpened = function() {
      if (this.is_opened()) {
        this.updateStats();
      }
      return setTimeout(this.updateIfOpened, STATS_UPDATE_INTERVAL);
    };

    StatisticsViewModel.prototype.updateStats = function() {
      var heap_size;

      this.observable_stats(kb.statistics.registeredStatsString('None'));
      this.model_events_stats(kb.statistics.modelEventsStatsString());
      heap_size = this._getHeapSize();
      this.memory_current(heap_size);
      this.memory_delta(this.memory_current() - this.memory_start());
      if (this.cycling_pages) {
        this.memory_cycle_current(heap_size);
        return this.memory_cycle_delta(this.memory_cycle_current() - this.memory_cycle_start());
      }
    };

    StatisticsViewModel.prototype._getHeapSize = function() {
      var _ref, _ref1;

      return ((_ref = window.performance) != null ? (_ref1 = _ref.memory) != null ? _ref1.usedJSHeapSize : void 0 : void 0) / (1024 * 1024);
    };

    return StatisticsViewModel;

  })();

  template_engine.templates.credits = "<div data-bind=\"visible: credits_is_opened\">\n  <div class='modal-backdrop'></div>\n  <div class=\"modal\" data-bind=\"fadeIn: credits_is_opened\"><div class=\"modal-body\">\n    <div class='nav pull-right'>\n      <a data-bind=\"click: toggleCredits\"><i class=\"icon-remove\"></i></a>\n    </div>\n\n    <div class='pagination-centered'>\n      <a href=\"http://kmalakoff.github.com/knockback/\">Knockback.js</a>\n      <span> and </span>\n      <a href=\"https://github.com/kmalakoff/knockback-reference-app/\">Knockback.js Reference App</a>\n      <br/>\n      <span> are brought to you by </span>\n      <a href=\"https://github.com/kmalakoff\">Kevin Malakoff</a>\n    </div>\n    <p></p>\n    <div class='pagination-centered'>\n      <span> With much appreciated dependencies on the </span>\n      <a href=\"http://twitter.github.com/bootstrap/\">Twitter Bootstrap</a>\n      <span>, </span>\n      <a href=\"http://knockoutjs.com/\">Knockout.js</a>\n      <span>, </span>\n      <a href=\"http://backbonejs.org/\">Backbone.js</a>\n      <span> and </span>\n      <a href=\"http://underscorejs.org/\">Underscore.js</a>\n      <span> libraries.</span>\n    </div>\n\n  </div></div>\n</div>";

  template_engine.templates.management = "<ul class=\"nav pull-right\">\n  <li><a data-bind=\"click: toggleCredits\">Credits</a></li>\n  <li class=\"dropdown\" data-bind=\"classes: {open: mode_menu_is_opened()}\">\n    <a href=\"#\" class=\"dropdown-toggle\" data-bind=\"click: toggleModeMenu\">\n      <span data-bind=\"text: 'Mode'\"></span>\n      <b class=\"caret\"></b>\n    </a>\n    <ul class=\"dropdown-menu\">\n      <li><a data-bind=\"click: goToApplication\">Tutorial</a></li>\n      <li><a data-bind=\"click: goToNavigatorsApplication\">Knockback-Navigators</a></li>\n      <li class=\"divider\"></li>\n      <li><a data-bind=\"click: statistics.open\">Statistics</a></li>\n    </ul>\n  </li>\n</ul>";

  template_engine.templates.statistics = "<div data-bind=\"visible: is_opened\">\n\n  <div class='modal-backdrop'></div>\n  <div class=\"modal\" data-bind=\"fadeIn: is_opened\"><div class=\"modal-body\">\n    <div class='nav'>\n      <a class='pull-right' data-bind=\"click: close\"><i class=\"icon-remove\"></i></a>\n    </div>\n\n    <div class='pagination-centered'>\n      <h4>Process Memory</h4>\n      <!-- ko ifnot: memory_stats_available -->\n        <p>Stats not available. Launch Chrome with option --enable-memory-info</p>\n      <!-- /ko -->\n\n      <!-- ko if: memory_stats_available -->\n        <table class=\"table table-bordered\">\n          <tr>\n            <td></td>\n            <td>Start</td>\n            <td>Current/End</td>\n            <td>Delta</td>\n          </tr>\n          <tr>\n            <td>Baseline</td>\n            <td><span data-bind=\"text: toFixed(memory_start(), 2)\"></span><button class='btn btn-mini pull-right' data-bind=\"click: resetBaselineMemory\">reset</button></td>\n            <td data-bind=\"text: toFixed(memory_current(), 2)\"></td>\n            <td data-bind=\"text: toFixed(memory_delta(), 2)\"></td>\n          </tr>\n          <tr>\n            <td>Cycle</td>\n            <td data-bind=\"text: toFixed(memory_cycle_start(), 2)\"></td>\n            <td data-bind=\"text: toFixed(memory_cycle_current(), 2)\"></td>\n            <td data-bind=\"text: toFixed(memory_cycle_delta(), 2)\"></td>\n          </tr>\n        </table>\n      <!-- /ko -->\n\n      <h4>Active kb.ViewModels and kb.CollectionObservables</h4>\n      <p data-bind=\"text: observable_stats\"></p>\n      <h4>Model Events Triggered <button class='btn btn-small pull-mini' data-bind=\"click: clear\">clear</button></h4>\n      <p data-bind=\"text: model_events_stats\"></p>\n      <form class=\"form-horizontal\">\n        <button class='btn btn-small' data-bind=\"click: cyclePages\">Cycle Pages</button>\n        <button class='btn btn-small' data-bind=\"click: kb.loadUrlFn('no_app')\">Release Application</button>\n      </form>\n      <form class=\"form-horizontal\">\n        <div class=\"control-group\">\n          <label class=\"control-label\">Cycle Count</label>\n          <div class=\"controls\">\n            <input type=\"text\" data-bind=\"value: cycle_count\"/>\n          </div>\n          <label class=\"control-label\">Cycle Interval</label>\n          <div class=\"controls\">\n            <input type=\"text\" data-bind=\"value: cycle_interval\"/>\n          </div>\n        </div>\n      </form>\n    </div>\n  </div></div>\n</div>";

}).call(this);

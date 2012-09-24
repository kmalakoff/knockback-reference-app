// Generated by CoffeeScript 1.3.3
(function() {
  var COLLECTION_LOAD_DELAY;

  if (!kb.loadUrl) {
    kb.loadUrl = function(url) {
      return window.location.hash = url;
    };
    kb.loadUrlFn = function(url) {
      return function(vm, event) {
        kb.loadUrl(url);
        (!vm || !vm.stopPropagation) || (event = vm);
        !(event && event.stopPropagation) || (event.stopPropagation(), event.preventDefault());
      };
    };
  }

  ko.bindingHandlers['classes'] = {
    update: function(element, value_accessor) {
      var key, state, _ref;
      _ref = ko.utils.unwrapObservable(value_accessor());
      for (key in _ref) {
        state = _ref[key];
        $(element)[ko.utils.unwrapObservable(state) ? 'addClass' : 'removeClass'](key);
      }
    }
  };

  ko.bindingHandlers['spinner'] = {
    init: function(element, value_accessor) {
      element.spinner = new Spinner(ko.utils.unwrapObservable(value_accessor())).spin(element);
      return ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
        !element.spinner || (element.spinner.stop(), element.spinner = null);
      });
    }
  };

  ko.bindingHandlers['fadeIn'] = {
    update: function(element, value_accessor) {
      !ko.utils.unwrapObservable(value_accessor()) || $(element).hide().fadeIn(500);
    }
  };

  window.Thing = Backbone.RelationalModel.extend({
    url: function() {
      return "things/" + (this.get('id'));
    },
    relations: [
      {
        type: 'HasMany',
        key: 'my_things',
        includeInJSON: 'id',
        relatedModel: 'Thing',
        reverseRelation: {
          key: 'my_owner',
          includeInJSON: 'id'
        }
      }
    ]
  });

  window.ThingCollection = Backbone.Collection.extend({
    localStorage: new Store('things-knockback'),
    model: Thing
  });

  COLLECTION_LOAD_DELAY = 500;

  Backbone.history || (Backbone.history = new Backbone.History());

  window.ApplicationViewModel = (function() {

    function ApplicationViewModel() {
      var _this = this;
      window.app = this;
      _.bindAll(this, 'afterBinding');
      this.collections = {
        things: new ThingCollection()
      };
      this.things_links = kb.collectionObservable(app.collections.things, {
        view_model: ThingLinkViewModel,
        filters: this.id,
        sort_attribute: 'name'
      });
      this.deleteAllThings = function() {
        var model, _i, _len, _ref;
        _ref = _.clone(_this.collections.things.models);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          model.destroy();
        }
      };
      this.saveAllThings = function() {
        var model, _i, _len, _ref;
        _ref = _this.collections.things.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          model.save();
        }
      };
      _.delay((function() {
        return _this.collections.things.fetch();
      }), COLLECTION_LOAD_DELAY);
      this.active_url = ko.observable(window.location.hash);
      this.nav_items = ko.observableArray([
        {
          name: 'Welcome',
          url: '',
          goTo: function(vm) {
            return kb.loadUrl(vm.url);
          }
        }, {
          name: 'Manage Things',
          url: '#things',
          goTo: function(vm) {
            return kb.loadUrl(vm.url);
          }
        }
      ]);
      this.credits_is_opened = ko.observable(false);
      this.toggleCredits = function() {
        return _this.credits_is_opened(!_this.credits_is_opened());
      };
      this.mode_menu_is_opened = ko.observable(false);
      this.toggleModeMenu = function() {
        return _this.mode_menu_is_opened(!_this.mode_menu_is_opened());
      };
      this.statistics = new StatisticsViewModel();
      this.goToApplication = function() {
        if (window.location.pathname.search('index_navigators.html') >= 0) {
          return window.location.pathname = window.location.pathname.replace('index_navigators.html', 'index.html');
        }
      };
      this.goToNavigatorsApplication = function() {
        if (window.location.pathname.search('index.html') >= 0) {
          return window.location.pathname = window.location.pathname.replace('index.html', 'index_navigators.html');
        }
      };
    }

    ApplicationViewModel.prototype.afterBinding = function(vm, el) {
      var _this = this;
      this.router = this.createRouter(el);
      Backbone.history.bind('route', function() {
        return _this.active_url(window.location.hash);
      });
      this.router.route('no_app', null, function() {
        _this.loadPage(null);
        return Backbone.Relational.store.clear();
      });
      return Backbone.history.start({
        hashChange: true
      });
    };

    ApplicationViewModel.prototype.loadPage = function(el) {
      if (this.active_el) {
        ko.removeNode(this.active_el);
      }
      if (!(this.active_el = el)) {
        return;
      }
      $('.pane-navigator.page').append(el);
      return $(el).addClass('active');
    };

    ApplicationViewModel.prototype.createRouter = function() {
      var router,
        _this = this;
      router = new Backbone.Router();
      router.route('', null, function() {
        return _this.loadPage(kb.renderTemplate('home', {}));
      });
      router.route('things', null, function() {
        _this.loadPage(kb.renderTemplate('things_page', new ThingsPageViewModel()));
        return app.things_links.filters(null);
      });
      router.route('things/:id', null, function(id) {
        var model, view_model;
        model = _this.collections.things.get(id) || new Backbone.ModelRef(_this.collections.things, id);
        _this.loadPage(kb.renderTemplate('thing_page', view_model = new ThingViewModel(model)));
        return app.things_links.filters(view_model.id);
      });
      return router;
    };

    return ApplicationViewModel;

  })();

  window.ThingViewModel = kb.ViewModel.extend({
    constructor: function(model, options) {
      var previous_model,
        _this = this;
      _.bindAll(this, 'onSubmit', 'onDelete', 'onStartEdit', 'onCancelEdit');
      kb.ViewModel.prototype.constructor.call(this, model, {
        requires: ['id', 'name', 'caption', 'my_owner', 'my_things'],
        factories: {
          'my_owner': ThingLinkViewModel,
          'my_things': ThingCollectionObservable
        },
        options: options
      });
      this.selected_things = kb.collectionObservable(new Backbone.Collection(), {
        options: app.things_links.shareOptions()
      });
      this.edit_mode = ko.observable();
      this.is_loaded = ko.observable();
      previous_model = null;
      this._syncViewToModel = ko.computed(function() {
        var changed, current_model;
        if ((current_model = _this.model())) {
          if ((changed = previous_model !== current_model)) {
            previous_model = current_model;
            _this.start_attributes = current_model.toJSON();
            _this.edit_mode(current_model.isNew());
          }
          if (_this.edit_mode()) {
            _this.selected_things.collection().reset(current_model.get('my_things').models);
          }
        }
        return _this.is_loaded(!!current_model);
      });
    },
    onSubmit: function() {
      var model;
      if (!(model = this.model())) {
        return;
      }
      model.get('my_things').reset(this.selected_things.collection().models);
      if (model.isNew()) {
        app.collections.things.add(model);
        this.model(new Thing());
      }
      model.save(null, {
        success: function() {
          return _.defer(app.saveAllThings);
        }
      });
      return this.edit_mode(false);
    },
    onDelete: function() {
      var model;
      if (!(model = this.model())) {
        return;
      }
      if (model.isNew()) {
        this.model(new Thing());
        return;
      }
      model.destroy({
        success: function() {
          return _.defer(app.saveAllThings);
        }
      });
      return kb.loadUrl('things');
    },
    onStartEdit: function() {
      return this.edit_mode(true);
    },
    onCancelEdit: function() {
      var model;
      if (!(model = this.model())) {
        return;
      }
      model.clear();
      model.set(this.start_attributes);
      return this.edit_mode(false);
    }
  });

  window.ThingCollectionObservable = kb.CollectionObservable.extend({
    constructor: function(collection, options) {
      return kb.CollectionObservable.prototype.constructor.call(this, collection, {
        view_model: ThingViewModel,
        options: options
      });
    }
  });

  window.ThingLinkViewModel = kb.ViewModel.extend({
    constructor: function(model, options) {
      kb.ViewModel.prototype.constructor.call(this, model, {
        keys: ['id', 'name'],
        options: options
      });
    }
  });

  window.ThingsPageViewModel = function() {
    this.things = kb.collectionObservable(app.collections.things, {
      view_model: ThingViewModel
    });
    this.new_thing = new ThingViewModel(new Thing());
  };

}).call(this);

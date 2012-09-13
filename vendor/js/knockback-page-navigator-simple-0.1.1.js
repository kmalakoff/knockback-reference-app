// Generated by CoffeeScript 1.3.3

/*
  knockback-navigators.js 0.1.1
  (c) 2012 Kevin Malakoff.
  KnockbackNavigators.js is freely distributable under the MIT license.
  See the following for full license details:
    https://github.com/kmalakoff/knockback-navigators/blob/master/LICENSE
  Dependencies: None
*/


(function() {
  var bind, kb, ko, throwUnexpected, _;

  throwUnexpected = function(instance, message) {
    throw "" + instance.constructor.name + ": " + message + " is unexpected";
  };

  try {
    kb = typeof require !== 'undefined' ? require('knockback') : this.kb;
  } catch (e) {
    ({});
  }

  this.kb = kb || (kb = {});

  try {
    ko = typeof require !== 'undefined' ? require('knockout') : this.ko;
  } catch (e) {
    ({});
  }

  ko || (ko = {});

  if (!ko.observable) {
    ko.dataFor = function(el) {
      return null;
    };
    ko.removeNode = function(el) {
      return $(el).remove();
    };
    ko.observable = function(initial_value) {
      var value;
      value = initial_value;
      return function(new_value) {
        if (arguments.length) {
          return value = new_value;
        } else {
          return value;
        }
      };
    };
    ko.observableArray = function(initial_value) {
      var observable;
      observable = ko.observable(arguments.length ? initial_value : []);
      observable.push = function() {
        return observable().push.apply(observable(), arguments);
      };
      observable.pop = function() {
        return observable().pop.apply(observable(), arguments);
      };
      return observable;
    };
  }

  _ = this._ ? this._ : (kb._ ? kb._ : {});

  if (!_.bindAll) {
    bind = function(obj, fn_name) {
      var fn;
      fn = obj[fn_name];
      return obj[fn_name] = function() {
        return fn.apply(obj, arguments);
      };
    };
    _.bindAll = function(obj, fn_name1) {
      var fn_name, _i, _len, _ref;
      _ref = Array.prototype.slice.call(arguments, 1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        fn_name = _ref[_i];
        bind(obj, fn_name);
      }
    };
  }

  if (!_.isElement) {
    _.isElement = function(obj) {
      return obj && (obj.nodeType === 1);
    };
  }

  if (this.x$) {
    this.$ = this.x$;
  }

  kb.PageNavigatorSimple = (function() {

    function PageNavigatorSimple(el, options) {
      this.options = options != null ? options : {};
      el || throwMissing(this, 'el');
      _.bindAll(this, 'hasHistory', 'activePage', 'activeUrl', 'loadPage', 'dispatcher');
      this.el = el.length ? el[0] : el;
      $(this.el).addClass('page');
      this.active_page = ko.observable();
    }

    PageNavigatorSimple.prototype.destroy = function() {
      this.destroyed = true;
      this.el = null;
      return this.active_page = null;
    };

    PageNavigatorSimple.prototype.hasHistory = function() {
      return false;
    };

    PageNavigatorSimple.prototype.activePage = function() {
      return this.active_page();
    };

    PageNavigatorSimple.prototype.activeUrl = function() {
      var active_page;
      if ((active_page = this.active_page())) {
        return active_page.url;
      } else {
        return null;
      }
    };

    PageNavigatorSimple.prototype.loadPage = function(info) {
      var active_page, previous_page;
      if (!info) {
        throw 'missing page info';
      }
      if (this.activeUrl() === window.location.hash) {
        active_page = this.activePage();
        active_page.el || pane_navigator.ensureElement(active_page);
        if (active_page.el.parentNode !== this.el) {
          $(this.el).append(active_page.el);
        }
        return active_page;
      }
      if ((previous_page = this.activePage())) {
        previous_page.destroy(this.options);
      }
      active_page = new kb.Pane(info, window.location.hash);
      active_page.activate(this.el);
      this.active_page(active_page);
      return active_page;
    };

    PageNavigatorSimple.prototype.dispatcher = function(callback) {
      var page_navigator;
      page_navigator = this;
      return function() {
        if (page_navigator.destroyed) {
          return;
        }
        return page_navigator.routeTriggered(this, callback, arguments);
      };
    };

    PageNavigatorSimple.prototype.routeTriggered = function(router, callback, args) {
      var active_page;
      if ((active_page = this.activePage()) && (active_page.url === window.location.hash)) {
        return this.loadPage(active_page);
      } else if (callback) {
        return callback.apply(router, args);
      }
    };

    return PageNavigatorSimple;

  })();

  if (typeof exports !== 'undefined') {
    exports.PageNavigatorSimple = kb.PageNavigatorSimple;
  }

  if (ko && ko.bindingHandlers) {
    ko.bindingHandlers['PageNavigatorSimple'] = {
      'init': function(element, value_accessor, all_bindings_accessor, view_model) {
        var options, page_navigator;
        options = ko.utils.unwrapObservable(value_accessor());
        if (!('no_remove' in options)) {
          options.no_remove = true;
        }
        page_navigator = new kb.PageNavigatorSimple(element, options);
        kb.utils.wrappedPageNavigator(element, page_navigator);
        ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
          if (typeof options.unloaded === "function") {
            options.unloaded(page_navigator);
          }
          return kb.utils.wrappedPageNavigator(element, null);
        });
        return typeof options.loaded === "function" ? options.loaded(page_navigator) : void 0;
      }
    };
  }

  kb.override_transitions = [];

  kb.popOverrideTransition = function() {
    if (kb.override_transitions.length) {
      return kb.override_transitions.pop();
    } else {
      return null;
    }
  };

  kb.loadUrl = function(url, transition) {
    kb.override_transitions.push(transition);
    return window.location.hash = url;
  };

  kb.loadUrlFn = function(url, transition) {
    return function(vm, event) {
      kb.loadUrl(url, transition);
      if (event && event.currentTarget) {
        event.stopPropagation();
      }
      return false;
    };
  };

  kb.utils || (kb.utils = {});

  kb.utils.wrappedPageNavigator = function(el, value) {
    if ((arguments.length === 1) || (el.__kb_page_navigator === value)) {
      return el.__kb_page_navigator;
    }
    if (el.__kb_page_navigator) {
      el.__kb_page_navigator.destroy();
    }
    el.__kb_page_navigator = value;
    return value;
  };

  kb.Pane = (function() {

    function Pane(info, url) {
      if (arguments.length) {
        this.url = url;
      }
      this.setInfo(info);
    }

    Pane.prototype.destroy = function(options) {
      if (options == null) {
        options = {};
      }
      this.deactivate(options);
      this.removeElement(options, true);
      this.create = null;
      return this.el = null;
    };

    Pane.prototype.setInfo = function(info) {
      var key, value;
      if (_.isElement(info)) {
        this.el = info;
      } else {
        for (key in info) {
          value = info[key];
          this[key] = value;
        }
      }
      if (this.el) {
        $(this.el).addClass('pane');
      }
      return this;
    };

    Pane.prototype.ensureElement = function() {
      var info;
      if (this.el) {
        return this.el;
      }
      if (!this.create) {
        throw 'expecting create';
      }
      info = this.create.apply(this, this.args);
      if (info) {
        this.setInfo(info);
      }
      if (!this.el) {
        throw 'expecting el';
      }
      if (this.el) {
        $(this.el).addClass('pane');
      }
      return this;
    };

    Pane.prototype.removeElement = function(options, force) {
      if (options == null) {
        options = {};
      }
      if (!this.el) {
        return this;
      }
      if (options.no_remove) {
        return;
      }
      if (force || (this.create && !options.no_destroy)) {
        ko.removeNode(this.el);
        this.el = null;
      } else if (this.el.parentNode) {
        this.el.parentNode.removeChild(this.el);
      }
      return this;
    };

    Pane.prototype.activate = function(el) {
      var view_model;
      this.ensureElement();
      if ($(this.el).hasClass('active')) {
        return;
      }
      $(this.el).addClass('active');
      if (this.el.parentNode !== el) {
        $(el).append(this.el);
      }
      view_model = this.view_model ? this.view_model : ko.dataFor(this.el);
      if (view_model && view_model.activate) {
        view_model.activate(this);
      }
      return this;
    };

    Pane.prototype.deactivate = function(options) {
      var view_model;
      if (options == null) {
        options = {};
      }
      if (!(this.el && $(this.el).hasClass('active'))) {
        return;
      }
      $(this.el).removeClass('active');
      view_model = this.view_model ? this.view_model : ko.dataFor(this.el);
      if (view_model && view_model.deactivate) {
        view_model.deactivate(this);
      }
      this.removeElement(options);
      return this;
    };

    return Pane;

  })();

  if (typeof exports !== 'undefined') {
    exports.Pane = kb.Pane;
  }

}).call(this);
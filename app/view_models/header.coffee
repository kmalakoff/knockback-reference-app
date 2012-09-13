class window.HeaderViewModel
  constructor: (@mode) ->
    @active_url = ko.observable(window.location.hash)
    @setActiveUrl = => @active_url(window.location.hash)
    Backbone.history.bind('route', @setActiveUrl)

    # nav items
    @nav_items = ko.observableArray([
      {name: 'Welcome',       url: '',        goTo: (vm) -> kb.loadUrl(vm.url)},
      {name: 'Manage Things', url: 'things',  goTo: (vm) -> kb.loadUrl(vm.url)}
    ])

    @credits_is_opened = ko.observable(false)
    @toggleCredits = => @credits_is_opened(not @credits_is_opened())

    @mode_menu_is_opened = ko.observable(false)
    @toggleModeMenu = => @mode_menu_is_opened(not @mode_menu_is_opened())

  destroy: ->
    Backbone.history.unbind('route', @setActiveUrl)
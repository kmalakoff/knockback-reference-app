COLLECTION_LOAD_DELAY = 500

# initialization
Backbone.history or= new Backbone.History() # initialize history so it is guaranteed to exist

class window.ApplicationViewModel
  constructor: ->
    window.app = @ # publish ourselves so can be accessed elsewhere
    _.bindAll(@, 'afterBinding') # bind functions so they can be called from templates

    #########################
    # Models
    #########################
    @collections =
      things: new ThingCollection()
    @things_links = kb.collectionObservable(app.collections.things, {view_model: ThingLinkViewModel, filters: @id, sort_attribute: 'name'})
    @deleteAllThings = => model.destroy() for model in _.clone(@collections.things.models); return
    @saveAllThings = => model.save() for model in @collections.things.models; return

    #########################
    # Header
    #########################
    @active_url = ko.observable(window.location.hash)
    @nav_items = ko.observableArray([
      {name: 'Welcome',       url: '',        goTo: (vm) -> kb.loadUrl(vm.url)},
      {name: 'Manage Things', url: '#things',  goTo: (vm) -> kb.loadUrl(vm.url)}
    ])

    @credits_is_opened = ko.observable(false)
    @toggleCredits = => @credits_is_opened(not @credits_is_opened())

    @mode_menu_is_opened = ko.observable(false)
    @toggleModeMenu = => @mode_menu_is_opened(not @mode_menu_is_opened())

    #########################
    # App Management
    #########################
    @statistics = new StatisticsViewModel()
    @goToApplication = => window.location.pathname = window.location.pathname.replace('index_navigators.html', 'index.html') if window.location.pathname.search('index_navigators.html') >= 0
    @goToNavigatorsApplication = => window.location.pathname = window.location.pathname.replace('index.html', 'index_navigators.html') if window.location.pathname.search('index.html') >= 0

    return

  #########################
  # Routing
  #########################

  # start routing after this ViewModel is bound
  afterBinding: (vm, el) ->
    @router = @createRouter(el)
    Backbone.history.bind('route', => @active_url(window.location.hash)) # synchronize active url
    Backbone.history.start({hashChange: true})

  loadApp: (load) ->
    return if @is_loaded is load # already in the state
    if @is_loaded = load
      _.delay((=> @collections.things.fetch()), COLLECTION_LOAD_DELAY) # load things collection late (to demonstrate Backbone.ModelRef)
    else
      @collections.things.reset()
      kb.utils.wrappedStore(@things_links).clear() # release the store
      Backbone.Relational.store.clear() # clean up caches so can check used memory

  loadPage: (el) ->
    ko.removeNode(@active_el) if @active_el # remove previous
    @loadApp(!!el)
    return unless @active_el = el # no new page
    $('.pane-navigator.page').append(el)
    $(el).addClass('active')

  createRouter: ->
    router = new Backbone.Router()

    router.route('', null, => @loadPage(kb.renderTemplate('home', {})))

    router.route('things', null, =>
      @loadPage(kb.renderTemplate('things_page', new ThingsPageViewModel()))
      app.things_links.filters(null) # remove filter
    )

    router.route('things/:id', null, (id) =>
      model = @collections.things.get(id) or new Backbone.ModelRef(@collections.things, id)
      @loadPage(kb.renderTemplate('thing_page', view_model = new ThingViewModel(model)))
      app.things_links.filters(view_model.id) # add filter
    )

    router.route('no_app', null, => @loadPage(null))

    return router
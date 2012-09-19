COLLECTION_LOAD_DELAY = 500

# initialization
Backbone.history or= new Backbone.History() # initialize history so it is guaranteed to exist

class window.AppViewModel
  constructor: ->
    window.app = @ # publish ourselves so can be accessed elsewhere
    _.bindAll(@, 'deleteAllThings', 'saveAllThings') # bind functions so they can be called from templates

    #########################
    # Models
    #########################
    @collections =
      things: new ThingCollection()
    _.delay((=> @collections.things.fetch()), COLLECTION_LOAD_DELAY) # load things collection (later to demonstrate Backbone.ModelRef)

    #########################
    # Routing
    #########################
    @loadPage = (el) ->
      ko.removeNode(@active_el) if @active_el # remove previous
      return unless @active_el = el # no new page
      $('.pane-navigator.page').append(el)
      $(el).addClass('active')

    unless @router # the router may have been set up by a derived class
      @router = new Backbone.Router()
      @router.route('', null, => @loadPage(kb.renderTemplate('home', {})))
      @router.route('things', null, => @loadPage(kb.renderTemplate('things_page', new ThingsPageViewModel())))
      @router.route('things/:id', null, (id) =>
        model = @collections.things.get(id) or new Backbone.ModelRef(@collections.things, id)
        @loadPage(kb.renderTemplate('thing_page', new ThingCellViewModel(model)))
      )
    @afterBinding = -> Backbone.history.start({hashChange: true}) # start routing after this ViewModel is bound

    #########################
    # Header
    #########################
    @active_url = ko.observable(window.location.hash)
    @router.bind('route', => @active_url(window.location.hash))
    @nav_items = ko.observableArray([
      {name: 'Welcome',       url: '',        goTo: (vm) -> kb.loadUrl(vm.url)},
      {name: 'Manage Things', url: 'things',  goTo: (vm) -> kb.loadUrl(vm.url)}
    ])

    @credits_is_opened = ko.observable(false)
    @toggleCredits = => @credits_is_opened(not @credits_is_opened())

    @mode_menu_is_opened = ko.observable(false)
    @toggleModeMenu = => @mode_menu_is_opened(not @mode_menu_is_opened())

    #########################
    # App Management
    #########################
    @statistics = new StatisticsViewModel()
    @router.route('no_app', null, => @loadPage(null))

    # # close the mode selector
    # @view_model.header.mode_menu_is_opened(false) if @view_model and @view_model.header

    # # go to check memory mode
    # if mode.no_app
    #   @view_models.statistics.open() # open stats
    #   (@view_model = null; ko.removeNode(@el); @el = null) if @view_model
    #   Backbone.Relational.store.clear() # clean up caches
    #   return

    # # save the mode and clean up previous state
    # (@view_model = null; ko.removeNode(@el); @el = null) if @view_model

    # # tutorial or extended version
    # @view_model = if mode.tutorial then new ApplicationViewModel() else new ApplicationViewModelExtended(mode)
    # @el = kb.renderTemplate('app', @view_model, {afterRender: @view_model.afterRender})
    # $('body').append(@el)

    # # close statistics after creating the new view model (statistics close tries to re-create the latest app mode assuming the user closed the modal)
    # @view_models.statistics.close()

  deleteAllThings: ->
    model.destroy() for model in _.clone(@collections.things.models)
    return

  saveAllThings: ->
    (model.save() if model.hasChanged()) for model in @collections.things.models
    return
kb = if not @kb and (typeof(require) != 'undefined') then require('knockback') else @kb
_ = kb._; Backbone = kb.Backbone

class window.Application
  constructor: ->
    # bind functions so they can be called from templates
    _.bindAll(@, 'deleteAllThings', 'goToThings', 'setMode')
    @view_models = {}
    @collections = {}

  initialize: ->
    ko.setTemplateEngine(new TemplateEngine()) # register the template engine that holds strings for non-tutorial views
    Backbone.history or= new Backbone.History() # initialize history s it is guaranteed to exist

    # create the things
    @collections.things = new ThingCollection()

    # create and bind statistics element
    @view_models.statistics = new StatisticsViewModel()
    @statistics_el = kb.renderAutoReleasedTemplate('statistics', @view_models.statistics)
    $('body').append(@statistics_el)

    # set the current mode
    @setMode({tutorial: true})

  destroy: ->
    ko.releaseNode(@statistics_el); @statistics_el = @view_models = null

  goToThings: ->
    window.location.hash = 'things'

  deleteAllThings: ->
    model.destroy() for model in _.clone(@collections.things.models)
    @

  setMode: (mode={}) ->

    # close the mode selector
    @view_model.header.mode_menu_is_opened(false) if @view_model and @view_model.header

    # go to check memory mode
    if mode.no_app
      @view_models.statistics.open() # open stats
      (@view_model = null; ko.removeNode(@el); @el = null) if @view_model
      Backbone.Relational.store.clear() # clean up caches
      return

    # save the mode and clean up previous state
    @mode = mode
    (@view_model = null; ko.removeNode(@el); @el = null) if @view_model

    # tutorial or extended version
    @view_model = if mode.tutorial then new ApplicationViewModel() else new ApplicationViewModelExtended(mode)
    @el = kb.renderAutoReleasedTemplate('app', @view_model, {afterRender: @view_model.afterRender})
    $('body').append(@el)

    # close statistics after creating the new view model (statistics close tries to re-create the latest app mode assuming the user closed the modal)
    @view_models.statistics.close()

    # start or update routing
    if Backbone.History.started then Backbone.history.loadUrl(window.location.hash) else Backbone.history.start({hashChange: true})
    @
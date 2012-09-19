STATS_UPDATE_INTERVAL = 1000
CYCLE_COUNT = 20
CYCLE_INTERVAL = 10

window.toFixed = (value, precision) ->
  power = Math.pow(10, precision || 0);
  return String(Math.round(value * power) / power);

class window.StatisticsViewModel
  constructor: ->
    # bind functions so they can be called from templates
    _.bindAll(@, 'open', 'close', 'clear', 'resetBaselineMemory', 'updateIfOpened')

    kb.statistics = new kb.Statistics()
    @is_opened = ko.observable(false)
    @observable_stats = ko.observable('none')
    @model_events_stats = ko.observable('none')

    # baseline stats
    @memory_stats_available = ko.observable(!!@_getHeapSize())
    @memory_start = ko.observable(@_getHeapSize())
    @memory_current = ko.observable(@memory_start())
    @memory_delta = ko.observable(0)

    # page cycling stats
    @cycle_count = ko.observable(CYCLE_COUNT)
    @cycle_interval = ko.observable(CYCLE_INTERVAL)
    @memory_cycle_start = ko.observable(@_getHeapSize())
    @memory_cycle_current = ko.observable(@memory_cycle_start())
    @memory_cycle_delta = ko.observable(0)

    # set a timer to update stats
    setTimeout(@updateIfOpened, STATS_UPDATE_INTERVAL)

  open: ->
    app.mode_menu_is_opened(false) if app.mode_menu_is_opened # close the mode select
    @app_restore_url = if window.location.hash is '#no_app' then '' else window.location.hash # save the open fragment
    @is_opened(true)

    # currently existing observables
    @observable_stats(kb.statistics.registeredStatsString('None'))

    # events triggered
    @model_events_stats(kb.statistics.modelEventsStatsString())

  close: ->
    @is_opened(false)
    window.location.hash = @app_restore_url if window.location.hash is '#no_app' # restore the application page

  clear: ->
    kb.statistics.clear()
    @model_events_stats(kb.statistics.modelEventsStatsString())

  cyclePages: ->
    # start stats
    @cycling_pages = true
    @memory_cycle_start(@_getHeapSize())

    # load the app if it isn't already
    (app.setMode(app.mode); @is_opened(true)) unless app.view_model

    # make the randomized list of urls to cycle through
    available_urls = ['', 'things'].concat(_.map(app.collections.things.models, (test) -> "things/#{test.id}"))
    urls = []
    cycle_count = @cycle_count()
    urls = urls.concat(available_urls) while (cycle_count-- > 0)
    urls = _.shuffle(urls)

    loadNextPage = =>
      @updateStats()
      unless urls.length # done
        @cycling_pages = false
        return

      # load next page
      url = urls.shift()
      window.location.hash = url
      _.delay(loadNextPage, @cycle_interval())
    loadNextPage()

  resetBaselineMemory: ->
    @memory_start(@_getHeapSize())

  updateIfOpened: ->
    @updateStats() if @is_opened()
    setTimeout(@updateIfOpened, STATS_UPDATE_INTERVAL)

  updateStats: ->
    @observable_stats(kb.statistics.registeredStatsString('None'))
    @model_events_stats(kb.statistics.modelEventsStatsString())

    heap_size = @_getHeapSize()
    @memory_current(heap_size)
    @memory_delta(@memory_current()-@memory_start())

    if @cycling_pages
      @memory_cycle_current(heap_size)
      @memory_cycle_delta(@memory_cycle_current()-@memory_cycle_start())

  _getHeapSize: -> return window.performance?.memory?.usedJSHeapSize/(1024*1024)
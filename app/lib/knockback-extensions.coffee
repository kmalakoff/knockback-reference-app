unless kb.loadUrl
  kb.loadUrl = (url) -> window.location.hash = url

  kb.loadUrlFn = (url) ->
    return (vm, event) ->
      kb.loadUrl(url)

      # stop the event handling chains
      (not vm or not vm.stopPropagation) or (event = vm) # not a ViewModel, but an event
      if event and event.stopPropagation
        event.stopPropagation()
        event.preventDefault()

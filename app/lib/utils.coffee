window.utils or= {}

window.utils.decrementClampedObservable = (observable) ->
  value = observable()
  observable(--value) if (value > 0) # clamp to 0
  return value
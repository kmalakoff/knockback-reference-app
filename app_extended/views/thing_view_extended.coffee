window.ThingViewExtendedView = """
  <div class='row'>

    <!-- * MY INFORMATION * -->
    <div class='span3'>
      <legend data-bind="text: name"></legend>
      <p data-bind="text: caption"></p>
    </div>

    <!-- * MY THINGS INFORMATION WITH EMBEDDED SLIDING PANE * -->
    <div class='span8'>
      <legend data-bind="text: 'My Things (' + my_things().length + ')'"></legend>

      <button class='btn btn-small' data-bind="click: kb.previousPane"><i class='icon-step-backward'></i></button>
      <button class='btn btn-small' data-bind="click: kb.nextPane"><i class='icon-step-forward'></i></button>

      <div style='position: relative; min-height: 180px'>
        <div class='pane-navigator' data-bind="PaneNavigator: {transition: 'NavigationSlide'}, foreach: my_things">
          <div class='pane'>
            <div class='cell thumbnail form-actions' data-bind="click: goTo, template: {name: 'thing_view', data: $data}"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
"""
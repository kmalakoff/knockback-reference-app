window.AppManagementView = """
  <ul class="nav pull-right">
    <li><a data-bind="click: toggleCredits">Credits</a></li>
    <li class="dropdown" data-bind="classes: {open: mode_menu_is_opened()}">
      <a href="#" class="dropdown-toggle" data-bind="click: toggleModeMenu">
        <span data-bind="text: 'Demo Mode (' + mode + ')'"></span>
        <b class="caret"></b>
      </a>
      <ul class="dropdown-menu">
        <li><a data-bind="click: function(){app.setMode({tutorial: true});}">Tutorial</a></li>
        <li class="divider"></li>
        <li class="nav-header">Knockback Navigators</li>
        <li><a data-bind="click: function(){app.setMode({has_panes: false, no_history: true});}">Panes</a></li>
        <li><a data-bind="click: function(){app.setMode({has_panes: true, no_history: true});}">Page Animations</a></li>
        <li><a data-bind="click: function(){app.setMode({has_panes: true, no_history: false});}">Page Animations + History</a></li>
        <li><a data-bind="click: function(){app.setMode({has_panes: true, no_history: false, no_cache: true});}">Page Animations + History + No Cache</a></li>
        <li class="divider"></li>
        <li><a data-bind="click: app.view_models.statistics.open">Statistics</a></li>
      </ul>
    </li>
  </ul>
"""
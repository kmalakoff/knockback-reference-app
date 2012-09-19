template_engine.templates.management = """
  <ul class="nav pull-right">
    <li><a data-bind="click: toggleCredits">Credits</a></li>
    <li class="dropdown" data-bind="classes: {open: mode_menu_is_opened()}">
      <a href="#" class="dropdown-toggle" data-bind="click: toggleModeMenu">
        <span data-bind="text: 'Mode'"></span>
        <b class="caret"></b>
      </a>
      <ul class="dropdown-menu">
        <li><a data-bind="click: function(){app.setMode({tutorial: true});}">Tutorial</a></li>
        <li><a data-bind="click: function(){app.setMode({tutorial: true});}">Knockback-Navigators</a></li>
        <li class="divider"></li>
        <li><a data-bind="click: statistics.open">Statistics</a></li>
      </ul>
    </li>
  </ul>
"""
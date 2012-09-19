template_engine.templates.credits = """
  <div data-bind="visible: credits_is_opened">
    <div class='modal-backdrop'></div>
    <div class="modal" data-bind="fadeIn: credits_is_opened"><div class="modal-body">
      <div class='nav'>
        <a class='pull-right' data-bind="click: toggleCredits"><i class="icon-remove"></i></a>
      </div>

      <div class='pagination-centered'>
        <a href="http://kmalakoff.github.com/knockback/">Knockback.js</a>
        <span> and </span>
        <a href="https://github.com/kmalakoff/knockback-reference-app/">Knockback.js Reference App</a>
        <br/>
        <span> are brought to you by </span>
        <a href="https://github.com/kmalakoff">Kevin Malakoff</a>
      </div>
      <p></p>
      <div class='pagination-centered'>
        <span> With much appreciated dependencies on the </span>
        <a href="http://twitter.github.com/bootstrap/">Twitter Bootstrap</a>
        <span>, </span>
        <a href="http://knockoutjs.com/">Knockout.js</a>
        <span>, </span>
        <a href="http://backbonejs.org/">Backbone.js</a>
        <span> and </span>
        <a href="http://underscorejs.org/">Underscore.js</a>
        <span> libraries.</span>
      </div>

    </div></div>
  </div>
"""
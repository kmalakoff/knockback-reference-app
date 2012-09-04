module.exports =
  app:
    join: 'app.js'
    output: '..'
    directories: 'app'

  app_extended:
    join: 'app_extended.js'
    output: '..'
    directories: 'app_extended'

  _postinstall:
    commands: [
      # knockback dependencies
      'cp -v knockback/knockback-core-stack.js vendor/js/knockback-core-stack.js'

      # knockback optional libraries
      'cp -v backbone-modelref vendor/js/backbone-modelref.js'
      'cp -v backbone-relational vendor/js/backbone-relational.js'
      'cp -v knockback/lib/knockback-statistics.js vendor/js/knockback-statistics.js'

      'cp -v knockback-navigators/knockback-page-navigator-panes.js vendor/js/knockback-page-navigator-panes.js'
      'cp -v knockback-navigators/knockback-page-navigator-simple.js vendor/js/knockback-page-navigator-simple.js'
      'cp -v knockback-navigators/lib/knockback-sample-transitions.js vendor/js/knockback-sample-transitions.js'
    ]
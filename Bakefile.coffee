module.exports =
  app:
    join: 'app.js'
    output: '..'
    directories: 'app'

  app_navigators:
    join: 'app-navigators.js'
    output: '..'
    directories: 'app_navigators'

  app_management:
    join: 'app-management.js'
    output: '..'
    directories: 'app_management'

  _postinstall:
    commands: [
      # knockback dependencies
      'cp -v knockback/knockback-full-stack.js vendor/js/knockback-full-stack.js'

      # examples
      'cp -v backbone-relational vendor/js/backbone-relational.js'
      'cp -v backbone-relational/backbone-relational.min.js vendor/js/backbone-relational.min.js'

      # knockback optional libraries
      'cp -v backbone-modelref vendor/js/backbone-modelref.js'
      'cp -v backbone-relational vendor/js/backbone-relational.js'
      'cp -v knockback/lib/statistics.js vendor/js/knockback-statistics.js'

      'cp -v knockback-navigators/knockback-page-navigator-panes.js vendor/js/knockback-page-navigator-panes.js'
      'cp -v knockback-navigators/knockback-navigators.css vendor/css/knockback-navigators.css'
      'cp -v knockback-navigators/knockback-page-navigators.css vendor/css/knockback-page-navigators.css'
      'cp -v knockback-navigators/lib/knockback-sample-transitions-jquery.js vendor/js/knockback-sample-transitions-jquery.js'
    ]
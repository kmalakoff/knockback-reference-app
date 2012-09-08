![logo](https://github.com/kmalakoff/knockback-reference-app/raw/master/media/logo.png)

Knockback.js Reference Application provides a sample architecure for a Knockback.js application including page routing, separation of Models/ViewModels/Views, and memory management.

You can try out the application [here](http://kmalakoff.github.com/knockback-reference-app/) and can find step-by-step tutorial on the [Knockback.js website](http://kmalakoff.github.com/knockback/app_knockback_reference.html)

###Extended Features

In addition to a the Tutorial reference application, you can find more advanced implementations that use [KnockbackNavigators.js](https://github.com/kmalakoff/knockback-navigators) for page and embedded pane transitions (under DemoMode):

* ***Panes***: adds sliding panes with embedded cells for each relationship instead of simple buttons.
* ***Page Animations***: adds transition animations without history when navigating between pages.
* ***Page Animations + History***: adds transition animations with history when navigating between pages. Note: you can re-loading the page and the transitions will work as if you navigated from the main page.
* ***Page Animations + History + No Cache***: when you use history, you need to be careful to not keep too many pages in memory. This example show you how to on-demand load pages by passing a create function instead of element to the page navigator.

To help verify correct memory management and performance, the reference application provides some statistics helpers (under DemoMode -> Statistics):

* ***Chrome memory heap statistics***: You need to launch Chrome with the --enable-memory-info flag and also you might need to trigger heap compaction to ensure the statistics are up-to-date (for example, by using Developer Tools -> Profiles -> Take Heap Snapshot).
* ***Active ViewModels/CollectionObservables***: using the Knockback.js statistics component, you can see what which ViewModels and CollectionObservables are in memory. Note: if you do not derive from kb.ViewModel or kb.CollectionObservable, you need to add them manually using kb.Statistics.register(key, obj)
* ***Backbone.Model Events***: using the Knockback.js statistics component, you can see and reset all of the events that Knockback.js has intercepted from Backbone.js
* ***Page Cycling***: to do soak testing, you can choose the number of randomized page cycles and time per page to see the memory characteristics over time.


Building, Running and Testing the App
-----------------------

###Installing:

1. install node.js: http://nodejs.org
2. install node packages: 'npm install'

###Commands:

Look at: https://github.com/kmalakoff/easy-bake
window.StatisticsView = """
  <div data-bind="visible: is_opened">

    <div class='modal-backdrop'></div>
    <div class="modal" data-bind="fadeIn: is_opened"><div class="modal-body">
      <div class='nav'>
        <a class='pull-right' data-bind="click: close"><i class="icon-remove"></i></a>
      </div>

      <div class='pagination-centered'>
        <h4>Process Memory</h4>
        <!-- ko ifnot: memory_stats_available -->
          <p>Stats not available. Launch Chrome with option --enable-memory-info</p>
        <!-- /ko -->

        <!-- ko if: memory_stats_available -->
          <table class="table table-bordered">
            <tr>
              <td></td>
              <td>Start</td>
              <td>Current/End</td>
              <td>Delta</td>
            </tr>
            <tr>
              <td>Baseline</td>
              <td><span data-bind="text: toFixed(memory_start(), 2)"></span><button class='btn btn-mini pull-right' data-bind="click: resetBaselineMemory">reset</button></td>
              <td data-bind="text: toFixed(memory_current(), 2)"></td>
              <td data-bind="text: toFixed(memory_delta(), 2)"></td>
            </tr>
            <tr>
              <td>Cycle</td>
              <td data-bind="text: toFixed(memory_cycle_start(), 2)"></td>
              <td data-bind="text: toFixed(memory_cycle_current(), 2)"></td>
              <td data-bind="text: toFixed(memory_cycle_delta(), 2)"></td>
            </tr>
          </table>
        <!-- /ko -->

        <h4>Active kb.ViewModels and kb.CollectionObservables</h4>
        <p data-bind="text: observable_stats"></p>
        <h4>Model Events Triggered <button class='btn btn-small pull-mini' data-bind="click: clear">clear</button></h4>
        <p data-bind="text: model_events_stats"></p>
        <form class="form-horizontal">
          <button class='btn btn-small' data-bind="click: cyclePages">Cycle Pages</button>
          <button class='btn btn-small' data-bind="click: function(){app.setMode({no_app: true});}">Release Application</button>
        </form>
        <form class="form-horizontal">
          <div class="control-group">
            <label class="control-label">Cycle Count</label>
            <div class="controls">
              <input type="text" data-bind="value: cycle_count"/>
            </div>
            <label class="control-label">Cycle Interval</label>
            <div class="controls">
              <input type="text" data-bind="value: cycle_interval"/>
            </div>
          </div>
        </form>
      </div>
    </div></div>
  </div>
"""
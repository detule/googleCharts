// polyfill indexOf for IE8
if (!Array.prototype.indexOf) {
  Array.prototype.indexOf = function(elt /*, from*/) {
    var len = this.length >>> 0;

    var from = Number(arguments[1]) || 0;
    from = (from < 0)
         ? Math.ceil(from)
         : Math.floor(from);
    if (from < 0)
      from += len;

    for (; from < len; from++) {
      if (from in this &&
          this[from] === elt)
        return from;
    }
    return -1;
  };
}

loadWidget = function() {
  HTMLWidgets.widget({

    name: "googleCharts",

    type: "output",

    factory: function(el, width, height) {
      var wrapper = null;
      // add qt style if we are running under Qt
      if (window.navigator.userAgent.indexOf(" Qt/") > 0)
        el.className += " qt";

      return {
        renderValue: function(x) {
          var rawData = x.data;
          var data = null;
          var options = x.options;
          var chartType = x.chartType;

          if (rawData) {
            rawData.unshift(Object.keys(x.columns).map(function(k){return x.columns[k]}));
            data = google.visualization.arrayToDataTable(rawData);
            if (options.formatter) {
              options.formatter(data);
            }
         }

          if (!wrapper) {
            if (!data)
              return;
            wrapper = new google.visualization.ChartWrapper({
              chartType: chartType,
              containerId: el.id
            })
            wrapper.setDataTable(data)
            wrapper.setOptions(options)
          }
          if (data) {
            wrapper.setDataTable(data)
            wrapper.setOptions(options)
          } else {
            wrapper.getChart().clearChart();
          }
          if(options.eventHandlers) {
            options.eventHandlers(wrapper);
          }
          wrapper.draw();
        },

        resize: function(width, height) {
          if (wrapper)
            wrapper.draw();
        },

        wrapper: wrapper
      };
    }
  });
};

loadChartsAndWidget = function() {
  google.charts.load('current');
  google.charts.setOnLoadCallback(function() {
    loadWidget();
    /*
     * Htmlwidgets render callback fires on DOMLoad
     * However, as we are loading dynamically, this
     * might very well come after the DOMLoad event has
     * already fired.  Force htmlwidgets to re-render.
     * This is sub-optimal.
     */
      HTMLWidgets.staticRender();
  });
};

(function() {
  if(window.HTMLWidgets.shinyMode) {
    loadWidget();
  } else {
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = "https://www.gstatic.com/charts/loader.js";
    if (script.readyState){  //IE
      script.onreadystatechange = function(){
        if (script.readyState == "loaded" ||
            script.readyState == "complete"){
          script.onreadystatechange = null;
          loadChartsAndWidget();
        }
      };
    } else {
      script.onload = function() {
        loadChartsAndWidget();
      };
    }
    document.getElementsByTagName("head")[0].appendChild(script);
  }
})();


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
        var wrapper = this.wrapper;
        var data = x.data

//        var options = x.options;
        var chartType = x.chartType;
        data.unshift(Object.keys(x.columns).map(function(k){return x.columns[k]}));
       
        if (!wrapper) {
          if (!data)
            return;
          wrapper = new google.visualization.ChartWrapper({
            options: {'title': 'Countries'},
            chartType: chartType,
            containerId: el.id
          })
          wrapper.setDataTable(data)
//          wrapper.setOptions(options)
        }
        if (data) {
          wrapper.setDataTable(data)
//          wrapper.setOptions(options)
        } else {
          wrapper.getChart().clearChart();
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


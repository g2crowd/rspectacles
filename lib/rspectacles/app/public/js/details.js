define(['jquery', 'mustache'], function ($, Mustache) {
  var me
    , defaults
    , current = {}
    , tmpl = $('#template').html()
    , isCount = false
    ;

  defaults = function () {
    return {
      name: ''
    , line_number: ''
    , status: ''
    , duration: ''
    , time_or_count: isCount ? 'Examples' : 'ms'
    , minutes: ''
    , value: null
    };
  };

  function secToMin(time) {
    var pad = function (val) { return ('00' + val).slice(-2); }
      , min = parseInt(time / 60)
      , sec = parseInt(time % 60)
      ;

    return pad(min) + ':' + pad(sec);
  }

  function render() {
    if (current.value) {
      if (!isCount) {
        current.minutes = secToMin(current.value);
        current.value = parseInt(current.value * 1000);
      }
    }

    $('.example-wrapper').html(Mustache.render(tmpl, current));
  }

  return {
    update: function (d) {
      current = $.extend({}, defaults(), d);
      render();
    }

  , isCount: function (value) {
      isCount = value;
    }
  };
});

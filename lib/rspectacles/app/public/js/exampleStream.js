/*global define: true EventSource: true */
define(['riffle'], function (riffle) {
  'use strict';

  return function streams(ajaxUri) {
    var stream = riffle.stream
      , each
      , jsonEvents
      ;

    function ajaxStream(url, args) {
      return stream(function (o) {
        $.get(url, args, function (d) {
          o(JSON.parse(d));
        });
      });
    }

    each = stream(function (o, i) {
      i.forEach(function (item) { o(item); });
    });

    function batched(delay, maxSize) {
      var batch = []
        ;

      delay = delay || 100;

      return stream(function (o, i) {
        batch = batch.concat(i);

        function clear() {
          batch.length > 0 && o(batch);
          batch = [];
        }

        if (maxSize && batch.length > maxSize) {
          clear();
        } else {
          setTimeout(clear, delay);
        }
      });
    }

    jsonEvents = each.input(ajaxStream(ajaxUri).invoke());

    return { example: batched().input(jsonEvents) };
  };
});

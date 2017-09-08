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
        , timer
        ;

      delay = delay || 100;
      maxSize = maxSize || 100;

      function clear(o) {
        batch.length > 0 && o(batch.splice(0, maxSize));

        if (batch.length < 1) {
          clearInterval(timer);
          timer = null;
        }
      }

      return stream(function (o, i) {
        batch = batch.concat(i);

        if (!timer) { timer = setInterval(function () { clear(o); }, delay); }
      });
    }

    jsonEvents = each.input(ajaxStream(ajaxUri).invoke());

    return { example: batched(10, 1000).input(jsonEvents) };
  };
});

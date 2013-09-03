/*global define: true EventSource: true */
define(['riffle'], function (riffle) {
  'use strict';

  return function streams(uri) {
    var stream = riffle.stream
      , me
      , events
      , matching
      , toJson
      , stringEvents
      , eventToString
      ;

    events = stream(function (o, i) {
      new EventSource(uri).addEventListener('message', o);
    }).invoke();

    eventToString = stream(function (o, i) {
      o(i.data);
    });

    matching = function (regex) {
      return stream(function (o, i) {
        if (i.match(regex)) { o(i); }
      });
    };

    toJson = stream(function (o, i) {
      o(JSON.parse(i));
    });

    function batched(delay, maxSize) {
      var batch = []
        ;

      delay = delay || 100;

      return stream(function (o, i) {
        batch.push(i);

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

    stringEvents = eventToString.input(events);

    return me = {
      message: matching(/^message:/).input(stringEvents)
    , start: matching(/^status:start/).input(stringEvents)
    , stop: matching(/^status:stop/).input(stringEvents)
    , example: batched().input(toJson.input(matching(/^\{/).input(stringEvents)))
    };
  };
});

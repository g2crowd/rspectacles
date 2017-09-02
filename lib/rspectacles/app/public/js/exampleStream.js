/*global define: true EventSource: true */
define(['riffle'], function (riffle) {
  'use strict';

  return function streams(serverUri, ajaxUri, currentRun) {
    var stream = riffle.stream
      , me
      , serverEvents
      , ajaxEvents
      , matching
      , toJson
      , each
      , stringEvents
      , allEvents
      , allExamples
      , scopedExamples
      , eventToString
      ;

    serverEvents = stream(function (o, i) {
      new EventSource(serverUri).addEventListener('message', o);
    }).invoke();

    function ajaxStream(url, args) {
      return stream(function (o) {
        $.get(url, args, function (d) {
          o(JSON.parse(d));
        });
      });
    }

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

    stringEvents = eventToString.input(serverEvents);
    ajaxEvents = each.input(ajaxStream(ajaxUri).invoke());
    allEvents = stream().input(stringEvents, ajaxEvents);
    allExamples = toJson.input(matching(/^\{/).input(allEvents));
    scopedExamples = stream(function (o, i) {
      if (i.rspec_run === currentRun) { o(i); }
    }).input(allExamples);

    return me = {
      message: matching(new RegExp('^' + currentRun + ':message:')).input(stringEvents)
    , start: matching(new RegExp('^' + currentRun + ':status:start')).input(stringEvents)
    , stop: matching(new RegExp('^' + currentRun + ':status:stop')).input(stringEvents)
    , example: batched().input(scopedExamples)
    };
  };
});

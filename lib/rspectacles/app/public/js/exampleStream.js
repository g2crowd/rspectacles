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

    stringEvents = eventToString.input(events);

    return me = {
      message: matching(/^message:/).input(stringEvents)
    , status: matching(/^message:/).input(stringEvents)
    , example: toJson.input(matching(/^\{/).input(stringEvents))
    };
  };
});

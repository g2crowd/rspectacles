/*global require: true EventSource: true */
require(['jquery', 'visualize', 'riffle'], function ($, v, riffle) {
  'use strict';

  var stream = riffle.stream
    , events
    , eventToString
    , withPrefix
    ;

  var s = new EventSource('/stream');

  s.addEventListener('message', function (e) {
    console.log(e);
  });
/*
  function eventStream(uri) {
    return stream(function (o, i) {
      
    });
  }

  eventToString = stream(function (o, i) {
    o(i.data);
  });

  withPrefix = function (prefix) {
    var reg = new RegExp('^' + prefix + ':');
    return stream(function (o, i) {
      if (i.match(reg)) { o(i); }
    });
  };

  events = eventToString.input(eventStream('/stream').invoke());
  events.onOutput(function (data) { console.log(data) });
  */
});

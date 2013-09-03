/*global require: true */
require(['chart', 'exampleStream'], function (chart, examples) {
  'use strict';

  var
      bodyEl = document.querySelector('body')
    , uri = bodyEl.dataset.streamUrl
    , streams = examples(uri)
    , c = chart()
    ;

  streams.start.onOutput(function (data) {
    c.reset();
  });

  streams.message.onOutput(function (data) {
    console.log('message logged', data);
  });

  streams.example.onOutput(function (data) {
    c.push(data);
  });

  c.render();
  window.c = c;
});

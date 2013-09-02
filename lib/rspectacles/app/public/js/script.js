/*global require: true */
require(['visualize', 'exampleStream'], function (v, examples) {
  'use strict';

  var
      bodyEl = document.querySelector('body')
    , uri = bodyEl.getAttribute('data-stream-url')
    , streams = examples(uri)
    ;

  streams.status.onOutput(function (data) {
    console.log(data);
  });

  streams.message.onOutput(function (data) {
    console.log('message logged', data);
  });

  streams.example.onOutput(function (data) {
    console.log(data);
  });
});

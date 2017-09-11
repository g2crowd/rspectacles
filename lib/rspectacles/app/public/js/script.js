/*global require: true */
require(['zoomable', 'exampleStream'], function (chart, examples) {
  'use strict';

  var
      bodyEl = document.querySelector('body')
    , ajaxUri = bodyEl.dataset.ajaxUrl
    , streams = examples(ajaxUri)
    , c = chart()
    ;

  streams.example.onOutput(function (data) {
    c.push(data);
  });

  c.render();
  window.c = c;
});

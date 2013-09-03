/*global test:true require:true it:true ok:true module:true */

require(['pathtree'], function (PathTree) {
  'use strict';

  test('constructor', function () {
    var tree = new PathTree([{ file_path: './file', full_description: 'hi' }]);
    equal(tree.nodes.children[0].name, 'file');
  });

  module('PathTree#add', {
    setup: function () {
      this.tree = new PathTree();
    }
  });

  test('add', function () {
    this.tree.add({ file_path: './file', full_description: 'hi' });
    equal(this.tree.nodes.children[0].name, 'file');
  });
});

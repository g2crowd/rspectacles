// @format
/*global define: true */
define(['jquery'], function($) {
  'use strict';

  function createNodes(path, data, node) {
    var nextNode;

    node.children = node.children || [];

    if (path.length === 0) {
      nextNode = $.extend(
        {
          size: data.duration,
          name: data.full_description,
        },
        data,
      );

      node.children.push(nextNode);
      return;
    }

    nextNode = node.children.filter(function(child) {
      return child.name === path[0];
    })[0];

    if (!nextNode) {
      nextNode = {name: path[0]};
      node.children.push(nextNode);
    }

    path.shift();
    createNodes(path, data, nextNode);
  }

  function PathTree(data) {
    this.nodes = {};
    data && this.add(data);
  }

  PathTree.prototype.add = function(data) {
    var that = this;
    !$.isArray(data) && (data = [data]);

    data.forEach(function(node) {
      var path = node.file_path.split('/');

      ['.'].forEach(function(v) {
        if (path[0] === v) {
          path.shift();
        }
      });

      createNodes(path, node, that.nodes);
    });
  };

  return PathTree;
});

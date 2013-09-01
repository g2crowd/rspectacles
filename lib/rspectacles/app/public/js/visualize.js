/*global define: true */
define(['plates', 'jquery'], function (Plates, $) {
  'use strict';

  var width = 960
    , height = 700
    , radius = Math.min(width, height) / 2
    , color = d3.scale.category20c()
    , isCount = true
    , svg
    , partition
    , arc
    ;

  svg = d3.select("body").append("svg")
          .attr("width", width)
          .attr("height", height)
          .append("g")
          .attr("transform", "translate(" + width / 2 + "," + height * 0.52 + ")");

  partition = d3.layout.partition()
                .sort(null)
                .size([2 * Math.PI, radius * radius])
                .value(function (d) { return 1; });

  arc = d3.svg.arc()
          .startAngle(function (d) { return d.x; })
          .endAngle(function (d) { return d.x + d.dx; })
          .innerRadius(function (d) { return Math.sqrt(d.y); })
          .outerRadius(function (d) { return Math.sqrt(d.y + d.dy); });

  function pushData(root) {
    root = pathNameToTree(root.examples);

    var path = svg.datum(root).selectAll("path")
        .data(partition.nodes)
      .enter().append("path")
        .attr("display", function (d) { return d.depth ? null : "none"; }) // hide inner ring
        .attr("d", arc)
        .style("stroke", function (d) {
          if (d.status && d.status === 'failed') {
            return '#f00';
          } else {
            return '#fff';
          }
        })
        .style("fill", function (d) { return color((d.children ? d : d.parent).name); })
        .style("fill-rule", "evenodd")
        .each(stash)
        .on('mouseover', showDetails);

    d3.selectAll("input").on("change", function change() {
      var value = this.value === "count" ?
                  function () { return 1; } :
                  function (d) { return d.size; };

      isCount = this.value === 'count';

      path
          .data(partition.value(value).nodes)
        .transition()
          .duration(1500)
          .attrTween("d", arcTween);
    });
  }

  // Stash the old values for transition.
  function stash(d) {
    d.x0 = d.x;
    d.dx0 = d.dx;
  }

  // Interpolate the arcs in data space.
  function arcTween(a) {
    var i = d3.interpolate({x: a.x0, dx: a.dx0}, a);
    return function(t) {
      var b = i(t);
      a.x0 = b.x;
      a.dx0 = b.dx;
      return arc(b);
    };
  }

  d3.select(self.frameElement).style("height", height + "px");


  var tmpl = $('#template').html();

  function showDetails(data) {
    var mappedData = $.extend({
      name: ''
    , line_number: ''
    , status: ''
    , duration: ''
    , time_or_count: isCount ? 'Examples' : 'Seconds'
    }, data);

    !isCount && (mappedData.value = mappedData.value.toFixed(3));

    $('.example-wrapper').html(Plates.bind(tmpl, mappedData));
  }

  function createNodes(path, data, node) {
    var nextNode
      ;

    node.children = node.children || [];

    if (path.length === 0) {
      nextNode = $.extend({
        size: data.duration
      , name: data.full_description
      }, data);

      node.children.push(nextNode);
      return;
    }

    nextNode = node.children.filter(function (child) {
      return child.name === path[0];
    })[0];

    if (!nextNode) {
      nextNode = { name: path[0] };
      node.children.push(nextNode);
    }

    path.shift();
    createNodes(path, data, nextNode);
  }

  function pathNameToTree(examples) {
    var tree = {}
      ;

    examples.forEach(function (data) {
      var path = data.file_path.split('/');
      path.shift();
      createNodes(path, data, tree);
    });

    return tree;
  }

  return pushData;
});

define(['jquery', 'pathtree', 'details', 'form'], function ($, PathTree, details, countForm) {
  return function (options) {
    var width = 960,
        height = 700,
        radius = (Math.min(width, height) / 2) - 10,
        form = countForm(),
        me;

    function arcTween(a) {
      var i = d3.interpolate({ x: a.x0, dx: a.dx0 }, a);
      return function tweener(t) {
        var b = i(t);
        a.x0 = b.x;
        a.dx0 = b.dx;
        return arc(b);
      };
    }

    var x = d3.scale.linear()
        .range([0, 2 * Math.PI]);

    var y = d3.scale.sqrt()
        .range([0, radius]);

    var color = d3.scale.category20c();

    var partition = d3.layout.partition()
        .sort(function(a, b) { return d3.ascending(a.name, b.name); })
        .value(function(d) { return d.size; });

    var arc = d3.svg.arc()
        .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
        .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
        .innerRadius(function(d) { return Math.max(0, y(d.y)); })
        .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

    var svg = d3.select("body").append("svg")
        .attr("width", width)
        .attr("height", height)
      .append("g")
        .attr("transform", "translate(" + width / 2 + "," + (height / 2) + ")");

    function getValue() {
      return form.isCount() ?
                  function () { return 1; } :
                  function (d) { return d.size; };
    }

    function getColor(d) {
      if (d.status && d.status === 'failed') {
        return '#f00';
      } else {
        return color(((d.children ? d : d.parent) || {}).name);
      }
    }

    function stash(d) {
      d.x0 = d.x;
      d.dx0 = d.dx;
    }


    function onUpdate(path) {
      path
          .attr("d", arc)
          .each(stash)
          .style("fill", getColor);
    }

    var render = function () {
      var path = svg.datum(me.tree.nodes).selectAll("path")
          .data(partition.value(getValue()).nodes);

      onUpdate(path);
      path
        .enter().append("path")
          .on('mouseover', details.update)
          .attr("d", arc)
          .style("fill", getColor)
          .style("stroke", function (d) { return 'rgba(255,255,255,0.3)'; })
          .style("fill-rule", "evenodd")
          .on("click", click);

      form.onChange = function (isCount) {
        details.isCount(isCount);

        path
          .data(partition.value(getValue()).nodes)
          .transition()
            .duration(1500)
            .attrTween("d", arcTween);
      };

      render = function () {
        path.datum(me.tree.nodes)
            .data(partition.value(getValue()).nodes);
      };
    };

    function click(d) {
      svg.transition()
          .duration(750)
          .tween("scale", function() {
            var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
                yd = d3.interpolate(y.domain(), [d.y, 1]),
                yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
            return function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); };
          })
        .selectAll("path")
          .attrTween("d", function(d) { return function() { return arc(d); }; });
    }

    d3.select(self.frameElement).style("height", height + "px");

    return me = {
      tree: new PathTree(),

      render: render,

      reset: function () {
        me.tree = new PathTree();
        me.render();
      },

      push: function (data) {
        me.tree.add(data);
        me.render();
      }
    };
  }
});

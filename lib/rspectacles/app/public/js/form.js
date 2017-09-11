define(function () {
  return function () {
    var isCount = false;
    var me;

    d3.selectAll("input").on("change", function () {
      var newCount = this.value === 'count';

      if (newCount !== isCount) {
        isCount = newCount;
        me.onChange(isCount);
      }
    });

    return me = {
      isCount: function () {
        return isCount;
      },

      onChange: function () {
      }
    }
  }
});

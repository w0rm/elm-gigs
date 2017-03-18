var _w0rm$elm_gigs$Native_Measure = (function () {

  function measure (font, text) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
      var node = document.createElement('div');
      var dimensions;
      node.style.whiteSpace = 'nowrap';
      node.style.position = 'absolute';
      node.style.visibility = 'hidden';
      node.style.font = font;
      node.innerHTML = text;

      document.body.appendChild(node);

      dimensions = {
        width: node.clientWidth,
        height: node.clientHeight
      };

      node.parentNode.removeChild(node);

      return callback(_elm_lang$core$Native_Scheduler.succeed(dimensions));

    });
  }

  return {
    measure: F2(measure)
  };

})();

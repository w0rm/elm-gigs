var _w0rm$elm_unsoundscapes2$Native_Measure = (function () {

  function measure (fontFamily, fontSize, text) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
      var node = document.createElement('div');
      var dimensions;
      node.style.whiteSpace = 'nowrap';
      node.style.position = 'absolute';
      node.style.visibility = 'hidden';
      node.style.fontFamily = fontFamily;
      node.style.fontSize = fontSize;

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
    measure: F3(measure)
  };

})();

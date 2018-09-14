'use strict';

(function () {
  $(function () {
    Atrackt.setPlugin('Demo Plugin', {
      send: function send() {}
    });
    Atrackt.setEvent({
      click: '.track'
    });
    return $('a.custom').data('atrackt-function', function () {
      return console.log('Custom Function Called!');
    });
  });
}).call(undefined);
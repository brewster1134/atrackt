// Generated by CoffeeScript 2.2.4
(function () {
  $(function () {
    Atrackt.setPlugin('Demo Plugin', {
      send: function () {}
    });
    Atrackt.setEvent({
      click: '.track'
    });
    return $('a.custom').data('atrackt-function', function () {
      return console.log('Custom Function Called!');
    });
  });
}).call(this);
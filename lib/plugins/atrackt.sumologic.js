'use strict';

(function () {
  /*
  Atrackt Sumo Logic Plugin
  https://github.com/brewster1134/atrackt
  @author Ryan Brewster
  @version 0.0.1
  */
  (function (factory) {
    if (typeof define !== "undefined" && define !== null ? define.amd : void 0) {
      return define(['jquery', 'atrackt'], function ($, Atrackt) {
        return factory($, Atrackt);
      });
    } else {
      return factory(jQuery, Atrackt);
    }
  })(function ($, Atrackt) {
    return Atrackt.setPlugin('sumologic', {
      options: {},
      send: function send(data, options) {
        if (options['type'] !== 'error') {
          return;
        }
        return $.ajax({
          method: 'POST',
          url: '',
          data: data
        });
      }
    });
  });
}).call(undefined);
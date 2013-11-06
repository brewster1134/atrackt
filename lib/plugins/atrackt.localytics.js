/*
Atrackt Localytics Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 0.0.1
*/


(function() {
  window.Atrackt.registerPlugin('localytics', {
    send: function(obj, options) {
      return typeof localyticsSession !== "undefined" && localyticsSession !== null ? localyticsSession.tagEvent(options.localytics.eventName, obj) : void 0;
    }
  });

}).call(this);

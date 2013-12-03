/*
Atrackt Localytics Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 0.0.1
*/


(function() {
  window.Atrackt.registerPlugin('localytics', {
    send: function(obj, options) {
      if (typeof localyticsSession === "undefined" || localyticsSession === null) {
        return console.log('LOCALYTICS SCRIPT NOT LOADED!');
      }
      return localyticsSession.tagEvent(options.localytics.eventName, obj);
    }
  });

}).call(this);

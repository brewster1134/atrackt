/*
Atrackt Localytics Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 0.0.2
*/


(function() {
  window.Atrackt.registerPlugin('localytics', {
    send: function(obj, options) {
      var redirectUrl;

      if (this._isUiWebView()) {
        redirectUrl = this._getRedirectUrl(obj, options.localytics);
        return this._redirect(redirectUrl);
      } else {
        return this._callTagMethod(obj, options.localytics);
      }
    },
    _callTagMethod: function(obj, options) {
      return typeof localyticsSession !== "undefined" && localyticsSession !== null ? localyticsSession.tagEvent(options.eventName, obj) : void 0;
    },
    _isUiWebView: function() {
      return /(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/i.test(navigator.userAgent);
    },
    _getRedirectUrl: function(obj, options) {
      var redirectUrl;

      redirectUrl = "localytics://?event=" + options.eventName;
      redirectUrl += "&attributes=" + (JSON.stringify(obj));
      return redirectUrl;
    },
    _redirect: function(url) {
      if (this._isUiWebView()) {
        return window.location = url;
      }
    }
  });

}).call(this);

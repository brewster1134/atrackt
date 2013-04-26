// Generated by CoffeeScript 1.4.0

/*
Atrackt Debugging Console
@author Ryan Brewster
@version 0.0.3
*/


(function() {

  $.extend(window.Atrackt, {
    _debug: function() {
      return this._urlParams('debugTracking') === 'true';
    },
    _debugConsoleReset: function() {
      if (this._debug()) {
        return $('#atrackt-elements tbody').empty();
      }
    },
    _debugConsole: function() {
      var _this = this;
      if (!Atrackt._debug()) {
        return false;
      }
      return $(function() {
        $('body').addClass('atrackt-debug');
        $('<style>\
        body.atrackt-debug {\
          margin-top: 300px; }\
        #atrackt-debug {\
          height: 300px;\
          background-color: white;\
          width: 100%;\
          overflow-x: hidden;\
          overflow-y: scroll;\
          position: fixed;\
          top: 0;\
          left: 0;\
          z-index: 1;\
          border-bottom: 2px solid black; }\
        #atrackt-location {\
          border-bottom: 1px solid black;\
          padding: 5px; }\
        #atrackt-elements {\
          width: 100%; }\
        body.atrackt-debug .highlight {\
          background-color: green !important;\
          color: white !important; }\
        body.atrackt-debug .atrackt-element.error{\
          background-color: red !important;\
          color: white !important; }\
        </style>').appendTo('head');
        return $('<div id="atrackt-debug">\
          <div id="atrackt-debug-content">\
            <div id="atrackt-location">Location: ' + _this._getLocation() + '</div>\
            <table class="table" id="atrackt-elements">\
              <thead><tr>\
                <th>Plugin : Event</th>\
                <th>Categories</th>\
                <th>Value</th>\
                <th>Error</th>\
              </tr></thead>\
              <tbody></tbody>\
            </table>\
          </div>\
        </div>').prependTo('body');
      });
    },
    _debugPluginEvent: function(plugin, event) {
      return "<div class='" + plugin + " " + event + "'>" + plugin + " : " + event + "</div>";
    },
    _debugEl: function($el, plugin, event) {
      var elId, matchingBodyEls, matchingConsoleEls, mathingEls, pluginEventDiv, pluginEventMainDiv;
      if (!this._debug()) {
        return false;
      }
      this._getTrackObject($el);
      elId = this._debugElementId($el);
      $el.attr('data-atrackt-debug-id', elId);
      matchingConsoleEls = $('body .atrackt-element[data-atrackt-debug-id=' + elId + ']');
      pluginEventDiv = this._debugPluginEvent(plugin, event);
      if (matchingConsoleEls.length === 0) {
        $('<tr class="atrackt-element" data-atrackt-debug-id="' + elId + '">\
        <td class="atrackt-plugin-event">' + pluginEventDiv + '</td>\
        <td class="atrackt-categories">' + $el.data('track-object').categories + '</td>\
        <td class="atrackt-value">' + $el.data('track-object').value + '</td>\
        <td class="atrackt-error"></td>\
        </tr>').appendTo('#atrackt-elements tbody');
      } else {
        pluginEventMainDiv = matchingConsoleEls.find('.atrackt-plugin-event');
        if (!($(pluginEventMainDiv).has("." + plugin + "." + event).length > 0)) {
          pluginEventMainDiv.append(pluginEventDiv);
        }
      }
      mathingEls = $('body [data-atrackt-debug-id=' + elId + ']');
      matchingConsoleEls = mathingEls.filter('.atrackt-element');
      matchingBodyEls = mathingEls.not('.atrackt-element');
      if (matchingBodyEls.length > 1) {
        console.log('DUPLICATE ELEMENTS FOUND', matchingBodyEls);
        matchingConsoleEls.addClass('error');
        matchingConsoleEls.find('.atrackt-error').append('DUPLICATE');
      }
      matchingConsoleEls.add($el).off('mouseenter mouseleave');
      matchingConsoleEls.hover(function() {
        $(this).add($el).addClass('highlight');
        return $('html, body').scrollTop($el.offset().top - $('#atrackt-debug').height() - 20);
      }, function() {
        return $(this).add($el).removeClass('highlight');
      });
      return $el.hover(function() {
        var elIndex, scrollTo, totalEls, totalHeight;
        $(this).add(matchingConsoleEls).addClass('highlight');
        totalHeight = $('#atrackt-elements tbody').height();
        totalEls = $('#atrackt-elements .atrackt-element').length;
        elIndex = $('#atrackt-elements .atrackt-element').index(matchingConsoleEls);
        scrollTo = (elIndex / totalEls) * totalHeight;
        return $('#atrackt-debug').scrollTop(scrollTo);
      }, function() {
        return $(this).add(matchingConsoleEls).removeClass('highlight');
      });
    },
    _debugElementId: function($el) {
      var idArray, _categories, _ctaValue;
      if (!$el.data('track-object')) {
        return false;
      }
      _categories = $el.data('track-object').categories;
      _ctaValue = $el.data('track-object').value;
      idArray = [];
      if (_categories) {
        idArray.push(_categories);
      }
      if (_ctaValue) {
        idArray.push(_ctaValue);
      }
      return idArray.join().toLowerCase().replace(/[^\w]/g, '');
    },
    _debugConsoleDestroy: function() {
      $('#atrackt-debug').remove();
      $('body').removeClass('atrackt-debug');
      return $('body [data-atrackt-debug-id]').removeAttr('data-atrackt-debug-id');
    }
  });

  Atrackt._debugConsole();

}).call(this);

/*
Atrackt Tracking Library
https://github.com/brewster1134/atrackt
@version 0.0.15
@author Ryan Brewster
*/


(function() {
  if (!String.prototype.trim) {
    String.prototype.trim = function() {
      return this.replace(/^\s+|\s+$/g, '');
    };
  }

  (function($, _, window, document) {
    if (window.console == null) {
      window.console = {
        log: function() {}
      };
    }
    return window.Atrackt = {
      plugins: {},
      registerPlugin: function(pluginName, attrs) {
        var _this = this;

        if (typeof (attrs != null ? attrs.send : void 0) !== 'function') {
          return console.log('NO SEND METHOD DEFINED');
        }
        attrs.elements || (attrs.elements = {});
        attrs.includeSelectors || (attrs.includeSelectors = {});
        attrs.includeElements || (attrs.includeElements = {});
        attrs.excludeSelectors || (attrs.excludeSelectors = {});
        attrs.excludeElements || (attrs.excludeElements = {});
        attrs.bind = function(eventsObject) {
          var currentElements, currentSelectors, data, eventType, _results;

          if (eventsObject == null) {
            return console.log('NOTHING TO BIND. YOU MUST PASS AN EVENT OBJECT CALLING BIND');
          }
          _results = [];
          for (eventType in eventsObject) {
            data = eventsObject[eventType];
            if (data instanceof Array) {
              currentSelectors = attrs.includeSelectors[eventType] || [];
              attrs.includeSelectors[eventType] = _.union(currentSelectors, data);
            } else if (data instanceof jQuery) {
              currentElements = attrs.includeElements[eventType] || [];
              attrs.includeElements[eventType] = _.union(currentElements, data);
            }
            _results.push(_this._bind(pluginName, eventType, data));
          }
          return _results;
        };
        attrs.unbind = function(eventsObject) {
          var currentElements, currentSelectors, data, eventType, _results;

          if (eventsObject != null) {
            _results = [];
            for (eventType in eventsObject) {
              data = eventsObject[eventType];
              if (data instanceof Array) {
                currentSelectors = attrs.excludeSelectors[eventType] || [];
                attrs.excludeSelectors[eventType] = _.union(currentSelectors, data);
              } else if (data instanceof jQuery) {
                currentElements = attrs.excludeElements[eventType] || [];
                attrs.excludeElements[eventType] = _.union(currentElements, data);
              }
              _results.push(_this._unbind(pluginName, eventType));
            }
            return _results;
          } else {
            attrs.elements = {};
            attrs.includeSelectors = {};
            attrs.includeElements = {};
            attrs.excludeSelectors = {};
            attrs.excludeElements = {};
            return _this._unbind(pluginName);
          }
        };
        attrs.setOptions = function(options) {
          var pluginOptions;

          pluginOptions = attrs.options || {};
          return attrs.options = $.extend(true, pluginOptions, options);
        };
        attrs.setGlobalData = function(object) {
          attrs.globalData || (attrs.globalData = {});
          return $.extend(true, attrs.globalData, object);
        };
        attrs.setCallback = function(name, callback) {
          if (!_.contains(['before', 'after'], name)) {
            return false;
          }
          attrs.callbacks || (attrs.callbacks = {});
          return attrs.callbacks[name] = callback;
        };
        return this.plugins[pluginName] = attrs;
      },
      setGlobalData: function(object) {
        var pluginData, pluginName, _ref, _results;

        _ref = this.plugins;
        _results = [];
        for (pluginName in _ref) {
          pluginData = _ref[pluginName];
          _results.push(pluginData.setGlobalData(object));
        }
        return _results;
      },
      setCallback: function(name, callback) {
        var pluginData, pluginName, _ref, _results;

        _ref = this.plugins;
        _results = [];
        for (pluginName in _ref) {
          pluginData = _ref[pluginName];
          _results.push(pluginData.setCallback(name, callback));
        }
        return _results;
      },
      bind: function(eventsObject) {
        var pluginData, pluginName, _ref, _results;

        _ref = this.plugins;
        _results = [];
        for (pluginName in _ref) {
          pluginData = _ref[pluginName];
          _results.push(pluginData.bind(eventsObject));
        }
        return _results;
      },
      unbind: function(eventsObject) {
        var pluginData, pluginName, _ref, _results;

        _ref = this.plugins;
        _results = [];
        for (pluginName in _ref) {
          pluginData = _ref[pluginName];
          _results.push(pluginData.unbind(eventsObject));
        }
        return _results;
      },
      refresh: function() {
        var eventType, pluginData, pluginName, selectors, _ref, _ref1;

        this._debugConsoleReset();
        _ref = this.plugins;
        for (pluginName in _ref) {
          pluginData = _ref[pluginName];
          _ref1 = pluginData.elements;
          for (eventType in _ref1) {
            selectors = _ref1[eventType];
            this._bind(pluginName, eventType);
          }
        }
        return true;
      },
      track: function(data, options, event) {
        var pluginData, pluginName, trackObject, trackingData, _ref, _ref1, _ref2;

        if (options == null) {
          options = {};
        }
        if (!(trackObject = this._getTrackObject(data))) {
          return false;
        }
        _ref = this.plugins;
        for (pluginName in _ref) {
          pluginData = _ref[pluginName];
          trackingData = $.extend(true, {}, pluginData.globalData, trackObject, event);
          $.extend(options, {
            plugin: pluginName
          });
          if ((_ref1 = pluginData.callbacks) != null) {
            if (typeof _ref1['before'] === "function") {
              _ref1['before'](trackingData, options);
            }
          }
          if (data instanceof jQuery) {
            if ((event == null) || event.handleObj.namespace === ("atrackt." + pluginName)) {
              pluginData.send($.extend(trackingData, {
                event: event != null ? event.type : void 0
              }), $.extend(options, {
                el: data
              }));
            }
          } else if (data instanceof Object) {
            pluginData.send(trackingData, options);
          }
          if ((_ref2 = pluginData.callbacks) != null) {
            if (typeof _ref2['after'] === "function") {
              _ref2['after'](trackingData, options);
            }
          }
        }
        return true;
      },
      _cleanup: function() {},
      _collectElements: function(pluginName, eventType) {
        var allElements, excludeElements, excludeSelectors, includeElements, includeSelectors, plugin, _ref, _ref1;

        this._cleanup(pluginName, eventType);
        plugin = this.plugins[pluginName];
        includeSelectors = $((_ref = plugin.includeSelectors[eventType]) != null ? _ref.join(',') : void 0);
        includeElements = includeSelectors || [];
        _.each(plugin.includeElements[eventType] || [], function(el) {
          return includeElements = includeElements.add(el);
        });
        excludeSelectors = $((_ref1 = plugin.excludeSelectors[eventType]) != null ? _ref1.join(',') : void 0);
        excludeElements = excludeSelectors || [];
        _.each(plugin.excludeElements[eventType] || [], function(el) {
          return excludeElements = excludeElements.add(el);
        });
        allElements = includeElements.not(excludeElements);
        this.plugins[pluginName].elements[eventType] = allElements;
        return allElements;
      },
      _bind: function(pluginName, eventType, data) {
        var selectors;

        this._collectElements(pluginName, eventType);
        this._unbind(pluginName, eventType, data);
        selectors = $(this.plugins[pluginName].elements[eventType]);
        if (data instanceof Array) {
          selectors = selectors.filter(data.join(','));
        } else if (data instanceof jQuery) {
          selectors = data;
        }
        selectors.on("" + eventType + ".atrackt." + pluginName, function(e) {
          return Atrackt.track($(this), {}, e);
        });
        if (typeof this._debug === "function" ? this._debug() : void 0) {
          selectors.each(function() {
            return Atrackt._debugEl($(this), pluginName, eventType);
          });
        }
        return selectors;
      },
      _unbind: function(pluginName, eventType, data) {
        var eventName, selectors;

        eventName = '.atrackt';
        selectors = $('*', 'body');
        if (eventType != null) {
          eventName = eventType.concat(eventName);
        }
        if (pluginName != null) {
          eventName = eventName.concat("." + pluginName);
        }
        if ((pluginName != null) && (eventType != null)) {
          selectors = $(this.plugins[pluginName].elements[eventType]);
        }
        if (data instanceof Array) {
          selectors = selectors.filter(data.join(','));
        } else if (data instanceof jQuery) {
          selectors = data;
        }
        selectors.off(eventName);
        return selectors;
      },
      _getTrackObject: function(data, event) {
        var $el, _base;

        if (data instanceof HTMLElement) {
          data = $(data);
        }
        if (data instanceof jQuery) {
          $el = data;
          $el.data('track-object', {
            location: this._getLocation(),
            categories: this._getCategories($el),
            value: this._getValue($el)
          });
          if (typeof (_base = $el.data('track-function')) === "function") {
            _base($el.data('track-object'), $el, event);
          }
          return $el.data('track-object');
        } else if (data instanceof Object) {
          $.extend(data, {
            location: this._getLocation()
          });
          return data;
        } else {
          console.log('DATA IS NOT TRACKABLE', data);
          return false;
        }
      },
      _getLocation: function() {
        return $('body').data('track-location') || $(document).attr('title') || document.URL;
      },
      _getCategories: function($el) {
        var catArray;

        catArray = [];
        if ($el.data('track-cat')) {
          catArray.unshift($el.data('track-cat'));
        }
        $el.parents('[data-track-cat]').each(function() {
          return catArray.unshift($(this).data('track-cat'));
        });
        return catArray;
      },
      _getValue: function($el) {
        return $el.data('track-value') || $el.attr('title') || $el.attr('name') || $el.text().trim() || $el.val() || $el.attr('id') || $el.attr('class');
      },
      _urlParams: function(key) {
        var paramString, params;

        if (key == null) {
          key = null;
        }
        params = {};
        paramString = window.location.search.substring(1);
        $.each(paramString.split('&'), function(i, param) {
          var paramObject;

          paramObject = param.split('=');
          return params[paramObject[0]] = paramObject[1];
        });
        if (key) {
          return params[key];
        } else {
          return params;
        }
      }
    };
  })(jQuery, _, window, document);

}).call(this);
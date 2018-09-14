'use strict';

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

(function () {
  /*
  Atrackt Tracking Library
  https://github.com/brewster1134/atrackt
  @version 1.0.13
  @author Ryan Brewster
  */
  (function (factory) {
    if (typeof define !== "undefined" && define !== null ? define.amd : void 0) {
      return define(['jquery'], function ($) {
        return factory($);
      });
    } else {
      return factory(window.jQuery);
    }
  })(function ($) {
    var Atrackt;
    Atrackt = function () {
      var Atrackt = function () {
        function Atrackt() {
          _classCallCheck(this, Atrackt);
        }

        _createClass(Atrackt, [{
          key: 'setPlugin',


          // PUBLIC METHODS

          value: function setPlugin(pluginName, plugin) {
            var _this = this;

            if (!pluginName) {
              throw new Error('ATRACKT ERROR: `setPlugin` - No plugin name defined');
            }
            if (!(plugin && typeof plugin.send === 'function')) {
              throw new Error('ATRACKT ERROR: `setPlugin` - No send method was defined for `' + pluginName + '`.');
            }
            // Add plugin to global plugins object
            pluginName = pluginName.toLowerCase().replace(/[^a-z]/g, '-');
            this.plugins[pluginName] = plugin;
            // Set plugin name
            // This value is used to determine if a context is a plugin or on the global Atrackt object
            plugin.name = pluginName;
            // Default plugin attributes
            plugin._data || (plugin._data = {});
            plugin._options || (plugin._options = {});
            plugin._elements || (plugin._elements = {});
            plugin._callbacks || (plugin._callbacks = {});
            // Pass data to global methods with plugin context
            plugin.setEvent = function (eventsObject) {
              return _this.setEvent(eventsObject, plugin);
            };
            plugin.setData = function (data) {
              return _this.setData(data, plugin);
            };
            plugin.setOptions = function (options) {
              return _this.setOptions(options, plugin);
            };
            plugin.setCallback = function (name, callback) {
              return _this.setCallback(name, callback, plugin);
            };
            return plugin.track = function (data, options, event, plugin) {
              return _this.track(data, options, event, plugin);
            };
          }

          // Handles registering strings, jquery objects, or html nodes to the plugin
          // Actual event binding is done from _registerElement

        }, {
          key: 'setEvent',
          value: function setEvent(eventsObject) {
            var context = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : this;

            var eventType, globalEvent, object, objects, pluginEvent, results;
            if (!eventsObject) {
              throw new Error('ATRACKT ERROR: `setEvent` - You must pass a valid event object.');
            }
            results = [];
            for (eventType in eventsObject) {
              objects = eventsObject[eventType];
              // build event namespace
              globalEvent = [eventType, 'atrackt'];
              pluginEvent = globalEvent.slice(0);
              if (context.name) {
                pluginEvent.push(context.name);
              }
              // typecast objects into an array
              if (!(objects instanceof Array)) {
                objects = [objects];
              }
              results.push(function () {
                var _this2 = this;

                var i, len, results1;
                results1 = [];
                for (i = 0, len = objects.length; i < len; i++) {
                  object = objects[i];
                  results1.push($(object).each(function (index, element) {
                    var base, base1, globalIndex, pluginData, pluginIndex, pluginName, ref, ref1, ref2, results2;
                    (base = _this2._elements)[eventType] || (base[eventType] = []);
                    // if binding on a plugin
                    // ...and the element has not already been bound globally
                    // ...and the element has not already been bound to the plugin
                    if (context.name) {
                      globalIndex = _this2._elements[eventType].indexOf(element);
                      // if element is not in global array...
                      if (globalIndex === -1) {
                        (base1 = context._elements)[eventType] || (base1[eventType] = []);
                        // if element is not in plugin array...
                        if (context._elements[eventType].indexOf(element) === -1) {
                          return _this2._registerElement(context, element, eventType);
                        }
                      }
                      // if binding globally
                      // ...and the element has not already been bound globally
                    } else if (_this2._elements[eventType].indexOf(element) === -1) {
                      _this2._registerElement(context, element, eventType);
                      ref = _this2.plugins;
                      // loop through plugins and remove global element if it exists
                      results2 = [];
                      for (pluginName in ref) {
                        pluginData = ref[pluginName];
                        pluginIndex = (ref1 = pluginData._elements[eventType]) != null ? ref1.indexOf(element) : void 0;
                        if (pluginIndex !== -1) {
                          results2.push((ref2 = pluginData._elements[eventType]) != null ? ref2.splice(pluginIndex, 1) : void 0);
                        } else {
                          results2.push(void 0);
                        }
                      }
                      return results2;
                    }
                  }));
                }
                return results1;
              }.call(this));
            }
            return results;
          }

          // Set data that will always be tracked

        }, {
          key: 'setData',
          value: function setData(data) {
            var context = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : this;

            return $.extend(true, context._data, data);
          }

          // Set options that will always be passed to the send method

        }, {
          key: 'setOptions',
          value: function setOptions(options) {
            var context = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : this;

            return $.extend(true, context._options, options);
          }

          // Set callbacks that will be run each time data is tracked

        }, {
          key: 'setCallback',
          value: function setCallback(name, callback) {
            var context = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : this;

            var allowedCallbacks, base;
            allowedCallbacks = ['before', 'after'];
            if (allowedCallbacks.indexOf(name) === -1) {
              throw new Error('ATRACKT ERROR: `setCallback` - `' + name + '` is not a valid callback.  Only callbacks allowed are: ' + allowedCallbacks.join(', '));
            }
            (base = context._callbacks)[name] || (base[name] = []);
            return context._callbacks[name].push(callback);
          }

          // Determine if data can be tracked or not

        }, {
          key: 'track',
          value: function track(data) {
            var options = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

            var _this3 = this;

            var event = arguments[2];
            var context = arguments[3];

            var delay, trackPlugins;
            if (context != null ? context.name : void 0) {
              // Add the plugin name to the options if it exists
              options._plugin = context.name;
            }
            trackPlugins = function trackPlugins() {
              var eventNamespace, pluginData, pluginName, ref, ref1, results;
              ref = _this3.plugins;
              // Loop through each plugin and check if the data should be tracked
              results = [];
              for (pluginName in ref) {
                pluginData = ref[pluginName];
                // If tracking is triggered by an event, make sure the event namespace matches the plugin or is global
                if (eventNamespace = event != null ? (ref1 = event.handleObj) != null ? ref1.namespace : void 0 : void 0) {
                  if (eventNamespace === 'atrackt' || eventNamespace === 'atrackt.' + pluginName) {
                    results.push(_this3._trackJqueryObject(pluginData, data, options, event));
                  } else {
                    results.push(void 0);
                  }
                } else {
                  if (!options._plugin || options._plugin === pluginName) {
                    // track jQuery objects
                    if (data instanceof jQuery) {
                      results.push(_this3._trackJqueryObject(pluginData, data, options, event));
                    } else {
                      // track everything else (html element or an object)
                      results.push(_this3._track(pluginData, data, options, event));
                    }
                  } else {
                    results.push(void 0);
                  }
                }
              }
              return results;
            };
            // track with optional delay (in milliseconds)
            delay = options.delay;
            if (delay) {
              return setTimeout(function () {
                return trackPlugins();
              }, delay);
            } else {
              return trackPlugins();
            }
          }

          // Introduce an element into the Atrackt eco-system
          // * add the element to an elements array (global or plugin)
          // * bind the appropriate event (global or plugin)

        }, {
          key: '_registerElement',
          value: function _registerElement(context, element, eventType) {
            var globalEvent, pluginEvent;
            context._elements[eventType].push(element);
            // create event namespaces
            globalEvent = [eventType, 'atrackt'];
            if (context.name) {
              pluginEvent = globalEvent.slice(0);
              if (context.name) {
                pluginEvent.push(context.name);
              }
            } else {
              pluginEvent = globalEvent;
            }
            // bind event
            $(element).off(globalEvent.join('.'));
            return $(element).on(pluginEvent.join('.'), function (e) {
              return context.track(this, {}, e);
            });
          }

          // Loop through a jquery object and track each element

        }, {
          key: '_trackJqueryObject',
          value: function _trackJqueryObject(plugin, data, options, event) {
            var _this4 = this;

            // loop through each jquery object element and track it
            return $(data).each(function (index, element) {
              return _this4._track(plugin, element, options, event);
            });
          }

          // Track data with a particular plugin
          // * collect meta data
          // * run callbacks
          // * call plugin send method

        }, {
          key: '_track',
          value: function _track(plugin, data, options, event) {
            var callback, i, j, k, l, len, len1, len2, len3, metaData, optionsCopy, ref, ref1, ref2, ref3, results, trackingData, trackingOptions;
            metaData = this._getTrackObject(data, event);
            if (!metaData) {
              throw new Error('ATRACKT ERROR: `track` - Only valid selectors, jquery objects, or html nodes are supported.');
            }
            // prepare tracking data
            trackingData = $.extend(true, {}, this._data, plugin._data, options._data || {}, metaData);
            // remove any data in the options & plugin options in the global options
            optionsCopy = $.extend(true, {}, options, options[plugin.name] || {});
            delete optionsCopy._data;
            delete optionsCopy[plugin.name];
            trackingOptions = $.extend(true, {}, this._options, plugin._options, optionsCopy);
            ref = this._callbacks.before || [];
            // run global before callbacks
            for (i = 0, len = ref.length; i < len; i++) {
              callback = ref[i];
              if (typeof callback === "function") {
                callback(trackingData, trackingOptions);
              }
            }
            ref1 = plugin._callbacks.before || [];
            // run plugin before callbacks
            for (j = 0, len1 = ref1.length; j < len1; j++) {
              callback = ref1[j];
              if (typeof callback === "function") {
                callback(trackingData, trackingOptions);
              }
            }
            // run the custom function if it exists
            if (data instanceof jQuery || data.nodeType === 1) {
              if (typeof $(data).data('atrackt-function') === 'function') {
                $.proxy($(data).data('atrackt-function'), data)(trackingData, trackingOptions);
              }
            }
            // call plugin's send method
            plugin.send(trackingData, trackingOptions);
            ref2 = plugin._callbacks.after || [];
            // run plugin after callbacks
            for (k = 0, len2 = ref2.length; k < len2; k++) {
              callback = ref2[k];
              if (typeof callback === "function") {
                callback(trackingData, trackingOptions);
              }
            }
            ref3 = this._callbacks.after || [];
            // run global after callbacks
            results = [];
            for (l = 0, len3 = ref3.length; l < len3; l++) {
              callback = ref3[l];
              results.push(typeof callback === "function" ? callback(trackingData, trackingOptions) : void 0);
            }
            return results;
          }

          // Gets default meta data
          // * add categories and value attributes for elements
          // * add location & event attributes

        }, {
          key: '_getTrackObject',
          value: function _getTrackObject(data, event) {
            var $el;
            // add element related data
            if (data instanceof jQuery || data.nodeType === 1) {
              $el = $(data);
              data = {
                _el: data,
                _categories: this._getCategories($el),
                _value: this._getValue($el)
              };
            }
            // add location
            data._location = this._getLocation();
            // add event if it exists
            if (event != null ? event.type : void 0) {
              data._event = event.type;
            }
            return data;
          }

          // Get the location value

        }, {
          key: '_getLocation',
          value: function _getLocation() {
            return $('body').data('atrackt-location') || $(document).attr('title') || document.URL;
          }

          // Crawl the elements parents and collectiong dom categories

        }, {
          key: '_getCategories',
          value: function _getCategories($el) {
            var catArray;
            catArray = [];
            if ($el.data('atrackt-category')) {
              // add this element's data-track key/value
              catArray.unshift($el.data('atrackt-category'));
            }
            // add this element's parents data-trackkey/value
            $el.parents('[data-atrackt-category]').each(function () {
              return catArray.unshift($(this).data('atrackt-category'));
            });
            return catArray;
          }

          // Get an element value based on a variety of options

        }, {
          key: '_getValue',
          value: function _getValue($el) {
            return $el.data('atrackt-value') || $el.val() || $el.attr('title') || $el.attr('name') || $el.text().trim() || $el.attr('id') || $el.attr('class');
          }
        }]);

        return Atrackt;
      }();

      ;

      // Default global attributes
      Atrackt.prototype.plugins = {};

      Atrackt.prototype._data = {};

      Atrackt.prototype._options = {};

      Atrackt.prototype._elements = {};

      Atrackt.prototype._callbacks = {};

      return Atrackt;
    }.call(this);
    return window.Atrackt || (window.Atrackt = new Atrackt());
  });
}).call(undefined);
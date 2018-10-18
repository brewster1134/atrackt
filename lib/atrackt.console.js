'use strict';

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

(function () {
  /*
  Atrackt Tracking Library
  https://github.com/brewster1134/atrackt
  @version 1.1.0
  @author Ryan Brewster
  */
  (function (factory) {
    if (typeof define !== "undefined" && define !== null ? define.amd : void 0) {
      return define(['jquery', 'atrackt', 'jquery.scrollTo'], function ($, Atrackt) {
        return factory($, Atrackt.constructor);
      });
    } else {
      return factory(window.jQuery, window.Atrackt.constructor);
    }
  })(function ($, Atrackt) {
    var AtracktConsole;
    AtracktConsole = function (_Atrackt) {
      _inherits(AtracktConsole, _Atrackt);

      // Build the console html and add it to the dom

      function AtracktConsole() {
        _classCallCheck(this, AtracktConsole);

        var consoleHtml;
        consoleHtml = "<div id=\"atrackt-console\">\n  <h4>Location: <span id=\"atrackt-location\"></span></h4>\n  <table>\n    <thead>\n      <tr>\n        <th>Plugin</th>\n        <th>Event</th>\n        <th>Categories</th>\n        <th>Value</th>\n      </tr>\n    </thead>\n    <tbody>\n    </tbody>\n  </table>\n<div>";

        var _this = _possibleConstructorReturn(this, (AtracktConsole.__proto__ || Object.getPrototypeOf(AtracktConsole)).call(this, consoleHtml));

        _this.$console = $(consoleHtml);
        $('#atrackt-location', _this.$console).text(_this._getLocation());
        $('body').addClass('atrackt-console').prepend(_this.$console);
        _this._setPlugins();
        _this._renderConsoleElements();
        return _this;
      }

      // Override the custom class to just log tracking data to the console

      _createClass(AtracktConsole, [{
        key: 'setPlugin',
        value: function setPlugin(pluginName, plugin) {
          _get(AtracktConsole.prototype.__proto__ || Object.getPrototypeOf(AtracktConsole.prototype), 'setPlugin', this).call(this, pluginName, plugin);
          if (plugin) {
            // backup original send method and replace send with a simple console log
            plugin._send = plugin.send;
            return plugin.send = function (data, options) {
              return console.log(plugin.name, data, options);
            };
          }
        }
      }, {
        key: '_setPlugins',
        value: function _setPlugins() {
          var plugin, pluginName, ref, results;
          ref = this.plugins;
          results = [];
          for (pluginName in ref) {
            plugin = ref[pluginName];
            if (!plugin._send) {
              results.push(this.setPlugin(pluginName, plugin));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }

        // Re-render console elements

      }, {
        key: '_renderConsoleElements',
        value: function _renderConsoleElements() {
          var element, elements, eventType, i, len, plugin, pluginName, ref, ref1, results;
          $('tbody', this.$console).empty();
          ref = this._elements;
          // Render global elements
          for (eventType in ref) {
            elements = ref[eventType];
            for (i = 0, len = elements.length; i < len; i++) {
              element = elements[i];
              this._renderConsoleElement('ALL', element, eventType);
            }
          }
          ref1 = this.plugins;
          // Render all plugin elements
          results = [];
          for (pluginName in ref1) {
            plugin = ref1[pluginName];
            results.push(function () {
              var ref2, results1;
              ref2 = plugin._elements;
              results1 = [];
              for (eventType in ref2) {
                elements = ref2[eventType];
                results1.push(function () {
                  var j, len1, results2;
                  results2 = [];
                  for (j = 0, len1 = elements.length; j < len1; j++) {
                    element = elements[j];
                    results2.push(this._renderConsoleElement(pluginName, element, eventType));
                  }
                  return results2;
                }.call(this));
              }
              return results1;
            }.call(this));
          }
          return results;
        }

        // Add console events to elements

      }, {
        key: '_registerElement',
        value: function _registerElement(context, element, event) {
          var contextName;
          _get(AtracktConsole.prototype.__proto__ || Object.getPrototypeOf(AtracktConsole.prototype), '_registerElement', this).call(this, context, element, event);
          contextName = context.name ? context.name : 'ALL';
          return this._renderConsoleElement(contextName, element, event);
        }

        // Add a single element to the console

      }, {
        key: '_renderConsoleElement',
        value: function _renderConsoleElement(contextName, element, eventType) {
          var $rowEl, $trackEl, elementValueId, self, trackObject;
          self = this;
          // Get element meta data
          trackObject = this._getTrackObject(element, eventType);
          // Create unique id
          elementValueId = trackObject._categories.slice(0);
          elementValueId.unshift(trackObject._value);
          elementValueId.unshift(eventType);
          elementValueId = elementValueId.join('-').toLowerCase().replace(/[^a-z]/g, '');
          // Build console element html
          $rowEl = $('<tr><td>' + contextName + '</td><td>' + eventType + '</td><td>' + trackObject._categories + '</td><td>' + trackObject._value + '</td></tr>');
          $trackEl = $(element);
          // Add error class if elements track duplicate data
          if ($('tr#' + elementValueId, this.$console).length) {
            $('tr#' + elementValueId, this.$console).addClass('error');
            $rowEl.addClass('error');
          }
          // add row to console
          $('tbody', this.$console).append($rowEl);
          // Give id to both elements
          $rowEl.attr('id', elementValueId);
          $trackEl.attr('data-atrackt-id', elementValueId);
          // Add hover event to console element to highlight both the console and the tracked element
          return $rowEl.add($trackEl).hover(function () {
            $rowEl.addClass('atrackt-console-active');
            $trackEl.addClass('atrackt-console-active');
            // scroll to hovered element
            if ($.scrollTo) {
              if (this === $rowEl[0]) {
                return $.scrollTo($trackEl, 0, {
                  offset: {
                    top: -300
                  }
                });
              } else if (this === $trackEl[0]) {
                return self.$console.scrollTo($rowEl, 0, {
                  offset: {
                    top: -100
                  }
                });
              }
            }
          }, function () {
            $rowEl.removeClass('atrackt-console-active');
            return $trackEl.removeClass('atrackt-console-active');
          });
        }
      }]);

      return AtracktConsole;
    }(Atrackt);
    if (location.href.indexOf('atracktConsole') > -1) {
      return window.Atrackt = new AtracktConsole();
    }
  });
}).call(undefined);
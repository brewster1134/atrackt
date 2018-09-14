'use strict';

(function () {
  /*
  Atrackt Omniture Plugin
  https://github.com/brewster1134/atrackt
  @author Ryan Brewster
  @version 1.0.6
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
    return Atrackt.setPlugin('omniture', {
      // default options
      options: {
        trackingType: 'o',
        charReplaceRegex: /[^\x20-\x7E]/g,
        version: 14,
        delimiters: {
          linkName: '/',
          category: '|'
        },
        linkTrackVars: ['products', 'events'],
        propMap: {
          _location: 'prop1',
          _categories: 'prop2',
          _value: 'prop3',
          _event: 'prop4'
        }
      },
      send: function send(data, options) {
        var arg, ref, ref1;
        // return if the site catalyst library isnt loaded
        if (typeof s === "undefined" || s === null) {
          return;
        }
        $.extend(true, this.options, options);
        data._categories = (ref = data._categories) != null ? ref.join(this.options.delimiters.category) : void 0;
        data = this._translatePropMap(data);
        this._buildSObject(data);
        if (this.options.page && s.t != null) {
          s.t();
        } else if (s.tl != null) {
          arg = ((ref1 = this.options.el) != null ? ref1.attr('href') : void 0) ? this.options.el[0] : true;
          s.tl(arg, this.options['trackingType'], this._buildLinkName(data));
        }
        return data;
      },
      // omniture specific
      _buildSObject: function _buildSObject(obj) {
        var key, linkTrackVars, value;
        switch (this.options.version) {
          case 14:
            linkTrackVars = this.options.linkTrackVars;
            for (key in obj) {
              value = obj[key];
              linkTrackVars.push(key);
            }
            s.linkTrackVars = linkTrackVars.join(',');
            $.extend(s, obj);
            break;
          default:
            s.contextData = obj;
        }
        return s;
      },
      _buildLinkName: function _buildLinkName(obj) {
        var linkName;
        linkName = [obj[this.options.propMap._location], obj[this.options.propMap._categories], obj[this.options.propMap._value]];
        return linkName.join(this.options.delimiters.linkName);
      },
      _translatePropMap: function _translatePropMap(obj) {
        var _this = this;

        var _globalData;
        if (this.options.version > 14) {
          return obj;
        }
        _globalData = {};
        $.each(obj, function (k, v) {
          var base;
          return _globalData[_this._keyLookup(k)] = v != null ? typeof (base = v.toString()).replace === "function" ? base.replace(_this.options.charReplaceRegex, '') : void 0 : void 0;
        });
        return _globalData;
      },
      _keyLookup: function _keyLookup(key) {
        var _newKey;
        _newKey = this.options.propMap[key];
        return _newKey || key;
      }
    });
  });
}).call(undefined);
# Atrackt
---

A library for making complex tracking & analytics easier.

## Dependencies

* [jQuery](http://jquery.com)
* [Underscore.js](http://underscorejs.org)

## Tracking An Element

When an element is tracked, there are several basic values that are included.

* *location*: This represents the page that tracking events come from. It will track the first value it finds from the following:
  * `$('body').data('track-location')` - The custom value attached to the body element's `data-track-location` attribute.
  * `$(document).attr('title')` - The page title
  * `document.URL` - The page URL

* *categories*: This represents the elements location on the page.  It traverses the dom from the element and collects data along the way.  Specifically any parent element with the `data-track-cat` value set (including the element itself).
  * In the exmaple below, if the `a` element is tracked, the value for categories would be an array of `[ 'one', 'two', 'three' ]`

```html
<div data-track-cat='one'>
  <div data-track-cat='two'>
    <a data-track-cat='three'></a>
  </div>
</div>
```

* *value*: This reperesents the value of the tracked element.  It will track the first value it finds from the following:
  * `title` - The value of the title attribute
  * `name` - The value of the name attribute
  * `text` - The text value of the element. This contains only text and will not include any HTML.
  * `val` - The value (if a form element)
  * `id` - The value of the id attribute
  * `class` - The value of the id attribute

* *event*: This represents the type of event that fired the tracking call.

* *plugin*: The name of the plugin responsible for tracking the element

## Usage

* Download the [script](https://raw.github.com/brewster1134/atrackt/master/js/atrackt.js) _(right-click & save as)_
* Add the script to your page
  * `<script src="atrackt.js"></script>`
* Add a plugin to your page _([or write your own!](#registering-plugins))_ _AFTER_ `atrackt.js`
  * `<script src="atrackt.plugin.js"></script>`

That's it!  The settings from your plugin will bind events to elements and you can start tracking!

### Advanced Usage

#### `registerPlugin`

Call `registerPlugin` to quickly register a custom plugin.

The minimum a plugin needs is a `send` method.  This is a function that accepts the tracking object, and any additional options as an argument.  You can do additional processing on the object and pass it wherever you need to track it.

```coffee
Atrackt.registerPlugin 'testPlugin',
  send: (obj, options) ->
    # do stuff to the object and send it somewhere
```

#### `bind` & `unbind`

Typically just creating a send method to manually track objects is not enough.  Normally you want to bind a whole bunch of elements to an event _(or events)_ to track.

Call 'bind' and 'unbind' to register jquery selectors or jquery objects to automatically fire tracking events.  These methods accept a special events object.

The format is an event type as the key, and an array of jquery selectors, or a jquery object as the value.  Any matching selectors or objects will be automatically bound and tracked with the given event.

```coffee
# bind on ALL registered plugins
Atrackt.bind
  click: ['a']
  hover: ['a', 'button' ]

# bind on a specific plugin
Atrackt.plugins['testPlugin'].bind
  click: ['a']
  hover: ['a', 'button' ]
```

The same options are available to `unbind` elements.

```coffee
Atrackt.unbind
  click: ['a']

Atrackt.plugins['testPlugin'].unbind
  click: ['a']
```

You can also bind/unbind a specific element instead of a selector.  This is helpful if you generate new elements dynamically and need to track them as they are created.

```coffee
Atrackt.bind
  click: $('div#foo')

Atrackt.plugins['testPlugin'].bind
  click: $('div#foo')
```
#### `track`

Call 'track' to manually track any JS object.  It will add the additional Atrackt data and pass it to each registered plugin to be tracked.

It accepts 3 arguments.

* [Object]  The data you want to track
* [Object]  Any options you want to send the plugin to customize tracking
* [Event]   An event.  If an event is passed, it will be check that the event namespace matches each plugin.

```coffee
Atrackt.track
  foo: 'bar'
```

#### `refresh`

Call `refresh` if you need to re-scan the dom and re-bind elements based on the `bind` and `unbind` data.

```coffee
Atrackt.refresh()
```

Set `data-track-function` to add a custom function to a specific element.  This function will be run before the send method is called.  You can then modify the data or do any number of things before the data is tracked.

It accepts 3 arguments

* [Object]  The generated data being tracked
* [jQuery Object] The element being tracked
* [Event] The event that triggered the tracking

For example, you could track things conditionally...

```coffee
$('a#foo').data 'track-function', (data, el) ->
  if data.value == 'foo' || el.data('foo') == true
    data.foo = true
  else
    data.foo = false
```

#### `setOptions`

Call `setOptions` on a specific plugin if you need to pass custom options to your plugin.  This will will set attributes on the `options` object in your plugin.  If your plugin already has default options set, the custom options well simply extend over them.

_setOptions is not available to set options on all plugins at once.  options should be specific to a plugin_

```coffee
Atrackt.registerPlugin 'testPlugin',
  send: ->
  options:
    foo: 'foo'

Atrackt.plugins['testPlugin'].setOptions
  foo: 'bar'
```


#### `setGlobalData`

Call `setGlobalData` to add attributes that will be tracked with every tracking call.  Global data will _NOT_ overwrite the main values provided by Atrackt (location, categories, value, event).

```coffee
# set globalData for all plugins
Atrackt.setGlobalData
  foo: 'bar'

# set globalData for a specific plugin
Atrackt.plugins['testPlugin'].setGlobalData
  foo: 'bar'
```

#### `setCallback`

Call `setCallback` to assign functions to be run before and after the plugin's send function.  Currently the only callbacks supported are 'before' and 'after'

```coffee
# set before callback for all plugins
Atrackt.setCallback 'before', (data, options ,event) ->

# set after callback for a specific plugin
Atrackt.plugins['testPlugin'].setCallback 'after', (data, options ,event) ->
```

## Debugging Console

To better visualize what elements you are tracking, you can load the debugging console.

* Download the [script](https://raw.github.com/brewster1134/atrackt/master/js/atrackt.debug.js) _(right-click & save as)_
* Add the script to your page _AFTER_ `atrackt.js`
  * `<script src="atrackt.debug.js"></script>`

Simply add the url paramater `debugTracking=true` to the end of any URL to show the debugging console.  For example `http://foo.com?debugTracking=true`

It is a bit crude, but it gives you a visual overview of your elements.

* The console lists all the elements currently being tracked along with their various values.
* If you hover over an element in the console, it will scroll to that element on your page and highlight it.
* If you hover over a tracked element on your page, it will scroll to that entry in your console and highlight it.
* Clicking on a row in the console will refresh any stale data on the element.  This can happen if an element is tracked before it gets added to the dom.  Since it doesn't have any parent elements yet, the categories column will be empty.
* The debugger will also show you errors if you have any.
  * If you have multiple elements tracking the same data, they will be highlighted and show the error in the error column. **NOTE** Since duplicate items will have the same ID, the debugging console UI will not be able to scroll to BOTH duplicate elements.  Check your javascript console to see the  offending elements.

## Demo

Download the project and open `demo/index.html` in your browser.

Click the link or visit `demo/index.html?debugTracking=true` to view the debugging console.

## Development

### Dependencies

* [CoffeeScript](http://coffeescript.org)

Do **NOT** modify any `.js` files in the `js` directory!  Modify the files in the `src` directory and compile them with coffeescript into the js directory.

This will be done automatically if you are running the tests with testem _(see the [Testing](#testing) section below)_, or you can compile it with the CoffeeScript command line tool.

`coffee -o js/ -c src/*.coffee && coffee -o js/plugins/ -c src/plugins/*.coffee`

## Testing

### Dependencies

* Node.js & NPM
  * From [nodejs.org](http://nodejs.org)
  * Using a [package manager](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager)
    * HomeBrew: 'brew install node'
* [Testem](https://github.com/airportyh/testem)
  * `npm install testem -g`

### Optional

* [PhantomJS](http://phantomjs.org)
  * HomeBrew: `brew install phantomjs`

Simply run `testem`

### To-Do

* pass an element to refresh() to scope to
* suport binding an element only if it matches a plugins selector rules (this requires some serious thought for the API)
* IE testing
* Support multiple callbacks

### CHANGE LOG
0.12  Added setCallback

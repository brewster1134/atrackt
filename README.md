# Atrackt
---

A library for making complex tracking & analytics easier.

## Dependencies

* [jQuery](http://jquery.com)
* [Underscore.js](http://underscorejs.org)

## Tracking An Element

When an element is tracked, there are several peices that are included.

* location: This represents the page that tracking event happened. It will track the first value it finds from the following:
  * `$('body').data('track-location')` - The custom value attached to the body element's `data-track-location` attribute.
  * `$(document).attr('title')` - The page title
  * `document.URL` - The page URL

* categories: This represents the elements location on the page.  It traverses the dom from the element the event fires on and collects all the `data-track-cat` values along the way (including the element itself).
  * In the exmaple below, if the `a` element is tracked, the value for the categories attribute will be an array of `[ 'one', 'two', 'three' ]`

```html
<div data-track-cat='one'>
  <div data-track-cat='two'>
    <a data-track-cat='three'></a>
  </div>
</div>
```

* value: This reperesents the value of the tracked element.  It will track the first value it finds from the following:
  * `title` - The value of the title attribute
  * `name` - The value of the name attribute
  * `text` - The text value of the element. This contains only text and will not include any HTML.
  * `val` - The value (if a form element)
  * `id` - The value of the id attribute
  * `class` - The value of the id attribute

* event: This represents the type of event that fired the tracking call.

* plugin: The name of the plugin responsible for tracking the element

## Usage

* Download the [script](https://raw.github.com/brewster1134/atrackt/master/js/atrackt.js) _(right-click & save as)_
* Add the script to your page
  * `<script src="atrackt.js"></script>`
* Add a plugin to your page _([or write your own!](#registering-plugins))_ _AFTER_ `atrackt.js`
  * `<script src="atrackt.plugin.js"></script>`

That's it!  The settings from your plugin will bind events to elements and you can start tracking!

### Advanced Usage

To manually track any JS object, just pass it as an argument to the track method.

```coffee
Atrackt.track({ foo: 'bar' })
```

Call `refresh` If you add new elements to your page you may need to re-scan the dom to re-bind those elements.

```coffee
Atrackt.refresh()
```

You can also bind custom functions to a specific element using the `data-track-function` attribute.  This function will be run before the send method is called.  It allows for any custom manipulatons to the tracking object on a per-element basis. For example, you could track things conditionally...

```coffee
# You can only bind to events that exist so load your scripts at the end of the page, or fire them after the dom is ready with jQuery's document.ready event.
$ ->
  $('a#foo').data 'track-function', (data) ->
    if data.value == 'foo'
      data.foo = true
```

#### Registering Plugins

Common plugins can be found in `js/plugins` and will self-register themselves by including them on your page, but if you would like custom tracking you can quickly create a new plugin with the `registerPlugin` method.

The minimum a plugin needs is a `send` method.  This is a function that accepts the tracking object as an argument.  You can do additional processing on the object and send it off however you need.

```coffee
Atrackt.registerPlugin 'testPlugin',
  send: (obj) ->
    # do stuff to the object and send it somewhere
```

Typically just creating a send method to manually track objects is not enough.  Normally you want to bind a whole bunch of elements to an event _(or events)_ to track.

You can accomplish this by calling the `bind` method. The method accepts an object with the event type as the key, and an array of jquery selectors as the values.  Any matching selectors will be automatically bound and tracked with the given event.

```coffee
# unbind from ALL registered plugins
Atrackt.bind
  click: ['a']
  hover: ['a', 'button' ]

# unbind from a specific plugin
Atrackt.plugins['testPlugin'].bind
  click: ['a']
  hover: ['a', 'button' ]
```

The same options are available to `unbind` elements.

```coffee
Atrackt.unbind
  click: ['a']
  hover: ['a', 'button' ]

Atrackt.plugins['testPlugin'].unbind
  click: ['a']
  hover: ['a', 'button' ]
```

If you need your plugin to accept custom options, you can call the `setOptions` method.  This will be available in your plugin under the key `options`.  If your plugin already has default options, the custom options well simply extend over them.

```coffee
Atrackt.registerPlugin 'testPlugin',
  send: ->
  options:
    foo: 'foo'

Atrackt.plugins['testPlugin'].setOptions
  foo: 'bar'
```

## Debugging Console

To better visualize what elements you are tracking, you can load the debugging console.

* Download the [script](https://raw.github.com/brewster1134/atrackt/master/js/atrackt.debug.js) _(right-click & save as)_
* Add the script to your page _AFTER_ `atrackt.js`
  * `<script src="atrackt.debug.js"></script>`

Now simply add the url paramater `debugTracking=true` to the end of any URL to show the debugging console.  Like so `http://foo.com?debugTracking=true`

It is a bit crude, but it gives you a visual overview of your elements.

* The console lists all the elements currently being tracked along with their various values.
* If you hover over an element in the console, it will scroll to that element on your page and highlight it.
* If you hover over a trakced element on your page, it will scroll to that entry in your console and highlight it.
* The debugger will also show you errors if you have any.
  * If you have multiple elements tracking the same data, they will turn red and show the error in the error column. **NOTE** Since duplicate items will have the same ID, the console will not be able to scroll to BOTH duplicate elements.  You can identify the offending elements in the javascript console.

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

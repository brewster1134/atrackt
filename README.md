# Atrackt
---

A library for making complex tracking & analytics easier.

## Dependencies

* [jQuery](http://jquery.com)

### Optional (But Recommended)

* [Live Query](https://github.com/brandonaaron/livequery)
  * Allows tracking new elements added to the page after the initial load (via ajax, etc.)

## Tracking An Element

When an element is tracked, there are several peices that are included.

* location: This represents the page that tracking event happened. It will track the first value it finds from the following:
  * `$('body').data('track-location')` - A custom value attached to the `body` element's `data-track-location`
  * `$(document).attr('title')` - The page's title value
  * `document.URL` - The URL of the page

* categories: This represents the elements location on the page.  It traverses the dom from the element the event fires on and collects all the `data-track-cat` values along the way (including the element itself).
  * For example... In the exmaple below, if the `a` element is tracked, the categories value will be an array containing `[ 'one', 'two', 'three' ]`

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

That's it!  The settings from your plugin will register events to elements and start tracking!

### Advanced Usage

To manually track any JS object, just pass it as an argument to the track method.

```coffee
Atrackt.track(object)
```

If you add new elements to your page (and are not using liveQuery) you can scan the dom again and re-bind elements.

```coffee
Atrackt.refresh()
```

You can also bind custom functions to a specific element using the `data-track-function` attribute.  The allows for any last minute custom attributes you want to include. For example, you could track things conditionally...

```coffee
$('a#foo').data 'track-function', (data) ->
  if data.value == 'foo'
    data.foo = true
```

#### Registering Plugins

Common plugins can be found in `js/plugins` and will self-register themselves by including them on your page, but if you would like custom tracking, you can quickly create a new plugin by calling the `registerPlugin` method.

The minimum a plugin needs is a `send` method.  This is a function that accepts a tracking object as an argument.  From here, you can do additional processing on the object and send it where ever you like to track it.

```coffee
Atrackt.registerPlugin 'testPlugin',
  send: (obj) ->
    # do stuff to the object and send it somewhere
```

Typically just creating a send method for you to manually track objects is not enough.  Normally you want to bind a whole bunch of elements to an event _(or events)_ to track.

You can accomplish this by calling the `bindEvents` method. an events object.  The method accepts click events as the key, and an array of jquery selectors as the values.  Any matching selectors will be bound and tracked when that event fires.

```coffee
Atrackt.plugins['testPlugin'].bindEvents
  # track every anchor on click
  click: ['a']
  # track every anchor and button on hover
  hover: ['a', 'button' ]
```

If you would like your plugin to accept custom objects, you can call the `setOptions` method.  If your plugin already has an options object, custom options well extend over them.

```coffee
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
  * If you have multiple elements tracking the same data, they will turn red and show the error in the error column. **NOTE** Since duplicate items will have the same ID

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

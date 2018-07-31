[![docs](http://inch-ci.org/github/brewster1134/atrackt.svg?branch=master)](http://inch-ci.org/github/brewster1134/atrackt)
[![build](https://travis-ci.org/brewster1134/atrackt.svg?branch=master)](https://travis-ci.org/brewster1134/atrackt)
[![coverage](https://api.codeclimate.com/v1/badges/aa9b7b5f4dae369df0b8/test_coverage)](https://codeclimate.com/github/brewster1134/atrackt/test_coverage)
[![code climate](https://codeclimate.com/github/brewster1134/atrackt/badges/gpa.svg)](https://codeclimate.com/github/brewster1134/atrackt)

# Atrackt
A library for making complex tracking & analytics easier.

## Upgrading from 0.x
* All `data-track-` attributes are now `data-atrackt-`
* `.bind` is now `.setEvent`
* `.setGlobalData` is now `.setData`
* `data-trackt-function` now only accepts 2 arguments (data & options). use `this` to access the element

## Dependencies
* [jQuery](http://jquery.com)

## Quick Usage
* Load the atrackt core library & any plugin(s)
  * `<script src="/lib/atrackt.js"></script>`
  * `<script src="/lib/plugins/atrackt.omniture.js"></script>`
* Bind something to track

```coffee
Atrackt.setEvent
  click: 'a, button'
```
##### That's it.  When any any button or anchor is clicked on, it will be tracked with omniture.

## Methods

###### A note on all methods... methods called on `Atrackt` are consider global, and will include all registered plugins.  To target a plugin directly, you can access it through the plugins object.

```coffee
Atrackt.plugins.omniture.setEvent
  click: 'a.omniture'
```

---
#### `setEvent`
The `setEvent` method accepts a custom event object which uses the event name as the key, and a css selector, jquery object, or html node as the value.

```coffee
Atrack.setEvent
  click: '.css-selector'
  mouseenter: $('.jquery-object')
  customevent: document.querySelector('.html-node')
```

You can also pass in an array of multiple object types

```coffee
Atrack.setEvent
  click: [ '.css-selector', $('.jquery-object'), document.querySelector('.html-node') ]
```

---
#### `setData`
You can add data globally that will always be included with every tracking call using `setData`.

```coffee
Atrackt.setData
  foo: 'bar'
```

---
#### `setOptions`
You can add options globally that will always be included with every tracking call using `setOptions`.

```coffee
Atrackt.setOptions
  foo: 'bar'
```

---
#### `setCallback`
Callbacks can be run before or after a tracking call is made.  You must specify `before` or `after`, along with a function that will be run.  Callbacks accepts 2 arguments, 1 for data, and 1 for options.  In `before` callbacks, you can alter those objects and they will be tracked.

```coffee
Atrackt.setCallback 'before', (data, options) ->
  data.foo = 'bar'
  options.foo = 'bar'
```

---
#### `track`
Instead of binding elements to events, you can track data directly.  This is helpful for tracking different states of your app.

You can track standard javascript objects, jquery objects, or html nodes.

The `track` method accepts 2 methods, data & options

```coffee
Atrackt.track
  fooData: 'bar'
,
  fooOption: 'bar'
```

---
## Element Tracking
When an element is tracked, there are several basic values that are included. See more information about each value below.

* `_categories` represent an elements virtual position on the page
* `_location` represents the page that tracking events come from
* `_value` represents an elements unique value
* `_event` type of event (if triggered by an event)

---
#### `_categories`

It traverses the dom from the element and collects data along the way, in reverse order.  Specifically any parent element with the `data-atrackt-category` value set (including the element itself).
  * In the example below, if the `a` element is tracked, the value for categories would be an array of `[ 'one', 'two', 'three' ]`

```html
<div data-atrackt-category='one'>
  <div data-atrackt-category='two'>
    <a data-atrackt-category='three'></a>
  </div>
</div>
```

---
#### `_location`
It will track the first value it finds from the following:
  * `$('body').data('atrackt-location')` Data attribute on the body
  * `$(document).attr('title')` The standard page title
  * `document.URL` The page URL

---
#### `_value`
  * `data-atrackt-value`  A custom value to explicitly set
  * `val`               The value (if a form element)
  * `title`             The value of the title attribute
  * `name`              The value of the name attribute
  * `text`              The text value of the element. This contains only text and will not include any HTML.
  * `id`                The value of the id attribute
  * `class`             The value of the class attribute

---
#### `_event`
If triggered by an event, this value will be the name of the event _(eg click, mouseenter, etc)_

---
##### Custom Function
On a per-element basis, you can add a custom function to the the `data-atrackt-function` data attribute that will be called each time that element is tracked. The function accepts 2 arguments, 1 for data, and 1 for options.  You can alter those objects before they are tracked.

```coffee
$('a#foo').data 'atrackt-function', (data, options) ->
  if options.hasColor
    data.color = $(@).css('color')
  else
    data.color = 'none'
```

## Creating Plugins
Creating new plugins for Atrackt is very simple.  At the bare minimum, you need a name, and a `send` method.  The `send` method is where all of the plugin logic should live to interact with whatever tracking strategy you are using.  Look at the source of the included plugins for better examples.

Call `setPlugin` to quickly register a custom plugin.

The minimum a plugin needs is a `send` method.  This is a function that accepts the tracking object, and any additional options as an argument.  You can do additional processing on the object and pass it wherever you need to track it.

---
#### `setPlugin`
```coffee
Atrackt.setPlugin 'testPlugin',
  send: (data, options) ->
    # do stuff
```

## Console
To better visualize what dom elements you are tracking, you can load the atrackt console.  When the console is loaded, no actual tracking calls will be made. Instead the data that would normally be passed to the plugins will be logged to the console to help with debugging.

* Load the atrackt.console library after the atrackt core library
  * `<script src="/lib/atrackt.js"></script>`
  * `<script src="/lib/atrackt.console.js"></script>`
* Visit the page with `?atracktConsole` at the end of thr URL

You should see a console show up at the top of your page that shows all the elements currently bound to events to be tracked.  When new elements are bound,  the console will update.

## Mutations
Sometimes elements you want to track get loaded asynchronously after page load.  Modern browsers support _Mutation Observers_ which you can tap into to make sure new elements you want to track, are automatically bound when they are added.  This code is not included in atrackt, but below is a simple example.

```coffee
# create a method that can be run on mutations
# do not worry about checking for only added nodes, or making sure elements do not get bound multiple times.
# atrackt will prevent duplicates, and not checked for added nodes is much more performant.
do attachEvents = ->
  Atrackt.setEvent
    click: ['a', 'button', '.atrackt-click']
    change: ['select']

# create an observer that calls your method
observe = ->
  observer = new MutationObserver (mutations) ->
    window.requestAnimationFrame ->
      attachEvents()

  observer.observe document.body,
    childList: true
    subtree: true    

# when the dom is loaded, initialize your observer
document.addEventListener 'DOMContentLoaded', ->
  observe()    
```

## Demo
Download the project and open `demo/index.html` in your browser for a simple demo.  Make sure to include `?atracktConsole` in the url if you want to use the console.

## Development

Dependencies are managed with [Yarn](https://yarnpkg.com)

```shell
yarn              # install dependencies
yarn exec testem  # compile assets & run tests
```

Do **NOT** modify any `.js` files!  Modify the coffee files in the `src` directory.  Testem will watch for changes and compile them to the `lib` directory.

## TODO
* rename location to title
* rename categories to location

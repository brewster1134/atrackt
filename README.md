# atrackt
---

A script for making tracking easier.

## Dependencies

* [jQuery](http://jquery.com)

### Optional (But Recommended)

* [Live Query](https://github.com/brandonaaron/livequery)
  * Allows tracking new elements added to the page after the initial load (via ajax, etc.)

## Usage

* Add the script to your page
  * `<script src="atrackt.js"></script>`
* Add a plugin to your page (or write your own! *see below)
  * `<script src="atrackt.siteCatalyst.js"></script>`

That's it!  The settings from your plugin will register events to elements and start tracking!

### Advanced Usage

To manually track any JS object, just pass it as an argument to the track method.

```js
Atrackt.track(object)
```

If you add new elements to your page (and are not using liveQuery) you can scan the dom again an re-bind elements.

```js
Atrackt.refresh()
```

#### Registering Plugins

Common plugins can be found in `js/plugins` and will self-register themselves by including them on your page, but if you would like custom tracking you can quickly create a new plugin by calling the `registerPlugin` method.

The minimum a plugin needs is a `send` method.  This is a function that accepts a tracking object as an argument.  You can do additional processing to the object and send it where ever you like to track it.

```js
<script>
  Atrackt.registerPlugin('testPlugin', {
    send: function(obj) {
      // do stuff to the object and send it somewhere
    }
  });
</script>
```

Typically though just creating a send method for you to manually track objects is not enough.  Normally you want to bind a whole bunch of elements to an event(s) to track.

You can accomplish this by passing an events object.  The events object accepts a click event as the key, and an array of jquery selectors as the value.  Any matching selectors will be bound and tracked when that event fires.

```js
<script>
  Atrackt.registerPlugin('testPlugin', {
    events: {
      // track every anchor on click
      click: ['a'],
      // track every anchor and button on hover
      hover: ['a', 'button' ]
    },
    send: function(obj) {
      // do stuff to the object and send it somewhere
    }
  });
</script>
```

## Demo

Download the project and open `demo/.index.html` in your browser.

## Development

### Dependencies

* [CoffeeScript](http://coffeescript.org)

Do **NOT** modify `atrackt.js` directly.  Modify `src/atrackt.coffee` and generate `atrackt.js`.

The can be done by either running testem _(see the Testing section below)_, or by compiling with CoffeeScript directly.

`coffee -o js/ -c src/atrackt.coffee && coffee -o js/plugins/ -c src/plugins/*.coffee`

## Testing

### Dependencies

* [Node.js](http://nodejs.org)
* [Testem](https://github.com/airportyh/testem)

### Optional

* [PhantomJS](http://phantomjs.org)

Simply run `testem`

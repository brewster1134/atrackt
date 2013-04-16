# atrackt
---

A script for making tracking easier.

## Dependencies

* [jQuery](http://jquery.com)

### Optional (But Recommended)

* [Live Query](https://github.com/brandonaaron/livequery)
  * Allows tracking new elements added to the page after the initial load (via ajax, etc.)

## Usage

_TODO_

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

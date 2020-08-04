# Atrackt

A library for making complex tracking & analytics easier

## API

> All methods can be called globally for all set plugins (`Atrackt.[METHOD NAME]`), or for an individual plugin (`Atrackt.plugins.[PLUGIN NAME].[METHOD NAME]`)

---

## Todo: Production

- easily include extra data for both elements and objects (via js w/out atrackt-function)
- easily include/change data for tracking objects (via js w/out atrackt-function)
- allow setting data and event via Atrackt.track
- rename location to title
- rename categories to location
- use [VisualEvent](https://github.com/DataTables/VisualEvent) as a reference to find elements with events

---

## Todo: Development

- webpack
  - add copy-pkg-json-webpack-plugin
  - generate LICENSE file
  - generate CHANGELOG
  - copy README.md, LICENSE, CHANGELOG
  - build demo
  - launch demo server
  - livereload
  - publish to github packages
  - transpile with babel
- add [jest](https://jestjs.io)
- add CI (github actions/travis/circle)
- add readme badges
- add configuration dot-files

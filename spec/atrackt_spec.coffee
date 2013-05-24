describe 'Atrackt', ->
  it 'should set the Atrackt object on window', ->
    expect(window.Atrackt).to.exist

  describe '#registerPlugin', ->
    before ->
      Atrackt.registerPlugin 'plugin',
        send: ->

    after ->
      Atrackt.plugins = {}

    it 'should add the plugin object to global plugins', ->
      expect(Atrackt.plugins['plugin']).to.exist

    it 'should create a bind function', ->
      expect(Atrackt.plugins['plugin'].bind).to.be.a 'function'

    it 'should create a unbind function', ->
      expect(Atrackt.plugins['plugin'].unbind).to.be.a 'function'

    it 'should create a setOptions function', ->
      expect(Atrackt.plugins['plugin'].setOptions).to.be.a 'function'

    it 'should create a setGlobalData function', ->
      expect(Atrackt.plugins['plugin'].setGlobalData).to.be.a 'function'

    it 'should create a setCallback function', ->
      expect(Atrackt.plugins['plugin'].setCallback).to.be.a 'function'

    context 'when registering an invalid plugin', ->
      before ->
        Atrackt.registerPlugin 'invalidPlugin'

      it 'should not add the plugin to the global plugins', ->
        expect(Atrackt.plugins['invalidPlugin']).to.not.exist

  context 'with valid plugins registered', ->
    # used for various tests
    el = null

    # fooEl & barEl used for plugin related tests
    fooEl = null
    fooPlugin = null
    fooSendSpy = null
    fooBindSpy = null

    barEl = null
    barPlugin = null
    barSendSpy = null
    barBindSpy = null

    before ->
      Atrackt.plugins = {}
      $('*').off 'atrackt'

      Atrackt.registerPlugin 'fooPlugin',
        send: ->
      Atrackt.registerPlugin 'barPlugin',
        send: ->

      fooEl = $('<a class="test foo"></a>')
      barEl = $('<a class="test bar"></a>')
      fooPlugin = Atrackt.plugins['fooPlugin']
      barPlugin = Atrackt.plugins['barPlugin']
      fooSendSpy = sinon.spy fooPlugin, 'send'
      barSendSpy = sinon.spy barPlugin, 'send'
      fooBindSpy = sinon.spy fooPlugin, 'bind'
      barBindSpy = sinon.spy barPlugin, 'bind'

      $('body').append(fooEl, barEl)

    afterEach ->
      fooSendSpy.reset()
      barSendSpy.reset()
      fooBindSpy.reset()
      barBindSpy.reset()

    after ->
      Atrackt.plugins = {}
      fooSendSpy.restore()
      barSendSpy.restore()
      fooBindSpy.restore()
      barBindSpy.restore()

    describe '#bind', ->
      context 'when binding a selector', ->
        before ->
          Atrackt.bind
            click: [ 'a.test' ]

        it 'should call bind events on all plugins', ->
          expect(fooBindSpy).to.be.called.once
          expect(barBindSpy).to.be.called.once

        it 'should set event on include property', ->
          expect(fooPlugin.includeSelectors.click).to.exist
          expect(barPlugin.includeSelectors.click).to.exist

        it 'should bind events on all plugins', ->
          expect($._data(fooEl[0]).events.click).to.have.length 2
          expect($._data(barEl[0]).events.click).to.have.length 2

        context 'when called on the plugin', ->
          before ->
            fooPlugin.includeSelectors = {}
            barPlugin.includeSelectors = {}
            $('a.foo, a.bar').off '.atrackt'

            fooPlugin.bind
              click: [ 'a.foo' ]
            barPlugin.bind
              hover: [ 'a.bar' ]

          it 'should set event on include property', ->
            expect(fooPlugin.includeSelectors.click).to.exist
            expect(barPlugin.includeSelectors.hover).to.exist

          it 'should bind events', ->
            expect($._data(fooEl[0]).events.click).to.have.length 1
            expect($._data(barEl[0]).events.hover).to.have.length 1

          it 'should track only events from the foo plugin', ->
            $('a.test').trigger 'click'

            expect(fooSendSpy).to.have.been.calledOnce
            expect(barSendSpy).to.not.have.been.called

          it 'should track only events from the bar plugin', ->
            $('a.test').trigger 'hover'

            expect(fooSendSpy).to.not.be.called
            expect(barSendSpy).to.be.called.once

          context 'when binding additional elements', ->
            before ->
              fooPlugin.bind
                click: [ 'button' ]

            it 'should retain previous events', ->
              expect(fooPlugin.includeSelectors.click).to.include 'a.foo'
              expect(fooPlugin.includeSelectors.click).to.include 'button'

      context 'when binding a jquery object', ->
        el = null

        before ->
          fooPlugin.includeSelectors = {}
          barPlugin.includeSelectors = {}
          $('*').off '.atrackt'

          el = $('a.foo')

          Atrackt.bind
            click: el

        it 'should add the element to the elements object', ->
          expect(fooPlugin.includeElements.click).to.have.length 1
          expect(fooPlugin.includeElements.click).to.contain el

        it 'should bind the element', ->
          expect($._data(el[0]).events.click).to.have.length 2

      context 'when calling bind both types', ->
        before ->
          Atrackt.bind
            click: [ 'a.foo' ]

          Atrackt.bind
            click: $('<a class="test bar"></a>')

        it 'should not unbind other elements from the plugin', ->
          expect($._data(fooEl[0]).events.click).to.have.length 2

    describe '#unbind', ->
      beforeEach ->
        fooPlugin.includeSelectors = {}
        barPlugin.includeSelectors = {}
        fooPlugin.excludeSelectors = {}
        barPlugin.excludeSelectors = {}
        $('*').off '.atrackt'

        Atrackt.plugins['fooPlugin'].bind
          click: [ 'a.foo' ]
          hover: [ 'a.foo' ]
        Atrackt.plugins['barPlugin'].bind
          click: [ 'a.bar' ]
          hover: [ 'a.bar' ]

      context 'for all plugins', ->
        beforeEach ->
          Atrackt.unbind()

        it 'should clear the include property', ->
          expect(fooPlugin.includeSelectors.click).to.not.exist
          expect(fooPlugin.includeSelectors.hover).to.not.exist
          expect(barPlugin.includeSelectors.click).to.not.exist
          expect(barPlugin.includeSelectors.hover).to.not.exist

        it 'should unbind all events', ->
          expect($._data(fooEl[0]).events?.click).to.not.exist
          expect($._data(fooEl[0]).events?.hover).to.not.exist
          expect($._data(barEl[0]).events?.click).to.not.exist
          expect($._data(barEl[0]).events?.hover).to.not.exist

      context 'for all plugins with event object', ->
        beforeEach ->
          Atrackt.unbind
            click: [ 'a.test' ]

        it 'should set the exclude property', ->
          expect(fooPlugin.excludeSelectors.click).to.exist
          expect(barPlugin.excludeSelectors.click).to.exist

        it 'should unbind specific events', ->
          expect($._data(fooEl[0]).events.click).to.not.exist
          expect($._data(fooEl[0]).events.hover).to.have.length 1
          expect($._data(barEl[0]).events.click).to.not.exist
          expect($._data(barEl[0]).events.hover).to.have.length 1

      context 'on a specific plugin with no event object', ->
        beforeEach ->
          Atrackt.plugins['fooPlugin'].unbind()

        it 'should clear the include property', ->
          expect(fooPlugin.includeSelectors.click).to.not.exist
          expect(fooPlugin.includeSelectors.hover).to.not.exist
          expect(barPlugin.includeSelectors.click).to.exist
          expect(barPlugin.includeSelectors.hover).to.exist

        it 'should unbind all events', ->
          expect($._data(fooEl[0]).events?.click).to.not.exist
          expect($._data(fooEl[0]).events?.hover).to.not.exist
          expect($._data(barEl[0]).events.click).to.have.length 1
          expect($._data(barEl[0]).events.hover).to.have.length 1

      context 'on a specific plugin with event object', ->
        beforeEach ->
          Atrackt.plugins['fooPlugin'].unbind
            click: [ 'a.test' ]

        it 'should set the exclude property', ->
          expect(fooPlugin.excludeSelectors.click).to.exist
          expect(fooPlugin.excludeSelectors.hover).to.not.exist
          expect(barPlugin.excludeSelectors.click).to.not.exist
          expect(barPlugin.excludeSelectors.hover).to.not.exist

        it 'should unbind specific events', ->
          expect($._data(fooEl[0]).events.click).to.not.exist
          expect($._data(fooEl[0]).events.hover).to.have.length 1
          expect($._data(barEl[0]).events.click).to.have.length 1
          expect($._data(barEl[0]).events.hover).to.have.length 1

    describe '#setOptions', ->
      before ->
        fooPlugin.setOptions
          foo: 'bar'

      it 'should set custom options on the plugin', ->
        expect(Atrackt.plugins['fooPlugin'].options.foo).to.equal 'bar'

    describe '#callbacks', ->
      before ->
        window._callbacks = []

        Atrackt.registerPlugin 'callbacks',
          send: (data, options) ->
            window._callbacks.push
              send:
                data: data
                options: options

        Atrackt.plugins['callbacks'].setCallback 'before', (data, options ,event) ->
          window._callbacks.push
            before:
              data: data
              options: options
              event: event

        Atrackt.plugins['callbacks'].setCallback 'after', (data, options ,event) ->
          window._callbacks.push
            after:
              data: data
              options: options
              event: event

        Atrackt.track
          data: 'data'
        ,
          option: 'option'

      it 'should call before callback', ->
        expect(window._callbacks[0].before).to.exist
        expect(window._callbacks[0].before.data).to.exist
        expect(window._callbacks[0].before.options).to.exist

      it 'should call send', ->
        expect(window._callbacks[1].send).to.exist
        expect(window._callbacks[1].send.data).to.exist
        expect(window._callbacks[1].send.options).to.exist

      it 'should call after callback', ->
        expect(window._callbacks[2].after).to.exist
        expect(window._callbacks[2].after.data).to.exist
        expect(window._callbacks[2].after.options).to.exist

    describe '#globalData', ->
      before ->
        Atrackt.setGlobalData
          globalFoo: 'foo'

      it 'should track add global data to the plugins', ->
        expect(fooPlugin.globalData.globalFoo).to.equal 'foo'

      context 'when adding additional globalData', ->
        before ->
          Atrackt.setGlobalData
            globalBar: 'bar'

        it 'should retain the previous data', ->
          expect(fooPlugin.globalData.globalFoo).to.equal 'foo'
          expect(fooPlugin.globalData.globalBar).to.equal 'bar'

      context 'when adding existing globalData', ->
        before ->
          Atrackt.setGlobalData
            globalFoo: 'bar'
          Atrackt.track $('<a></a>')

        it 'should extend existing data', ->
          expect(fooPlugin.globalData.globalFoo).to.equal 'bar'
          expect(fooPlugin.globalData.globalBar).to.equal 'bar'

    describe '#track', ->
      context 'wtih globalData', ->
        before ->
          Atrackt.setGlobalData
            globalFoo: 'foo'
          Atrackt.track $('a.foo')

        it 'should include the global data', ->
          expect(fooSendSpy.args[0][0].globalFoo).to.equal 'foo'

      context 'with options', ->
        beforeEach ->
          el = $('<a></a>')
          Atrackt.track el,
            foo: 'bar'

        it 'should call send with the track object', ->
          expect(fooSendSpy).to.be.called.once
          expect(fooSendSpy.args[0][1].foo).to.equal 'bar'

        it 'should add the plugin name to the options', ->
          expect(fooSendSpy.args[0][1].plugin).to.exist

      context 'with an element', ->
        beforeEach ->
          el = $('<a></a>')
          Atrackt.track el

        it 'should create the data-track-object on the element', ->
          expect(el.data('track-object')).to.exist

        it 'should call send with the track object', ->
          expect(fooSendSpy).to.be.called.once
          expect(fooSendSpy.args[0][0]).to.be.a 'object'

        context 'with a custom function', ->
          beforeEach ->
            el = $('<a></a>')
            el.data 'track-function', (data) ->
              data.custom = true
            Atrackt.track el

          it 'should add custom attribute', ->
            expect(el.data('track-object').custom).to.be.true

      context 'with an object', ->
        beforeEach ->
          Atrackt.track
            foo: 'bar'

        it 'should call send with the object', ->
          expect(fooSendSpy).to.be.called.once
          expect(fooSendSpy.args[0][0].foo).to.equal 'bar'
          expect(fooSendSpy.args[0][0].location).to.exist

    describe '#refresh', ->
      before ->
        el = $('<a class="refresh"></a>')
        $(document.body).append(el)
        Atrackt.bind
          click: [ 'a.refresh' ]
        Atrackt.refresh()

      it 'should bind default event to default elements on the dom', ->
        expect($._data(el[0], 'events').click).to.exist

    describe '#_getLocation', ->
      before ->
        $('body').data 'track-location', 'foo'

      it 'should return a value', ->
        expect(Atrackt._getLocation()).to.equal 'foo'

    describe '#_getCategories', ->
      before ->
        html = $('<div data-track-cat="three"><div data-track-cat="two"><a data-track-cat="one"></a></div></div>')
        el = html.find('a')

      it 'should return an array of categories', ->
        expect(Atrackt._getCategories(el)).to.deep.equal [ 'three', 'two', 'one' ]

    describe '#_getValue', ->
      before ->
        el = $('<a title="foo"></a>')

      it 'should return a value', ->
        expect(Atrackt._getValue(el)).to.equal 'foo'

describe 'Debugging Console', ->
  debugConsole = null

  before ->
    Atrackt._debug = -> true
    Atrackt._debugConsole()
    debugConsole = $('#atrackt-debug')

    Atrackt.registerPlugin 'console',
      send: ->

    Atrackt.bind
      click: [ 'a.refresh' ]

  after ->
    Atrackt._debugConsoleDestroy()

  it 'should add the console', ->
    expect(debugConsole).to.exist

  it 'should add the element to the console', ->
    expect(debugConsole.find('.atrackt-plugin-event').html()).to.contain('console : click')
    expect(debugConsole.find('.atrackt-value').html()).to.contain('refresh')

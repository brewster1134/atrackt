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

    it 'should create a bindEvents function', ->
      expect(Atrackt.plugins['plugin'].bindEvents).to.be.a 'function'

    it 'should create a unbindEvents function', ->
      expect(Atrackt.plugins['plugin'].unbindEvents).to.be.a 'function'

    it 'should create a setOptions function', ->
      expect(Atrackt.plugins['plugin'].setOptions).to.be.a 'function'

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
    fooBindEventsSpy = null

    barEl = null
    barPlugin = null
    barSendSpy = null
    barBindEventsSpy = null

    before ->
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
      fooBindEventsSpy = sinon.spy fooPlugin, 'bindEvents'
      barBindEventsSpy = sinon.spy barPlugin, 'bindEvents'

      $('body').append(fooEl, barEl)

    afterEach ->
      fooSendSpy.reset()
      barSendSpy.reset()
      fooBindEventsSpy.reset()
      barBindEventsSpy.reset()

    after ->
      Atrackt.plugins = {}
      fooSendSpy.restore()
      barSendSpy.restore()
      fooBindEventsSpy.restore()
      barBindEventsSpy.restore()

    describe '#bindEvents', ->
      before ->
        Atrackt.bindEvents
          click: [ 'a.test' ]
          hover: [ 'a.test' ]

      it 'should call bind events on all plugins', ->
        expect(fooBindEventsSpy).to.be.called.once
        expect(barBindEventsSpy).to.be.called.once

      it 'should bind events on all plugins', ->
        expect($._data(fooEl[0]).events.click).to.have.length 2
        expect($._data(fooEl[0]).events.hover).to.have.length 2
        expect($._data(barEl[0]).events.click).to.have.length 2
        expect($._data(barEl[0]).events.hover).to.have.length 2

      context 'when called on the plugin', ->
        before ->
          $('*').off '.atrackt'

          fooPlugin.bindEvents
            click: [ 'a.foo' ]
          barPlugin.bindEvents
            hover: [ 'a.bar' ]

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

    describe '#unbindEvents', ->
      beforeEach ->
        $('a.test').off '.atrackt'

        Atrackt.bindEvents
          click: [ 'a.foo' ]
          hover: [ 'a.foo' ]

      it 'should unbind all events from all plugins', ->
        Atrackt.unbindEvents()

        expect($._data(fooEl[0]).events).to.not.exist

      it 'should unbind all events from a specific plugin', ->
        Atrackt.unbindEvents 'fooPlugin'

        expect($._data(fooEl[0]).events.click).to.have.length 1
        expect($._data(fooEl[0]).events.hover).to.have.length 1

      it 'should unbind specific events from all plugins', ->
        Atrackt.unbindEvents
          click: [ 'a.test' ]

        expect($._data(fooEl[0]).events?.click).to.not.exist
        expect($._data(fooEl[0]).events.hover).to.have.length 2

      it 'should unbind specific events from a specific plugin', ->
        Atrackt.unbindEvents 'fooPlugin'
          click: [ 'a.test' ]

        expect($._data(fooEl[0]).events.click).to.have.length 1
        expect($._data(fooEl[0]).events.hover).to.have.length 2

    describe '#setOptions', ->
      before ->
        fooPlugin.setOptions
          foo: 'bar'

      it 'should set custom options on the plugin', ->
        expect(Atrackt.plugins['fooPlugin'].options.foo).to.equal 'bar'


    describe '#track', ->
      context 'with an element', ->
        beforeEach ->
          el = $('<a></a>')
          Atrackt.track el

        it 'should create the data-track-object on the element', ->
          expect(el.data('track-object')).to.exist

        it 'should call send with the track object', ->
          expect(fooSendSpy).to.be.called.once
          expect(fooSendSpy.args[0][0]).to.be.a 'object'

        it 'should set the plugin attr to the plugin name', ->
          expect(fooSendSpy.args[0][0].plugin).to.equal 'fooPlugin'

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
        Atrackt.bindEvents
          click: [ 'a.refresh' ]
        Atrackt.refresh()

      after ->
        Atrackt.unbindEvents
          click: [ 'a.refresh' ]

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

    describe '#_initEl', ->
      before ->
        el = $('<a></a>')
        Atrackt._initEl el, 'testPlugin', 'foo'

      it 'should bind default event to element', ->
        expect($._data(el[0], 'events').foo).to.exist

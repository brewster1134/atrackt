describe 'Atrackt', ->
  el = null

  it 'should set the Atrackt object on window', ->
    expect(window.Atrackt).to.exist

  describe '#registerPlugin', ->
    fooEl = null
    fooPlugin = null
    fooSpy = null

    barEl = null
    barPlugin = null
    barSpy = null

    before ->
      fooEl = $('<a class="foo"></a>')
      barEl = $('<a class="bar"></a>')
      $('body').append(fooEl, barEl)

      Atrackt.plugins = {}
      Atrackt.registerPlugin 'fooPlugin',
        send: ->
      Atrackt.registerPlugin 'barPlugin',
        send: ->

      fooPlugin = Atrackt.plugins['fooPlugin']
      barPlugin = Atrackt.plugins['barPlugin']
      fooSpy = sinon.spy fooPlugin, 'send'
      barSpy = sinon.spy barPlugin, 'send'

    afterEach ->
      fooSpy.reset()
      barSpy.reset()

    after ->
      fooSpy.restore()
      barSpy.restore()

    it 'should add an object to plugins', ->
      expect(Atrackt.plugins['fooPlugin'].send).to.be.a 'function'
      expect(Atrackt.plugins['barPlugin'].send).to.be.a 'function'

    describe '#bindEvents', ->
      before ->
        fooPlugin.bindEvents
          click: [ 'a.foo' ]
        barPlugin.bindEvents
          hover: [ 'a.bar' ]

      it 'should bind events', ->
        expect(Object.keys($._data(fooEl[0]).events)).to.have.length 1
        expect($._data(fooEl[0]).events.click).to.exist

        expect(Object.keys($._data(barEl[0]).events)).to.have.length 1
        expect($._data(barEl[0]).events.hover).to.exist

      it 'should track only events from the foo plugin', ->
        $('a').trigger 'click'

        expect(fooSpy).to.be.called.once
        expect(barSpy).to.not.be.called

      it 'should track only events from the bar plugin', ->
        $('a').trigger 'hover'

        expect(fooSpy).to.not.be.called
        expect(barSpy).to.be.called.once

    describe '#setOptions', ->
      before ->
        fooPlugin.setOptions
          foo: 'bar'

      it 'should set custom options on the plugin', ->
        expect(Atrackt.plugins['fooPlugin'].options.foo).to.equal 'bar'

  context 'after plugin registered', ->
    sendSpy = null

    before ->
      Atrackt.plugins = {}
      plugin = Atrackt.registerPlugin 'testPlugin',
        send: ->

      plugin.bindEvents
        click: [ 'a' ]

      sendSpy = sinon.spy Atrackt.plugins['testPlugin'], 'send'

    afterEach ->
      sendSpy.reset()

    after ->
      sendSpy.restore()
      $('a').off 'click'

    describe '#track', ->
      context 'with an element', ->
        beforeEach ->
          el = $('<a></a>')
          Atrackt.track el

        it 'should create the data-track-object on the element', ->
          expect(el.data('track-object')).to.exist

        it 'should call send with the track object', ->
          expect(sendSpy).to.be.called.once
          expect(sendSpy.args[0][0]).to.be.a 'object'

        it 'should set the plugin attr to the plugin name', ->
          expect(el.data('track-object').plugin).to.equal 'testPlugin'

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
          expect(sendSpy).to.be.called.once
          expect(sendSpy.args[0][0].foo).to.equal 'bar'
          expect(sendSpy.args[0][0].location).to.exist

    describe '#refresh', ->
      before ->
        el = $('<a></a>')
        $(document.body).append(el)
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

    describe '#_initEl', ->
      before ->
        el = $('<a></a>')
        Atrackt._initEl el, 'testPlugin', 'foo'

      it 'should bind default event to element', ->
        expect($._data(el[0], 'events').foo).to.exist

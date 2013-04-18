describe 'Atrackt', ->
  el = null

  before ->
    $(document).trigger('ready')

  context 'before plugin registered', ->
    it 'should set the Atrackt object on window', ->
      expect(window.Atrackt).to.exist

    describe '#registerPlugin', ->
      before ->
        el = $('<a></a>')
        $('body').append(el)
        Atrackt.plugins = {}
        Atrackt.registerPlugin 'fooPlugin',
          events:
            click: [ 'a' ]
          send: ->

      after ->
        $('a').off 'click'

      it 'should add an object to plugins', ->
        expect(Atrackt.plugins['fooPlugin'].send).to.be.a 'function'

      it 'should bind default events', ->
        expect($._data(el[0], 'events').click).to.exist

  context 'after plugin registered', ->
    sendSpy = null

    before ->
      Atrackt.plugins = {}
      Atrackt.registerPlugin 'barPlugin',
        events:
          click: [ 'a' ]
        send: ->

      sendSpy = sinon.spy Atrackt.plugins['barPlugin'], 'send'

    afterEach ->
      sendSpy.reset()

    after ->
      sendSpy.restore()
      $('a').off 'click'

    describe '#track', ->
      context 'with an element', ->
        beforeEach ->
          el = $('<div></div>')
          Atrackt.track el

        it 'should create the data-track-object on the element', ->
          expect(el.data('track-object')).to.exist

        it 'should call send with the track object', ->
          expect(sendSpy).to.be.called.once
          expect(sendSpy.args[0][0]).to.be.a 'object'

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

    describe '#_getEvent', ->
      before ->
        el = $('<a data-track-event="fooEvent"></a>')

      it 'should return a value', ->
        expect(Atrackt._getEvent(el)).to.equal 'fooEvent'

    describe '#_initEl', ->
      before ->
        el = $('<a></a>')
        el.data 'track-event', 'foo'
        Atrackt._initEl el

      it 'should bind default event to element', ->
        expect($._data(el[0], 'events').foo).to.exist

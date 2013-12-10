describe 'Plugin: Localytics', ->
  plugin = null
  isUiWebViewStub = null

  before ->
    Atrackt.plugins = {}
    loadJs 'lib/plugins/atrackt.localytics'
    plugin = Atrackt.plugins['localytics']
    isUiWebViewStub = sinon.stub plugin, '_isUiWebView'

  after ->
    plugin._isUiWebView.restore()
    for event, selectorArray of plugin.events
      $(selectorArray.join(',')).off event

  context 'in a UIWebView/HTML5 hybrid', ->
    before ->
      isUiWebViewStub.returns true

    describe '#send', ->
      getRedirectUrlStub = null
      redirectStub = null

      before ->
        redirectStub = sinon.stub plugin, '_redirect'
        getRedirectUrlStub = sinon.stub plugin, '_getRedirectUrl'
        getRedirectUrlStub.returns 'foo://url'

        plugin.send
          data: 'foo'
        ,
          eventName: 'bar'

      after ->
        plugin._redirect.restore()
        plugin._getRedirectUrl.restore()

      it 'should call getRedirectUrl', ->
        expect(getRedirectUrlStub).to.be.called.once
        expect(getRedirectUrlStub).to.be.calledWithExactly
          data: 'foo'
        ,
          eventName: 'bar'

      it 'should call redirect', ->
        expect(redirectStub).to.be.called.once

    describe '#_getRedirectUrl', ->
      redirectUrl = null

      before ->
        redirectUrl = plugin._getRedirectUrl
          foo: 'bar'
        ,
          eventName: 'foo'

      it 'should create the custom url', ->
        expect(redirectUrl).to.equal 'localytics://?event=foo&attributes={"foo":"bar"}'

      context 'when no object is tracked', ->
        before ->
          redirectUrl = plugin._getRedirectUrl {},
            eventName: 'foo'

        it 'should not have attributes', ->
          expect(redirectUrl).to.equal 'localytics://?event=foo'

  context 'in HTML5', ->
    callTagMethodStub = null
    redirectStub = null

    before ->
      isUiWebViewStub.returns false
      callTagMethodStub = sinon.stub plugin, '_callTagMethod'
      redirectStub = sinon.stub plugin, '_redirect'

      plugin.send
        data: 'foo'
      ,
        eventName: 'bar'

    after ->
      plugin._callTagMethod.restore()
      plugin._redirect.restore()

    describe '#send', ->
      it 'should call callTagMethod', ->
        expect(callTagMethodStub).to.be.called.once
        expect(callTagMethodStub).to.be.calledWithExactly
          data: 'foo'
        ,
          eventName: 'bar'

      it 'should NOT call redirect', ->
        expect(redirectStub).to.not.be.called

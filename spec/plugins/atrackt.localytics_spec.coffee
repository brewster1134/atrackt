describe 'Plugin: Localytics', ->
  _plugin = Atrackt.plugins['localytics']

  context 'in a UIWebView/HTML5 hybrid', ->
    getRedirectUrlStub = null
    redirectStub = null

    before ->
      sinon.stub(_plugin, '_isUiWebView').returns true
      getRedirectUrlStub = sinon.stub _plugin, '_getRedirectUrl'
      redirectStub = sinon.stub _plugin, '_redirect'

    after ->
      _plugin._isUiWebView.restore()
      _plugin._getRedirectUrl.restore()
      _plugin._redirect.restore()

    describe '#send', ->
      before ->
        _plugin._send
          data: 'foo'
        ,
          eventName: 'bar'

      it 'should call getRedirectUrl', ->
        expect(getRedirectUrlStub).to.have.been.called.once
        expect(getRedirectUrlStub).to.have.been.calledWithExactly
          data: 'foo'
        ,
          eventName: 'bar'

      it 'should call redirect', ->
        expect(redirectStub).to.be.called.once

  context 'in HTML5', ->
    callTagMethodStub = null
    redirectStub = null

    before ->
      sinon.stub(_plugin, '_isUiWebView').returns false
      callTagMethodStub = sinon.stub _plugin, '_callTagMethod'
      redirectStub = sinon.stub _plugin, '_redirect'

    after ->
      _plugin._isUiWebView.restore()
      _plugin._callTagMethod.restore()
      _plugin._redirect.restore()

    describe '#send', ->
      before ->
        _plugin._send
          data: 'foo'
        ,
          eventName: 'bar'

      it 'should call callTagMethod', ->
        expect(callTagMethodStub).to.be.called.once
        expect(callTagMethodStub).to.be.calledWithExactly
          data: 'foo'
        ,
          eventName: 'bar'

      it 'should NOT call redirect', ->
        expect(redirectStub).to.not.be.called

  describe '#_getRedirectUrl', ->
    redirectUrl = null

    before ->
      redirectUrl = _plugin._getRedirectUrl
        foo: 'bar'
      ,
        eventName: 'foo'

    it 'should create the custom url', ->
      expect(redirectUrl).to.equal 'localytics://?event=foo&attributes={"foo":"bar"}'

    context 'when no object is tracked', ->
      before ->
        redirectUrl = _plugin._getRedirectUrl {},
          eventName: 'foo'

      it 'should not have attributes', ->
        expect(redirectUrl).to.equal 'localytics://?event=foo'

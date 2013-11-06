describe 'Plugin: Localytics', ->
  plugin = null

  before ->
    window.localyticsSession = {}

    Atrackt.plugins = {}
    loadJs 'lib/plugins/atrackt.localytics'
    plugin = Atrackt.plugins['localytics']

  after ->
    delete window.localyticsSession

    for event, selectorArray of plugin.events
      $(selectorArray.join(',')).off event

  describe '#send', ->
    tagEventSpy = null

    before ->
      tagEventSpy = sinon.spy()
      window.localyticsSession.tagEvent = tagEventSpy

      plugin.send
        data: 'foo'
      ,
        localytics:
          eventName: 'bar'

    it 'should call the tagEvent method', ->
      expect(tagEventSpy).to.be.calledOnce

    it 'should call the tagEvent method with the correct arguments', ->
      expect(tagEventSpy).to.be.calledWithExactly 'bar',
        data: 'foo'

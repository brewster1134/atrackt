describe 'Plugin: omniture', ->
  plugin = null

  before ->
    Atrackt.plugins = {}
    loadJs 'lib/plugins/atrackt.omniture'
    plugin = Atrackt.plugins['omniture']

  after ->
    for event, selectorArray of plugin.events
      $(selectorArray.join(',')).off event

  describe '#buildSObject', ->
    before ->
      window.s = {}
      plugin.options.version = 14
      plugin.options.linkTrackVars = ['foo']
      plugin.buildSObject
        bar: 'bar'

    it 'should add to the s object', ->
      expect(s.foo).to_exist

    it 'shoule set linkTrackVars', ->
      expect(s.linkTrackVars).to.equal 'foo,bar'

  describe '#send', ->
    obj = null

    before ->
      plugin.options.propMap =
        foo: 'prop1'

      obj = plugin.send
        foo: 'foo'
        bar: 'bar'
      , {}

    it 'should not have the original key if it exists in the propMap', ->
      expect(obj.foo).to.not.exist
      expect(obj.prop1).to.exist

    it 'should keep the original key if it does not exist in the propMap', ->
      expect(obj.bar).to.exist

  describe '#keyLookup', ->
    before ->
      plugin.options.propMap =
        foo: 'bar'

    it 'should lookup from propMap', ->
      expect(plugin.keyLookup('foo')).to.equal 'bar'

  describe '#buildLinkName', ->
    linkName = null

    before ->
      plugin.options.delimiters =
        linkName: '|'
      plugin.options.propMap =
        value: 'prop1'
        location: 'prop2'
        categories: 'prop3'

      linkName = plugin.buildLinkName
        prop1: 'baz'
        prop2: 'foo'
        prop3: 'bar'

    it 'should build a link name', ->
      expect(linkName).to.equal 'foo|bar|baz'

  describe '#translatePropMap', ->
    pre = null
    post = null

    before ->
      pre =
        integer: 10
      post = plugin.translatePropMap pre

    it 'should handle any value type', ->
      expect(post['integer']).to.equal '10'

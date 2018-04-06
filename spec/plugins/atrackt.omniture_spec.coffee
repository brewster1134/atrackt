describe 'Plugin: Omniture', ->
  _plugin = Atrackt.plugins['omniture']

  before ->
    window.s = {}

  describe '#send', ->
    obj = null

    before ->
      _plugin.options.propMap =
        foo: 'prop1'

      obj = _plugin._send
        foo: 'foo'
        bar: 'bar'
      , {}

    it 'should not have the original key if it exists in the propMap', ->
      expect(obj.foo).to.not.exist
      expect(obj.prop1).to.exist

    it 'should keep the original key if it does not exist in the propMap', ->
      expect(obj.bar).to.exist

  describe '#_buildSObject', ->
    before ->
      window.s = {}
      _plugin.options.version = 14
      _plugin.options.linkTrackVars = ['foo']
      _plugin._buildSObject
        bar: 'bar'

    it 'should add to the s object', ->
      expect(s.bar).to.exist

    it 'shoule set linkTrackVars', ->
      expect(s.linkTrackVars).to.equal 'foo,bar'

  describe '#_buildLinkName', ->
    linkName = null

    before ->
      _plugin.options.delimiters =
        linkName: '|'
      _plugin.options.propMap =
        _value: 'prop1'
        _location: 'prop2'
        _categories: 'prop3'

      linkName = _plugin._buildLinkName
        prop1: 'baz'
        prop2: 'foo'
        prop3: 'bar'

    it 'should build a link name', ->
      expect(linkName).to.equal 'foo|bar|baz'

  describe '#_translatePropMap', ->
    pre = null
    post = null

    before ->
      pre =
        integer: 10
      post = _plugin._translatePropMap pre

    it 'should handle any value type', ->
      expect(post['integer']).to.equal '10'

  describe '#_keyLookup', ->
    before ->
      _plugin.options.propMap =
        foo: 'bar'

    it 'should lookup from propMap', ->
      expect(_plugin._keyLookup('foo')).to.equal 'bar'

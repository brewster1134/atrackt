describe 'Plugin: Omniture', ->
  _plugin = Atrackt.plugins['omniture']

  describe '#buildSObject', ->
    before ->
      window.s = {}
      _plugin.options.version = 14
      _plugin.options.linkTrackVars = ['foo']
      _plugin.buildSObject
        bar: 'bar'

    it 'should add to the s object', ->
      expect(s.foo).to_exist

    it 'shoule set linkTrackVars', ->
      expect(s.linkTrackVars).to.equal 'foo,bar'

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

  describe '#keyLookup', ->
    before ->
      _plugin.options.propMap =
        foo: 'bar'

    it 'should lookup from propMap', ->
      expect(_plugin.keyLookup('foo')).to.equal 'bar'

  describe '#buildLinkName', ->
    linkName = null

    before ->
      _plugin.options.delimiters =
        linkName: '|'
      _plugin.options.propMap =
        _value: 'prop1'
        _location: 'prop2'
        _categories: 'prop3'

      linkName = _plugin.buildLinkName
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
      post = _plugin.translatePropMap pre

    it 'should handle any value type', ->
      expect(post['integer']).to.equal '10'

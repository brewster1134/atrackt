# Setup plugin
#
Atrackt.setPlugin 'Foo Plugin',
  send: ->
_plugin = Atrackt.plugins['foo-plugin']

describe 'Atrackt', ->
  it 'should set the Atrackt object on window', ->
    expect(window.Atrackt).to.exist

  #
  # PUBLIC METHODS
  #
  describe '#setPlugin', ->
    it 'should add the plugin object to global plugins', ->
      expect(_plugin).to.exist

    plugin_methods = [
      'setEvent'
      'setOptions'
      'setData'
    ]

    for method in plugin_methods
      it "should create a #{method} function on the plugin", ->
        expect(_plugin[method]).to.be.a 'function'

    context 'when registering an invalid plugin', ->
      it 'should throw an exception', ->
        noName = ->
          Atrackt.setPlugin()
        noSend = ->
          Atrackt.setPlugin 'invalid'

        expect(noName).to.throw
        expect(noSend).to.throw

  describe '#setEvent', ->
    it 'should not overwrite global events with plugin events', ->
      $fooEl = $('<div class="bind-global-plugin"></div>')

      Atrackt.setEvent
        click: $fooEl

      _plugin.setEvent
        click: $fooEl

      expect($._data($fooEl[0]).events.click).to.have.length 1
      expect($._data($fooEl[0]).events.click[0].namespace).to.equal 'atrackt'

      expect(Atrackt._elements.click.indexOf($fooEl[0])).to.not.equal -1
      expect((_plugin._elements.click || []).indexOf($fooEl[0])).to.equal -1

    it 'should overwrite plugin events with global events', ->
      $fooEl = $('<div class="bind-plugin-global"></div>')

      _plugin.setEvent
        click: $fooEl

      Atrackt.setEvent
        click: $fooEl

      expect($._data($fooEl[0]).events.click).to.have.length 1
      expect($._data($fooEl[0]).events.click[0].namespace).to.equal 'atrackt'

      expect(Atrackt._elements.click.indexOf($fooEl[0])).to.not.equal -1
      expect(_plugin._elements.click.indexOf($fooEl[0])).to.equal -1

    it 'should bind on a plugin namespace', ->
      $fooEl = $('<div class="bind-plugin"></div>')

      _plugin.setEvent
        click: $fooEl

      expect($._data($fooEl[0]).events.click[0].namespace).to.equal 'atrackt.foo-plugin'

    it 'should bind selectors', ->
      $fooEl = $('<div class="bind-selector"></div>')
      $('body').append $fooEl

      Atrackt.setEvent
        click: '.bind-selector'

      expect($._data($fooEl[0]).events.click[0].namespace).to.equal 'atrackt'

    it 'should bind html nodes', ->
      $fooEl = $('<div class="bind-html"></div>')

      Atrackt.setEvent
        click: $fooEl[0]

      expect($._data($fooEl[0]).events.click[0].namespace).to.equal 'atrackt'

    it 'should bind jquery objects', ->
      $fooEl = $('<div class="bind-jquery"></div>')

      Atrackt.setEvent
        click: $fooEl

      expect($._data($fooEl[0]).events.click[0].namespace).to.equal 'atrackt'

    it 'should bind an array of all types of objects', ->
      $selectorOneEl = $('<div class="array-selector-one"></div>')
      $selectorTwoEl = $('<div class="array-selector-two"></div>')
      $jqueryEl = $('<div class="array-jquery"></div>')
      $htmlNodeEl = $('<div class="array-html-node"></div>')
      $('body').append $selectorOneEl, $selectorTwoEl, $jqueryEl, $htmlNodeEl

      Atrackt.setEvent
        click: [ '.array-selector-one, .array-selector-two', $('.array-jquery'), $('.array-html-node')[0]]

      expect($._data($selectorOneEl[0]).events.click[0].namespace).to.equal 'atrackt'
      expect($._data($selectorTwoEl[0]).events.click[0].namespace).to.equal 'atrackt'
      expect($._data($jqueryEl[0]).events.click[0].namespace).to.equal 'atrackt'
      expect($._data($htmlNodeEl[0]).events.click[0].namespace).to.equal 'atrackt'

  describe '#setOptions', ->
    before ->
      Atrackt.setOptions
        global_option: true

      _plugin.setOptions
        plugin_option: true

    it 'should set options', ->
      expect(Atrackt._options.global_option).to.be.true
      expect(_plugin._options.plugin_option).to.be.true

  describe '#setData', ->
    before ->
      Atrackt.setData
        global_data: true

      _plugin.setData
        plugin_data: true

    it 'should set data', ->
      expect(Atrackt._data.global_data).to.be.true
      expect(_plugin._data.plugin_data).to.be.true

  describe '#setCallback', ->
    before ->
      Atrackt.setCallback 'before', ->
      Atrackt.setCallback 'before', ->

      _plugin.setCallback 'after', ->

    it 'should add global callbacks', ->
      expect(Atrackt._callbacks.before[0]).to.be.a 'function'
      expect(Atrackt._callbacks.before[1]).to.be.a 'function'

    it 'should add plugin callbacks', ->
      expect(_plugin._callbacks.after[0]).to.be.a 'function'

  describe '#track', ->
    $fooEl = null
    beforeCallbackSpy = sinon.spy()
    afterCallbackSpy = sinon.spy()
    pluginSpy = sinon.spy _plugin, 'send'

    before ->
      Atrackt._options = {
        global_option: true
      }

      _plugin._options = {
        plugin_option: true
      }

      Atrackt._data = {
        global_data: true
      }

      _plugin._data = {
        plugin_data: true
      }

      Atrackt._callbacks =
        before: [ beforeCallbackSpy ]

      _plugin._callbacks =
        after: [ afterCallbackSpy ]

    after ->
      beforeCallbackSpy.reset()
      afterCallbackSpy.reset()
      pluginSpy.reset()

    context 'when tracking an object', ->
      before ->
        Atrackt.plugins['foo-plugin'].track
          track_data: true
        ,
          track_option: true
          _data:
            option_data: true

      it 'should call the send method on plugins with data and options', ->
        expect(pluginSpy).to.be.calledWithExactly
          _location: 'Atrackt Test'
          global_data: true
          plugin_data: true
          track_data: true
          option_data: true
        ,
          global_option: true
          plugin_option: true
          track_option: true

    context 'when tracking an element', ->
      before ->
        $fooEl = $('<a data-atrackt-category="Anchor" data-atrackt-value="Foo"></a>')
        $fooEl.data 'atrackt-function', (data, options) ->
          data['function_data'] = true
          options['function_option'] = true

        Atrackt.plugins['foo-plugin'].track $fooEl,
          track_option: true
          _data:
            option_data: true

      it 'should call the send method on plugins with data and options', ->
        expect(pluginSpy).to.be.calledWithExactly
          _location: 'Atrackt Test'
          _categories: ['Anchor']
          _value: 'Foo'
          global_data: true
          plugin_data: true
          option_data: true
          function_data: true
        ,
          global_option: true
          plugin_option: true
          track_option: true
          function_option: true

    context 'when tracking by event', ->
      before ->
        $fooEl = $('<a data-atrackt-category="Anchor" data-atrackt-value="Foo"></a>')
        $fooEl.data 'atrackt-function', (data, options) ->
          data['function_data'] = true
          options['function_option'] = true

        $('body').append $fooEl

        Atrackt.plugins['foo-plugin'].setEvent
          click: $fooEl

        $fooEl.trigger 'click'

      it 'should call the send method on plugins with data and options', ->
        expect(pluginSpy).to.be.calledWithExactly
          _location: 'Atrackt Test'
          _categories: ['Anchor']
          _value: 'Foo'
          _event: 'click'
          global_data: true
          plugin_data: true
          function_data: true
        ,
          global_option: true
          plugin_option: true
          function_option: true

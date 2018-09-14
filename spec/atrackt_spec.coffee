# Setup plugin
#
# prevent console from logging during tests
window.console.log = ->

# create plugin to test with
Atrackt.setPlugin 'Foo Plugin',
  send: ->
_plugin = Atrackt.plugins['foo-plugin']

describe 'Atrackt', ->
  before ->
    
    # make sure the foo plugin is the only registered plugin
    Atrackt.plugins =
      'foo-plugin': _plugin

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
    clock = null
    $fooEl = null
    beforeCallbackSpy = sinon.spy()
    afterCallbackSpy = sinon.spy()
    pluginSpy = sinon.spy _plugin, 'send'

    before ->
      clock = sinon.useFakeTimers()

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
      clock.restore()
      beforeCallbackSpy.resetHistory()
      afterCallbackSpy.resetHistory()
      pluginSpy.resetHistory()

    context 'when tracking an object', ->
      before ->
        Atrackt.plugins['foo-plugin'].track
          track_data: true
        ,
          track_option: true
          _data:
            option_data: true

        clock.tick 0

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
        @$fooEl = $('<a data-atrackt-category="Anchor" data-atrackt-value="Foo"></a>')

        Atrackt.plugins['foo-plugin'].track @$fooEl,
          track_option: true
          _data:
            option_data: true

        clock.tick 0

      it 'should call the send method on plugins with data and options', ->
        expect(pluginSpy).to.be.calledWithExactly
          _el: @$fooEl[0]
          _location: 'Atrackt Test'
          _categories: ['Anchor']
          _value: 'Foo'
          global_data: true
          plugin_data: true
          option_data: true
        ,
          global_option: true
          plugin_option: true
          track_option: true

    context 'when tracking by event', ->
      before ->
        @$fooEl = $('<a data-atrackt-category="Anchor" data-atrackt-value="Foo"></a>')
        $('body').append @$fooEl

        Atrackt.plugins['foo-plugin'].setEvent
          click: @$fooEl

        @$fooEl.trigger 'click'

        clock.tick 0

      it 'should call the send method on plugins with data and options', ->
        expect(pluginSpy).to.be.calledWithExactly
          _el: @$fooEl[0]
          _location: 'Atrackt Test'
          _categories: ['Anchor']
          _value: 'Foo'
          _event: 'click'
          global_data: true
          plugin_data: true
        ,
          global_option: true
          plugin_option: true

    context 'when tracking an element with a custom function', ->
      before ->
        @$fooEl = $('<a data-atrackt-value="Foo"></a>')
        @$fooEl.data 'atrackt-function', (data, options) ->
          data['function_data'] = true
          options['function_option'] = true

        Atrackt.plugins['foo-plugin'].setEvent
          click: @$fooEl

        @$fooEl.trigger 'click'

        clock.tick 0

      it 'should call the send method on plugins with data and options', ->
        expect(pluginSpy).to.be.calledWithExactly
          _el: @$fooEl[0]
          _location: 'Atrackt Test'
          _categories: []
          _value: 'Foo'
          _event: 'click'
          global_data: true
          plugin_data: true
          function_data: true
        ,
          global_option: true
          plugin_option: true
          function_option: true

    context 'when passing options globally', ->
      before ->
        @$fooEl = $('<a data-atrackt-value="Foo"></a>')

        Atrackt.track @$fooEl,
          global_option: 'global'
          global_only: true
          'foo-plugin':
            plugin_option: 'track-global-plugin-option'
            global_option: 'track-global-plugin-overwrite-option'

        clock.tick 0

      it 'should call send with proper data & options', ->
        expect(pluginSpy).to.be.calledWithExactly
          _el: @$fooEl[0]
          _location: 'Atrackt Test'
          _categories: []
          _value: 'Foo'
          global_data: true
          plugin_data: true
        ,
          global_only: true
          global_option: 'track-global-plugin-overwrite-option'
          plugin_option: 'track-global-plugin-option'

    context 'when passing options on a plugin', ->
      before ->
        @$fooEl = $('<a data-atrackt-value="Foo"></a>')

        Atrackt.plugins['foo-plugin'].track @$fooEl,
          plugin_option: 'track|plugin-option'

        clock.tick 0

      it 'should call send with proper data & options', ->
        expect(pluginSpy).to.be.calledWithExactly
          _el: @$fooEl[0]
          _location: 'Atrackt Test'
          _categories: []
          _value: 'Foo'
          global_data: true
          plugin_data: true
        ,
          global_option: true
          plugin_option: 'track|plugin-option'

    context 'when using a delay', ->
      before ->
        pluginSpy.resetHistory()
        Atrackt.plugins['foo-plugin'].track
          track_data: true
        ,
          delay: 100

      it 'should call the send method on plugins with data and options', ->
        expect(pluginSpy).to.not.be.called
        clock.tick 101
        expect(pluginSpy).to.be.called

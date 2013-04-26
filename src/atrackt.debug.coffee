###
Atrackt Debugging Console
@author Ryan Brewster
@version 0.0.2
###

$.extend window.Atrackt,
  # check if debugging is enabled
  _debug: ->
    @_urlParams('debugTracking') == 'true'

  _debugConsoleReset: ->
    if @_debug()
      # clear existing console if it exists
      $('#atrackt-elements tbody').empty()

  # Add the debugging console template to the dom
  _debugConsole: ->
    return false unless Atrackt._debug()

    $ =>
      $('body').addClass('atrackt-debug')

      # Add CSS
      $('<style>
        body.atrackt-debug {
          margin-top: 300px; }
        #atrackt-debug {
          height: 300px;
          background-color: white;
          width: 100%;
          overflow-x: hidden;
          overflow-y: scroll;
          position: fixed;
          top: 0;
          left: 0;
          z-index: 1;
          border-bottom: 2px solid black; }
        #atrackt-location {
          border-bottom: 1px solid black;
          padding: 5px; }
        #atrackt-elements {
          width: 100%; }
        body.atrackt-debug .highlight {
          background-color: green !important;
          color: white !important; }
        body.atrackt-debug .atrackt-element.error{
          background-color: red !important;
          color: white !important; }
        </style>'
      ).appendTo('head')

      # Add HTML
      $('<div id="atrackt-debug">
          <div id="atrackt-debug-content">
            <div id="atrackt-location">Location: ' + @_getLocation() + '</div>
            <table class="table" id="atrackt-elements">
              <thead><tr>
                <th>Plugin : Event</th>
                <th>Categories</th>
                <th>Value</th>
                <th>Error</th>
              </tr></thead>
              <tbody></tbody>
            </table>
          </div>
        </div>'
      ).prependTo('body')

  _debugPluginEvent: (plugin, event) ->
    '<div>' + plugin + ' : ' + event + '</div>'

  # Add each tracked element to the console
  _debugEl: ($el, plugin, event) ->
    return false unless @_debug()

    # set track-object since we want to show the data before it gets tracked.
    @_getTrackObject $el

    elId = @_debugElementId $el

    # set debug id on element
    $el.attr 'data-atrackt-debug-id', elId

    # create or append the matching console element
    matchingConsoleEls = $('body .atrackt-element[data-atrackt-debug-id=' + elId + ']')
    if matchingConsoleEls.length == 0
      $('<tr class="atrackt-element" data-atrackt-debug-id="' + elId + '">
        <td class="atrackt-plugin-event">' + @_debugPluginEvent(plugin, event) + '</td>
        <td class="atrackt-categories">' + $el.data('track-object').categories + '</td>
        <td class="atrackt-value">' + $el.data('track-object').value + '</td>
        <td class="atrackt-error"></td>
        </tr>'
      ).appendTo('#atrackt-elements tbody')
    else
      matchingConsoleEls.find('.atrackt-plugin-event').append(@_debugPluginEvent plugin, event)

    mathingEls = $('body [data-atrackt-debug-id=' + elId + ']')
    matchingConsoleEls = mathingEls.filter('.atrackt-element')
    matchingBodyEls = mathingEls.not('.atrackt-element')

    # errors:
    # if element with the same tracking information exists...
    if matchingBodyEls.length > 1
      console.log 'DUPLICATE ELEMENTS FOUND', matchingBodyEls
      matchingConsoleEls.addClass 'error'
      matchingConsoleEls.find('.atrackt-error').append('DUPLICATE')

    # events
    # events for elements in the console log
    matchingConsoleEls.add($el).off 'mouseenter mouseleave'

    matchingConsoleEls.hover ->
      $(@).add($el).addClass 'highlight'

      $('html, body').scrollTop($el.offset().top - $('#atrackt-debug').height() - 20)
    , ->
      $(@).add($el).removeClass 'highlight'

    # events for elements on the page
    $el.hover ->
      $(@).add(matchingConsoleEls).addClass 'highlight'

      # crazy stuff for scrolling in the overflow hidden element.
      # this is probably not as accurate as it could be, but it works.  goodnight.
      totalHeight = $('#atrackt-elements tbody').height()
      totalEls = $('#atrackt-elements .atrackt-element').length
      elIndex = $('#atrackt-elements .atrackt-element').index matchingConsoleEls
      scrollTo = ((elIndex / totalEls) * totalHeight)
      $('#atrackt-debug').scrollTop(scrollTo)
    , ->
      $(@).add(matchingConsoleEls).removeClass 'highlight'

  # Build a unique ID for each element
  _debugElementId: ($el) ->
    return false unless $el.data('track-object')
    _categories = $el.data('track-object').categories
    _ctaValue = $el.data('track-object').value

    idArray = []
    idArray.push _categories if _categories
    idArray.push _ctaValue if _ctaValue

    idArray.join().toLowerCase().replace(/[^\w]/g, '')

Atrackt._debugConsole()

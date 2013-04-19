###
Atrackt Debugging Console
@author Ryan Brewster
@version 0.0.1
###

$.extend window.Atrackt,
  _debug: ->
    @_urlParams('debugTracking') == 'true'

  # Add the debugging console template to the dom
  _debugConsole: ->
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
          border-bottom: 2px solid black; }
        #atrackt-location {
          border-bottom: 1px solid black;
          padding: 5px; }
        #atrackt-elements {
          width: 100%; }
        .atrackt-element.error{
          background-color: red;
          color: white; }
        body.atrackt-debug .highlight {
          background-color: green !important;
          color: white !important; }
        </style>'
      ).appendTo('head')

      # Add HTML
      $('<div id="atrackt-debug">
          <div id="atrackt-debug-content">
            <div id="atrackt-location">Location: ' + @_getLocation() + '</div>
            <table class="table" id="atrackt-elements">
              <thead><tr>
                <th>Categories</th>
                <th>Value</th>
                <th>Event</th>
                <th>Error</th>
              </tr></thead>
              <tbody></tbody>
            </table>
          </div>
        </div>'
      ).prependTo('body')

  # Add each tracked element to the console
  _debugEl: ($el) ->
    # set track-object since we want to show the data before it gets tracked.
    @_getTrackObject $el

    _elId = @_debugElementId $el
    $el.attr 'data-atrackt-debug-id', _elId

    $('<tr class="atrackt-element" data-atrackt-debug-id="' + _elId + '">
      <td class="atrackt-categories">' + $el.data('track-object').categories + '</td>
      <td class="atrackt-value">' + $el.data('track-object').value + '</td>
      <td class="atrackt-event">' + $el.data('track-object').event + '</td>
      <td class="atrackt-error"></td>
      </tr>'
    ).appendTo('#atrackt-elements tbody')

    # errors:
    # if element with the same tracking information exists...
    mathingEls = $('body [data-atrackt-debug-id=' + _elId + ']')
    matchingConsoleEls = mathingEls.filter('.atrackt-element')
    matchingBodyEls = mathingEls.not('.atrackt-element')

    if matchingBodyEls.length > 1
      console.log 'THERE ARE DUPLICATE ELEMENTS!', matchingBodyEls
      matchingConsoleEls.addClass 'error'
      matchingConsoleEls.find('.atrackt-error').append('DUPLICATE')

    # events
    # events for elements in the console log
    matchingConsoleEls.hover ->
      $(@).add($el).addClass 'highlight'

      $('body').scrollTop($el.offset().top - $('#atrackt-debug').height() - 20)
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
    _categories = $el.data('track-object').categories
    _ctaValue = $el.data('track-object').value
    _event = $el.data('track-object').event

    idArray = []
    idArray.push _categories if _categories
    idArray.push _ctaValue if _ctaValue
    idArray.push _event if _event

    idArray.join().toLowerCase().replace(/[^\w]/g, '')

Atrackt._debugConsole() if Atrackt._debug()

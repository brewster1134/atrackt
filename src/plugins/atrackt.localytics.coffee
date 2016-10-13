###
Atrackt Localytics Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 1.0.2
###

((factory) ->
  if define?.amd
    define [
      'atrackt'
    ], (Atrackt) ->
      factory Atrackt
  else
    factory Atrackt
) (Atrackt) ->

  window.Atrackt.setPlugin 'localytics',
    send: (data, options) ->
      if @_isUiWebView()
        redirectUrl = @_getRedirectUrl data, options
        @_redirect redirectUrl
      else
        @_callTagMethod data, options

    # HTML5 methods
    #
    _callTagMethod: (data, options) ->
      localyticsSession?.tagEvent options.eventName, data

    # UIWebView/HTML5 Hybrid methods
    #

    # Check if being run in UIWebView
    #
    _isUiWebView: ->
      /(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/i.test(navigator.userAgent)

    _getRedirectUrl: (data, options) ->
      redirectUrl = if options.screenEvent
        "localytics://?screenEvent=#{options.eventName}"
      else
        "localytics://?event=#{options.eventName}"

      redirectUrl += "&attributes=#{JSON.stringify(data)}" if Object.keys(data).length
      redirectUrl

    _redirect: (url) ->
      window.location = url if @_isUiWebView()

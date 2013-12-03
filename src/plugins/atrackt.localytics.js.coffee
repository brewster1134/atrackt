###
Atrackt Localytics Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 0.0.1
###

window.Atrackt.registerPlugin 'localytics',
  send: (obj, options) ->
    return console.log 'LOCALYTICS SCRIPT NOT LOADED!' unless localyticsSession?

    localyticsSession.tagEvent options.localytics.eventName, obj

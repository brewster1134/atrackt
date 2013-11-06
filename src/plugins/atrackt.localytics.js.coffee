###
Atrackt Localytics Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 0.0.1
###

window.Atrackt.registerPlugin 'localytics',
  send: (obj, options) ->
    localyticsSession?.tagEvent options.localytics.eventName, obj

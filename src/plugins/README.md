### CHANGE LOG
##### Localytics Plugin
###### 0.0.2
* supports detecting when in UIWebView
* redirects to a `localytics://` style url for UIWebView

###### 0.0.1
* Just a simple send method!

##### Omniture Plugin
###### 0.0.7
* Supports multiple types for tracked values

###### 0.0.6
* Proper `this|true` support
* Proper regex replace
  * Can be customized with options as `charReplaceRegex` (default `/[^\x20-\x7E]/g` )

###### 0.0.5
* Send method accepts option `delay: 'this'|false`
* Non-printable characters are removed from tracking object values

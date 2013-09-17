### CHANGE LOG

##### Omniture Plugin

###### 0.0.5

* Send method accepts option `delay: 'this'|false`
* Non-printable characters are removed from tracking object values

###### 0.0.6

* Proper `this|true` support
* Proper regex replace
  * Can be customized with options as `charReplaceRegex` (default `/[^\x20-\x7E]/g` )

###### 0.0.7
* Supports multiple types for tracked values

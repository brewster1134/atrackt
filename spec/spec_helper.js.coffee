window.loadJs = (jsFile) ->
  script = $('<script>').attr
    type: 'text/javascript'
    src: "/#{jsFile}.js"
  $('head').append script
  script

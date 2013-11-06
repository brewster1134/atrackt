window.loadJs = (jsFile) ->
  script = $('<script>').attr
    type: 'text/javascript'
    src: "/#{jsFile}.js"
  $('body').append script
  script

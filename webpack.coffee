path = require 'path'

module.exports =
  mode: 'development'
  target: 'web'
  watch: true
  devtool: 'eval-source-map'
  devServer:
    watchContentBase: true
    contentBase: [
      'demo'
      'listeners'
      'plugins'
      'src'
    ]
  entry:
    # core
    console: './src/core/console.coffee'
    core: './src/core/core.coffee'
    demo: './demo/demo.coffee'

    # listeners
    dom: './listeners/dom/dom.coffee'
    jquery: './listeners/jquery/jquery.coffee'

    # plugins
    'adobe-analytics': './plugins/adobe-analytics/adobe-analytics.coffee'
    'sumo-logic': './plugins/sumo-logic/sumo-logic.coffee'
  module:
    rules: [
      test: /\.coffee$/
      loader: 'coffee-loader'
      options:
        bare: true
        header: false
        sourceMap: true
        transpile:
          presets: ['@babel/env']
    ,
      test: /\.s[ac]ss$/
      use: [
        'style-loader'
        'css-loader'
        'sass-loader'
      ]
    ]
  resolve:
    modules: [
      path.resolve __dirname, 'demo'
      path.resolve __dirname, 'node_modules'
      path.resolve __dirname, 'src', 'core'
    ]
  watchOptions:
    ignored: /node_modules/

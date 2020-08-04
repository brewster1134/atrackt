{ CleanWebpackPlugin } = require 'clean-webpack-plugin'
path = require 'path'

module.exports =
  target: 'web'
  entry:
    # core
    core: './src/core/core.coffee'
    console: './src/core/console.coffee'

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
  output:
    filename: '[name].js'
    path: path.resolve __dirname, '.dist'
  plugins: [
    new CleanWebpackPlugin()
  ]
  resolve:
    modules: [
      path.resolve __dirname, 'node_modules'
      path.resolve __dirname, 'src', 'core'
    ]

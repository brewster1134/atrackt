{ CleanWebpackPlugin } = require 'clean-webpack-plugin'
path = require 'path'

module.exports =
  target: 'web'
  watch: true
  entry:
    'atrackt.console': './core/atrackt/atrackt.console.coffee'
    atrackt: './core/atrackt/atrackt.coffee'
    dom: './listeners/dom/dom.coffee'
    jquery: './listeners/jquery/jquery.coffee'
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
    alias:
      atrackt: path.resolve __dirname, 'core', 'atrackt', 'atrackt.coffee'
    modules: [
      path.resolve __dirname, 'core', 'atrackt'
      path.resolve __dirname, 'node_modules'
    ]
  watchOptions: {
    ignored: /node_modules/
  }

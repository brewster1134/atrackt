{ CleanWebpackPlugin } = require 'clean-webpack-plugin'
path = require 'path'

module.exports =
  mode: 'development'
  target: 'web'
  entry:
    atrackt: './core/atrackt/atrackt.coffee'
    console: './core/atrackt/atrackt.console.coffee'
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

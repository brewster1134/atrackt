{ merge } = require 'webpack-merge'
common = require './webpack.common.coffee'
path = require 'path'

module.exports = merge common,
  mode: 'development'
  watch: true
  devServer:
    watchContentBase: true
    contentBase: [
      'src'
      'demo'
      'listeners'
      'plugins'
    ]
  entry:
    demo: './demo/demo.coffee'
  resolve:
    modules: [
      path.resolve __dirname, 'demo'
    ]
  watchOptions: {
    ignored: /node_modules/
  }

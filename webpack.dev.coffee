{ merge } = require 'webpack-merge'
common = require './webpack.common.coffee'
path = require 'path'

module.exports = merge common,
  mode: 'development'
  devServer:
    watchContentBase: true
    contentBase: [
      'core'
      'demo'
      'listeners'
      'plugins'
    ]
  entry:
    demo: './demo/atrackt.demo.coffee'
  resolve:
    modules: [
      path.resolve __dirname, 'demo'
    ]

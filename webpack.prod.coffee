{ merge } = require 'webpack-merge'
common = require './webpack.common.coffee'

module.exports = merge common,
  mode: 'production'

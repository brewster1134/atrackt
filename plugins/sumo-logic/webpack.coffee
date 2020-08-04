{ merge } = require 'webpack-merge'
common = require '../../webpack.package.coffee'

module.exports = merge common,
  entry:
    'sumo-logic': './sumo-logic.coffee'

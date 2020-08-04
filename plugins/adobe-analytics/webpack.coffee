{ merge } = require 'webpack-merge'
common = require '../../webpack.package.coffee'

module.exports = merge common,
  entry:
    'adobe-analytics': './adobe-analytics.coffee'

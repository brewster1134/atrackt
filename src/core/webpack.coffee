{ merge } = require 'webpack-merge'
common = require '../../webpack.package.coffee'

module.exports = merge common,
  entry:
    core: './core.coffee'
    console: './console.coffee'
  module:
    rules: [
      test: /\.s[ac]ss$/
      use: [
        'style-loader'
        'css-loader'
        'sass-loader'
      ]
    ]
  resolve:
    modules: [
      '.'
    ]

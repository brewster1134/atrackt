path = require 'path'

module.exports =
  mode: 'production'
  target: 'web'
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
    ]
  output:
    filename: '[name].js'
    path: process.cwd()
  resolve:
    modules: [
      'node_modules'
    ]

path = require 'path'
CopyPkgJsonPlugin = require 'copy-pkg-json-webpack-plugin'
CopyPlugin = require 'copy-webpack-plugin'
ReplaceInFileWebpackPlugin = require 'replace-in-file-webpack-plugin'

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
    path: path.resolve process.cwd(), '.dist'
  plugins: [
    new CopyPkgJsonPlugin
      remove: ['scripts']
    new CopyPlugin
      patterns: [
        from: path.resolve process.cwd(), 'README.md'
        to: path.resolve process.cwd(), '.dist'
      ,
        from: path.resolve __dirname, 'LICENSE'
        to: path.resolve process.cwd(), '.dist'
      ]
    new ReplaceInFileWebpackPlugin [
      dir: '.dist'
      files: ['package.json']
      rules: [
        search: /"browser": "(.+)\.coffee"/
        replace: (match, p1) -> "\"browser\": \"#{p1}.js\""
      ]
    ]
  ]
  resolve:
    modules: [
      'node_modules'
    ]

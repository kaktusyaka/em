const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const webpack = require('webpack')

const path = require('path')
const PurgecssPlugin = require('purgecss-webpack-plugin')
const glob = require('glob-all')
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

environment.plugins.append("Provide", new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))

environment.loaders.append('expose', {
    test: require.resolve('jquery'),
    use: [{
        loader: 'expose-loader',
        options: '$'
    }, {
        loader: 'expose-loader',
        options: 'jQuery',
    }, {
        loader: 'expose-loader',
        options: 'WOW',
    }]
})

environment.plugins.append('PurgecssPlugin', new PurgecssPlugin({
  paths: glob.sync([
    path.join(__dirname, '../../app/javascript/**/*.vue'), // if using Vue.js
    path.join(__dirname, '../../app/javascript/**/*.js'),
    path.join(__dirname, '../../app/views/**/*.haml'),
    path.join(__dirname, '../../app/views/**/*.erb'),
    path.join(__dirname, '../../app/**/*.rb'),
  ]),
  // extractors: [ // if using Tailwind
  //   {
  //     extractor: TailwindExtractor,
  //     extensions: ['html', 'js', 'vue', 'ha']
  //   }
  // ]
}));

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.splitChunks()
module.exports = environment

/*
* Based on https://github.com/ccoenraets/react-trivia
* Published under MIT license
*/

var path = require('path');
var webpack = require('webpack');

var triviaEndpoint;
var setupEndpoint = function() {
  switch(process.env.NODE_ENV) {
  case 'production':
    triviaEndpoint = 'https://api.fspike.com';
    break;
  case 'test':
    triviaEndpoint = 'https://api-test.fspike.com';
    break;
  case 'development':
  case 'local':
  default:
    triviaEndpoint = 'http://localhost';
    break;
  }
};
setupEndpoint();

module.exports = {
  entry: './js/app.js',
  output: {
    path: path.resolve(__dirname, 'build'),
    filename: 'app.bundle.js'
  },
  plugins: [
    new webpack.DefinePlugin({
      '__TRIVIA_API__': JSON.stringify(triviaEndpoint)
    })
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: "babel-loader"
      },
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: "babel-loader"
      }
    ]
  },
  stats: {
    colors: true
  },
  devtool: 'source-map'
};

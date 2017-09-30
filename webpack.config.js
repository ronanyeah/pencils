const webpack = require("webpack");
const { resolve } = require("path");

const PROD = false;

module.exports = {
  entry: "./index.js",
  output: {
    path: resolve("./public/"),
    filename: "bundle.js"
  },
  devServer: {
    contentBase: "./public"
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          ...(PROD ? [] : [{ loader: "elm-hot-loader" }]),
          {
            loader: "elm-webpack-loader",
            options: {
              cwd: __dirname,
              debug: !PROD,
              warn: !PROD
            }
          }
        ]
      }
    ]
  },
  plugins: [
    ...(PROD
      ? [new webpack.optimize.UglifyJsPlugin()]
      : [new webpack.NamedModulesPlugin(), new webpack.NoEmitOnErrorsPlugin()])
  ]
};

import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = import.meta.dirname || path.dirname(fileURLToPath(import.meta.url));

export default {
  entry: './index.js',
  output: {
    filename: 'bundle.js',
    path: __dirname,
  },
  module: {
    rules: [
      {
        test: /\.(woff|woff2|eot|ttf|otf|svg)$/i,
        type: 'asset/inline',
      },
    ],
  },
  experiments: {
    css: true,
  },
};

/* eslint-env node */

module.exports = {
  env: {
    browser: true,
    es2022: true,
  },
  parserOptions: {
    sourceType: "module",
  },
  extends: ["eslint:recommended", "plugin:prettier/recommended"],
  ignorePatterns: ["app/javascript/controllers/index.js"],
};

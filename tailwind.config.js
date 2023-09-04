/* eslint-env node */

module.exports = {
  content: [
    "./app/assets/stylesheets/**/*.css",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.html*",
    "./public/*.html",
  ],
  plugins: [
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
    require("@tailwindcss/typography"),
  ],
};

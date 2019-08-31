module.exports = {
  root: true,
  env: {
    jest: true,
    node: true,
    es6: true,
    browser: true
  },
  parserOptions: {
    parser: 'babel-eslint'
  },
  extends: [
    "eslint:recommended",
    // https://github.com/vuejs/eslint-plugin-vue#priority-a-essential-error-prevention
    // consider switching to `plugin:vue/strongly-recommended` or `plugin:vue/recommended` for stricter rules.
    "plugin:vue/recommended",
  ],
  // required to lint *.vue files
  plugins: [
    'vue'
  ],
  rules: {
    // 'vue/no-unused-vars': 'error'
    "no-console": "off",
    "no-debugger": "warn",
    "vue/max-attributes-per-line": "off",
  }
};

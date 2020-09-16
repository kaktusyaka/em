import Vue from 'vue/dist/vue.esm'

Vue.filter('with_emoji', (value) => {
  return value.replace(/\\u(....)/g, (match, p1) => String.fromCharCode(parseInt(p1, 16))).replace(/\\(\d{3})/g, (match, p1) => String.fromCharCode(parseInt(p1,  8)))
})

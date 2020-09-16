<template>
  <span :class="'f-s-12 label ' + value['class'] " :title="value['title']">
    {{ value['value'] }}
  </span>
</template>

<script>
export default {
  props: ['value'],
  mounted () {
    $('span.label[title]').tooltip()
  }
}
</script>

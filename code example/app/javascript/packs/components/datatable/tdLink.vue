<template>
  <span>
    <a :href="value" target="_blank">{{ value }}</a>
    &nbsp;
    <i class="f-s-12 fas fa-external-link-alt"></i>
  </span>
</template>

<script>
export default {
  props: ['value']
}
</script>

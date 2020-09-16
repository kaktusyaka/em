<template>
  <span>
    <a :href="'/payments/' + value">
      <i class="f-s-12 fas fa-download"></i>
      Download
    </a>
  </span>
</template>

<script>
export default {
  props: ['value']
}
</script>

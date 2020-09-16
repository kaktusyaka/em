<template>
  <div>
    <notifications group='flash_messages' />
  </div>
</template>


<script>
  export default {
    props: ['flash_messages'],
    data () {
      return { }
    },

    mounted () {
      this.flash_messages.map((a, i) => {
        this.$notify({
          group: 'flash_messages',
          text: a.text,
          type: a.type,
          duration: 5000
        })
      })
    }
  }

</script>

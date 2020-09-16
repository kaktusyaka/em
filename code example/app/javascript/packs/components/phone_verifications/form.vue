<template>
  <div class='form-group'>
    <label for="phone_number">Mobile number</label>
    <vue-tel-input name="phone_number" v-bind="bindProps"></vue-tel-input>
  </div>
</template>

<script>

  import { VueTelInput } from 'vue-tel-input'

  export default {
    components: {
      VueTelInput,
    },
    data () {
      return {
        bindProps: {
          mode: "international",
          enabledFlags: true,
          enabledCountryCode: true,
          required: true
        }
      }
    }
  }
</script>

<style lang="scss">
</style>

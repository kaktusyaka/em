<template>
  <div class='row'>
    <div class='col-md-10 col-sm-12 col-xs-12 offset-md-1 alert alert-lime'>
      <button class='close' type='button' data-dismiss='alert' aria-label='Close' v-on:click="hideTrial">
        <span class='f-s-18' aria-hidden='true' style="font-size:20px">×</span>
      </button>
      <div class='text-center f-s-16'>
        Get Your First 50 Likes
        <strong>Free</strong>
        &nbsp;
        <a href='/trial_orders/new' class='btn btn-green'>Try It for Free</a>
      </div>
    </div>
  </div>

</template>

<script>
  export default {
    data: function () { return {} },
    methods: {
      hideTrial() {
        this.$cookies.set("notShowTrial","true",'7d')
      }
    }
  }
</script>

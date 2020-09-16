<template>
  <div class='text-center'>
    <notifications />

    <button v-on:click='showModal' class="btn btn-primary text-center">+ Add an Account</button>

    <modal name="add-account" :resizable='true' :scrollable="true" :reset='true' :adaptive="true" height="auto" @before-close="beforeCloseModal">
      <!-- Submit username and passowrd -->
      <form v-on:submit.prevent='addAccount' v-if='showAddAccountFields'>
        <div class="row m-t-20">
          <div class="col-10 offset-1 p-10 p-t-15">
            <h4 class="m-b-15">Adding an Instagram account</h4>

            <div class="alert alert-warning alert-dismissable">
              Adding an account can take up to 1 minute
            </div>

            <div class="alert alert-danger alert-dismissable" id="errorExplanation" v-if='errors.length > 0'>
              <ul class='m-t-15 m-b-15'>
                <li v-for="(error, index) in errors">
                  {{ error }}
                </li>
              </ul>
            </div>

            <div class="form-group">
              <label for="username">Instagram Username</label>
              <input class="form-control" v-model='username' type="text" name="instagram_account[username]">
            </div>
            <div class="form-group">
              <label for="password">Instagram Password</label>
              <input class="form-control" v-model='password' type="password" name="instagram_account[password]">
            </div>

            <div v-if='!isDisabledAddAccount' class='p-b-20' >
              <button type="submit" class="btn btn-large btn-lime m-r-5 m-t-15">Add Account</button>
              <a v-on:click='hideModal' href='javascript:;' class="btn btn-large btn-default m-r-5 m-t-15">Close</a>
            </div>
            <div class='spinner m-0 m-t-20' v-else></div>
          </div>
        </div>
      </form>

      <form v-on:submit.prevent='checkSmsCode' v-if='show2FaFields'>
        <div class="row m-t-20">
          <div class="col-10 offset-1 p-10 p-t-15">
            <h4 class="m-b-15">Enter verification code</h4>

            <div class="alert alert-danger alert-dismissable" id="errorExplanation" v-if='sms_errors.length > 0'>
              <ul class='m-t-15 m-b-15'>
                <li v-for="(error, index) in sms_errors">
                  {{ error }}
                </li>
              </ul>
            </div>

            <div class="alert alert-warning" v-if='smsCodeMessage.length > 0'>
              {{ smsCodeMessage }}
            </div>

            <div class="form-group">
              <label for="verification_code">Secure Code</label>
              <input class="form-control" placeholder="Secure Code" v-model='verification_code' type="number" name="instagram_account[verification_code]">
            </div>
            <p>
              Didn't receive your code? <a href='javascript:;' class='font-weight-bold' @click='resendSmsCode'>Get a new one</a>.
            </p>

            <div v-if='!isDisabledSmsCode' class='p-b-20' >
              <button type="submit" class="btn btn-large btn-lime m-r-5 m-t-15">Verify</button>
              <a v-on:click='hideModal' href='javascript:;' class="btn btn-large btn-default m-r-5 m-t-15">Close</a>
            </div>
            <div class='spinner m-0 m-t-20' v-else></div>
          </div>
        </div>
      </form>
    </modal>
  </div>
</div>
</template>

<script>
import axios from 'axios'

export default {
  data () {
    return {
      loading: true,
      isDisabledAddAccount: false,
      errors: [],
      sms_errors: [],
      username: null,
      password: null,
      verification_code: null,
      isDisabledSmsCode: false,
      showAddAccountFields: true,
      show2FaFields: false,
      smsCodeMessage: '',
      challenge: false
    }
  },

  methods: {
    showModal () {
      this.$modal.show('add-account')
    },

    hideModal () {
      this.$modal.hide('add-account')
    },

    beforeCloseModal () {
      this.isDisabledAddAccount = false
      this.errors = []
      this.sms_errors = []
      this.username = null
      this.password = null
      this.verification_code = null
      this.isDisabledSmsCode = false
      this.showAddAccountFields = true
      this.show2FaFields = false
      this.smsCodeMessage = ''
      this.challenge = false
    },

    addAccount() {
      this.errors = []
      this.isDisabledAddAccount = true
      axios.post('/api/instagram/accounts', { instagram_account: { username: this.username,
                                                                   password: this.password
                                                                  } })
            .then(response => {
              if ( response.data.hasOwnProperty('two_factor_info') ) {
                this.smsCodeMessage = 'Enter the code Instagram sent to your number ending in ' + response.data.two_factor_info
              }
              if ( response.data.hasOwnProperty('challenge_info') ) {
                this.challenge = true
                this.smsCodeMessage = response.data.challenge_info
              }

              if ( response.data.hasOwnProperty('redirect_to') ) {
                Turbolinks.visit(response.data.redirect_to)
                return
              }
              this.showAddAccountFields = false
              this.show2FaFields = true
            })
            .catch(error => {
              this.isDisabledAddAccount = false
              error.response.data.errors.map((a, i) => {
                this.errors.push(a)
              })
            })
    },

    checkSmsCode () {
      let url = null

      this.sms_errors = []
      this.isDisabledSmsCode = true
      if (this.challenge)
        url = '/api/instagram/accounts/send_challenge'
      else
        url = '/api/instagram/accounts/two_factor_login'

      axios.post(url, { verification_code: this.verification_code })
           .then(response => {})
           .catch(error => {
             error.response.data.errors.map((a, i) => {
               this.sms_errors.push(a)
             })
           })
           .then(response => {
             this.isDisabledSmsCode = false
           });

    },

    resendSmsCode () {
      let url = null

      this.sms_errors = []
      this.isDisabledSmsCode = true

      if (this.challenge)
        url = '/api/instagram/accounts/resend_challenge_code'
      else
        url = '/api/instagram/accounts/resend_sms_code'


      axios.post(url)
           .then(response => {
             this.smsCodeMessage = response.data.message
           })
           .catch(error => {
             error.response.data.errors.map((a, i) => {
               this.sms_errors.push(a)
             })
           })
           .then(response => {
             this.isDisabledSmsCode = false
           });

    }
  }
}
</script>

<style>
  .vue-notification {
    padding: 16px;
    margin: 60px 5px 5px;
    right:20px;

    font-size: 12px;

    color: #ffffff;
    background: #44A4FC;
    border-left: 5px solid #187FE7;

    &.warn {
      background: #ffb648;
      border-left-color: #f48a06;
    }

    &.error {
      background: #E54D42;
      border-left-color: #B82E24;
    }

    &.success {
      background: #68CD86;
      border-left-color: #42A85F;
    }
  }
  .spinner {
    position: relative;
    top: 0;
    left: 0;
  }
  .v--modal-overlay {
    background: rgba(0, 0, 0, 0.5);
  }
</style>

<template>
  <div>
    <notifications />

    <button v-on:click='showModal' class="btn btn-primary btn-block">+ Add Account</button>

    <modal name="add-account" :resizable='true' :scrollable="true" :reset='true' :adaptive="true" height="auto" @before-close="beforeCloseModal">
      <!-- Submit username and passowrd -->
      <form v-on:submit.prevent='addAccount' v-if='showAddAccountFields'>
        <div class="row m-t-20">
          <div class="col-10 offset-1 p-10 p-t-15">
            <h4 class="m-b-15">Add New Account</h4>

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


    <h4 class='m-t-30 m-b-20'>Connected Accounts</h4>

    <div class='row'>
      <div class="loader" v-if="loading"></div>
      <div class='col-12 m-b-5 p-b-1' v-for="account in accounts">
        <div class='p-10 bg-white rounded'>
          <div class='media media-xs overflow-visible align-items-center'>
            <a v-bind:href="'/instagram/accounts/' + account.attributes.username" class="media-left">
              <img class='rounded-corner' width='90' height='90' :alt='account.attributes.username' :src="account.attributes.profile_pic_url"/>
            </a>
            <div class='media-body m-l-20'>
              <a v-bind:href="'/instagram/accounts/' + account.attributes.username">
                <b class="f-s-18 media-heading">{{ account.attributes.username }}</b>
              </a>
              <a v-bind:href="'https://instagram.com/' + account.attributes.username" target="_blank" class='m-l-15'>
                <i class="fas fa-external-link-alt" title='Open on Instagram'></i>
              </a>

              <div class='p-t-15 clearfix'>
                <span class='m-r-10'> {{ account.attributes.media_count }}</span>
                <span class='m-r-10'> {{ account.attributes.follower_count }}</span>
                <span class='m-r-10'> {{ account.attributes.follow_count }} following</span>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</template>

<script>
import axios from 'axios'
import { linkify } from '../../../mixins/linkify'

export default {
  mixins: [linkify],
  data () {
    return {
      loading: true,
      accounts: [],
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
              if ( response.data.two_factor_info !== '' ) {
                this.smsCodeMessage = 'Enter the code Instagram sent to your number ending in ' + response.data.two_factor_info
              }
              if ( response.data.challenge_info !== '' ) {
                this.challenge = true
                this.smsCodeMessage = response.data.challenge_info
              }
            })
            .catch(error => {
              this.isDisabledAddAccount = false
              error.response.data.errors.map((a, i) => {
                this.errors.push(a)
              })
            })
            .then(response => {
              this.showAddAccountFields = false
              this.show2FaFields = true
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
  },

  mounted () {
    this.loading = true
    axios.get('/api/instagram/accounts')
         .then((response) => {
           this.accounts = response.data.data
           this.loading = false
         })
  }

  //
  //   addAccount () {
  //     let user = this.selectedAccount.user
  //     this.selectedAccount = null
  //     axios.post('/api/targets', { target: { type: 'Targets::User',
  //                                            username: user.username,
  //                                            pk: user.pk,
  //                                            full_name: user.full_name,
  //                                            is_private: user.is_private,
  //                                            profile_pic_url: user.profile_pic_url,
  //                                            follower_count: user.follower_count } })
  //           .then(response => {
  //             this.$notify({
  //               type: 'success',
  //               text: 'Target has been added successfuly!'
  //             });
  //             this.targets.push(response.data.data)
  //           })
  //           .catch(error => {
  //             this.$notify({
  //               type: 'error',
  //               text: error.response.data.message
  //             });
  //           })
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
</style>

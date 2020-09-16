<template>
  <div id="app">
    <notifications />
    <div class="content" id="content">
      <h3>New target</h3>
      <div class="row">
        <div class="col-4 p-t-10 p-b-15">
          <v-select label="name" :filterable="false" :options="options" @search="onSearch" @input="optionSelected" :value='selectedAccount'>
            <template slot="no-options">
              type to search instagram users..
            </template>
            <template slot="option" slot-scope="option">
              <div class="d-center">
                <img :src='option.user.profile_pic_url'/>
                <div class='details pull-left'>
                  <p><b>{{ option.user.username }}</b></p>
                  <p>{{ option.user.full_name | with_emoji }}</p>
                </div>
              </div>
            </template>
            <template slot="selected-option" slot-scope="option">
              <div class="selected d-center">
                <img :src='option.user.profile_pic_url'/>
                <div class='details pull-left'>
                  <p><b>{{ option.user.username }}</b></p>
                  <p>{{ option.user.full_name | with_emoji }}</p>
                </div>
              </div>
            </template>
          </v-select>
          <transition name="fade">
            <button v-show="selectedAccount" v-on:click="addAccount" type="button" class="btn-lime m-t-10 btn">Add Account</button>
          </transition>
       </div>
      </div>
    <hr>
    <h3>Targets</h3>
    <h3 class="p-t-20">Users:</h3>

    <div class="loader" v-if="loading"></div>

    <ul class="media-list media-list-with-divider row m-t-20">
			<li v-for="target in targets" class="media col-md-4 p-t-0 m-t-0 border-top-0">
  		  <a v-bind:href="'/targets/' + target.attributes.username" class="pull-left">
          <img :src="target.attributes.profile_pic_url" class='rounded-corner' width='110' height='110'>
  			</a>
  			<div class="media-body">
          <a v-bind:href="'/targets/' + target.attributes.username" class='pull-left'>
  	  		  <h3 class="media-heading">{{ target.attributes.username }}</h3>
          </a>
          <div class="btn-group">
            <a href="#" class='pull-left m-l-20' data-toggle="dropdown">
              <i style='font-size: 22px; display: inline-block' class='fas fa-cog m-t-4'></i>
            </a>
            <ul class="dropdown-menu pull-right">
              <li>
                <a v-bind:href="'https://instagram.com/' + target.attributes.username" target="_blank">Open on Instagram</a>
              </li>
            </ul>
          </div>
          <div class='p-t-15 clearfix'>
            <span class='m-r-10'> {{ target.attributes.media_count }}</span>
            <span class='m-r-10'> {{ target.attributes.follower_count }}</span>
            <span class='m-r-10'> {{ target.attributes.follow_count }} following</span>
          </div>
          <div class='p-t-10 clearfix' v-if="target.attributes.full_name">
            <span class='m-r-10 font-weight-bold'>{{ target.attributes.full_name | with_emoji }}</span>
          </div>
          <div class='p-t-10'><pre v-html='likifyInstagram(target.attributes.biography)'></pre></div>
  			 </div>
         </a>
  		</li>
    </ul>
  </div>
</div>
</template>

<script>
import axios from 'axios'
import { linkify } from '../../mixins/linkify'

export default {
  mixins: [linkify],
  props: ["targets", "loading"],
  data () {
    return {
      options: [],
      selectedAccount: null
    }
  },
  computed: {
    csrf_token () {
      return document.querySelector("meta[name=csrf-token]").content
    }
  },
  methods: {
    onSearch(search, loading) {
      loading(true)
      this.search(loading, search, this)
    },
    search: _.debounce((loading, search, vm) => {
      if (search == '') {
        loading(false)
        return
      }

      axios.get('https://www.instagram.com/web/search/topsearch/', { params: { context: 'user', query: escape(search), include_reel: true } })
           .then((response) => {
             vm.options = response.data.users
             loading(false);
           })
    }, 350),

    optionSelected (account) {
      this.selectedAccount = account
    },

    addAccount () {
      let user = this.selectedAccount.user
      this.selectedAccount = null
      axios.post('/api/targets', { target: { type: 'Targets::User',
                                             username: user.username,
                                             pk: user.pk,
                                             full_name: user.full_name,
                                             is_private: user.is_private,
                                             profile_pic_url: user.profile_pic_url,
                                             follower_count: user.follower_count } })
            .then(response => {
              this.$notify({
                type: 'success',
                text: 'Target has been added successfuly!'
              });
              this.targets.push(response.data.data)
            })
            .catch(error => {
              this.$notify({
                type: 'error',
                text: error.response.data.message
              });
            })
    }
  }
}
</script>

<style>
  .v-select img, .selected img  {
    height: auto;
    max-width: 4.5rem !important;
    margin-right: 1rem;
    border-radius: 2rem !important
  }

  .vs__dropdown-option--highlight {
    background-color: rgb(250, 250, 250);
    color: #000;
  }

  .vs__dropdown-toggle {
    background: #fff;
  }

  .d-center {
    display: flex;
    align-items: center;
  }

  .v-select .details, .selected .details {
    font-size: 15px;
  }

  .v-select .details p, .selected .details p {
    margin: 0;
  }

  .v-select .dropdown li {
    border-bottom: 1px solid black;
  }

  .v-select .dropdown li:last-child {
    border-bottom: none;
  }

  .v-select .dropdown li a {
    padding: 10px 20px;
    width: 100%;
    font-size: 1.25em;
    color: #3c3c3c;
  }

  .v-select .dropdown-menu .active > a {
    color: #fff;
  }

  pre {
    font-family: "Open Sans", Arial, sans-serif;
    font-size: 12px;
    overflow: unset;
    white-space: pre-wrap;
  }

  .fade-enter-active, .fade-leave-active {
    transition: opacity .5s;
  }

  .fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
    opacity: 0;
  }

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
</style>

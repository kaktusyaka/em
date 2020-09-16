<template>
  <div>
    <form v-on:submit='submitOrder'>
      <div class="row m-t-20">

        <div class="col-md-5 offset-md-1 col-sm-12 col-xs-12 bg-white border-right p-10 p-t-15">
          <h4 class="m-b-15">New Order</h4>

          <div class="form-group">
            <label for="category">Category</label>
            <select v-model='category' name="category" id="category" class="form-control" required='required'>
              <option v-for="(category, index) in categories" :value='category.id'>
                {{category.name}}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label for="service_id">Service</label>
            <select v-model.number='serviceId' v-if="category" class="form-control" name="order[service_id]" id="service_id" required='required'>
              <option v-for="(service, index) in services[category]" :value='service.id'>
                {{service.name}}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>{{linkUrlLabel}}</label>
            <input class="form-control" v-model='linkUrl' @keyup:enter="changeUrl" @blur="changeUrl" type="url" name="order[link_url]">
          </div>
          <link-prevue :url="linkUrl" apiUrl='/api/orders/link_preview' class='m-b-15'>
            <template slot-scope="props">
              <div class="card">
                <div class='row p-10'>
                  <img class="card-img-top col-4 width-150" :src="props.img" :alt="props.title">
                  <div class="card-block col-8">
                    <h4 class="card-title">{{props.title}}</h4>
                    <p class="card-text m-0 m-b-5">{{props.description}}</p>
                    <a v-bind:href="props.url" class="btn btn-primary" target='_blank'>More</a>
                  </div>
                </div>
              </div>
            </template>
          </link-prevue>

          <div class="form-group">
            <label>Quantity</label>
            <input class="form-control" type="number" name="order[quantity]" v-model='quantity'>
          </div>

          <div class='form-group' v-if='allowComments'>
            <label>Comments (1 per row)</label>
            <textarea class="form-control" name="order[comments]" rows='5' v-model='comments'></textarea>
          </div>

          <div class='m-t-15 checkbox checkbox-css' v-if='allowTimer'>
            <input type='checkbox' id='order_check_timer' name="order[check_timer]" v-model='checkTimer' />
            <label for='order_check_timer'>Set Speed</label>
          </div>

          <div v-if='checkTimer'>
            <h5>Settings</h5>
            <div class="form-group">
              <label>Quantity</label>
              <input class="form-control" type="number" name="order[timer_likes]" v-model='timerLikes'>
            </div>
            <div class="form-group">
              <label>Delay (days)</label>
              <input class="form-control" type="number" name="order[timer_interval]" v-model='timerInterval'>
            </div>
          </div>

          <div class="alert alert-danger alert-dismissable" id="errorExplanation" v-if='errors.length > 0'>
            <ul class='m-t-15 m-b-15'>
              <li v-for="(error, index) in errors">
                {{ error }}
              </li>
            </ul>
          </div>

          <button type="submit" v-if='!isDisabled' class="btn btn-large btn-lime m-r-5 m-t-15">Create</button>
          <div class='spinner m-0 m-t-20' v-else></div>
        </div>

        <div>&nbsp;</div>
        <div class='hidden-xs hidden-sm'>&nbsp;</div>

        <div class="col-md-5 col-sm-12 col-xs-12 bg-white p-10 p-t-15">
          <h4 class="m-b-15">Preview</h4>

          <div class="form-group">
            <label>Service</label>
            <input type="text" :value='serviceName' class="form-control" disabled="disabled">
          </div>
          <div class="form-group">
            <label>Minimum/maximum</label>
            <input type="text" :value='minMax' class="form-control" disabled="disabled">
          </div>
          <div class="form-group">
            <label>Price per 1000</label>
            <input type="text" :value='price | currency' class="form-control" disabled="disabled">
          </div>
          <div class="form-group">
            <label>Total</label>
            <input type="text" :value='total | currency' class="form-control" disabled="disabled">
          </div>
          <div class="alert alert-primary alert-dismissable" v-html="this.serviceDescription" v-if='this.serviceDescription'>
          </div>
        </div>
      </div>
    </form>
  </div>
</template>

<script>
  import axios from 'axios'
  import LinkPrevue from 'link-prevue'

  let csrfToken = document.querySelector("meta[name=csrf-token]").content
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken

  export default {
    components: { LinkPrevue },
    props: ['services', 'categories'],
    data () {
      return {
        category: 1,
        serviceId: null,
        quantity: null,
        serviceName: null,
        minMax: null,
        price: 0,
        total: 0,
        linkUrl: null,
        comments: null,
        allowComments: false,
        checkTimer: false,
        allowTimer: false,
        timerLikes: 0,
        timerInterval: 0,
        isDisabled: false,
        errors: [],
        serviceDescription: null,
        linkUrlLabel: 'Link to Instagram Profile'
      }
    },
    methods: {
      changeUrl: function(event) {
        this.linkUrl = event.target.value
      },

      setDefaultService () {
        this.serviceId = this.services[this.category][0].id
      },

      updatePreview () {
        if (this.serviceId == null)
          this.serviceId = this.services[this.category][0].id

        var serviceDetails = this.services[this.category].find( ({ id }) => id == this.serviceId )
        this.serviceName = serviceDetails.name
        this.minMax = serviceDetails.minmax
        this.price = serviceDetails.price
        this.total = this.quantity * this.price / 1000
        this.allowComments = serviceDetails.allow_comments
        this.allowTimer = serviceDetails.allow_timer
        this.linkUrlLabel = serviceDetails.link_url_label
        this.serviceDescription = serviceDetails.description
      },

      updateMin () {
        this.quantity = this.services[this.category].find( ({ id }) => id == this.serviceId ).minmax.split('/')[0]
      },

      submitOrder (event) {
        event.preventDefault()
        this.isDisabled = true
        this.error = []

        axios.post('/api/orders', { order: { service_id: this.serviceId, quantity: this.quantity, link_url: this.linkUrl, comments: this.comments, timer_likes: this.timerLikes, timer_interval: this.timerInterval } })
             .then((response) => {
               setTimeout(function() {
                 Turbolinks.visit('/orders/history')
               }, 1000)
             })
             .catch(error => {
               this.isDisabled = false
               error.response.data.errors.map((a, i) => {
                 this.errors.push(a)
               })
             });
      }
    },

    mounted () {
      this.setDefaultService()
      this.updateMin()
      this.updatePreview()
    },

    watch: {
      category: function() {
        this.setDefaultService()
        this.updatePreview()
      },

      serviceId: function() {
        this.updateMin()
        this.updatePreview()
      },

      quantity: function() {
        this.updatePreview()
      }
    }

  }
</script>

<style lang="scss">
  #orders-new {
    div.spinner {
      top: 0;
      left: 0;
      position: relative;
    }

    select, input[type='text'], input[type='url'], input[type='number'] {
      font-size: 14px !important;
    }
  }

</style>

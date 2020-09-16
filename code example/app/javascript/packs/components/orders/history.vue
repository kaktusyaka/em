<template>
  <div>
    <div class='row'>
      <div class='col-md-10 offset-md-1 m-t-20 col-xs-12 col-ms-12'>
        <h4 class='p-0'>Orders History</h4>
      </div>
    </div>
    <div class='row p-10 m-t-10 p-t-15'>
      <datatable class='f-s-14 col-md-10 offset-md-1 col-xs-12 col-ms-12 bg-white' v-bind="$data" />
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import tdStatus from '../datatable/tdStatus'
  import tdLink from '../datatable/tdLink'

  export default {
    components: { tdStatus, tdLink },
    data: function () {
      return {
        HeaderSettings: false,
        columns: [
          { title: 'ID', field: 'id' },
          { title: 'Service', field: 'service', thClass: 'd-none d-md-table-cell', tdClass: 'd-none d-md-table-cell' },
          { title: 'Date', field: 'created_at', thClass: 'd-none d-md-table-cell', tdClass: 'd-none d-md-table-cell'},
          { title: 'URL', field: 'link_url', tdComp: 'tdLink' },
          { title: 'Initial quantity', field: 'beginning_quantity', thClass: 'd-none d-md-table-cell', tdClass: 'd-none d-md-table-cell' },
          { title: 'Quantity', field: 'quantity', thClass: 'd-none d-md-table-cell', tdClass: 'd-none d-md-table-cell'},
          { title: 'Status', field: 'status', tdComp: 'tdStatus' }
        ],
        data: [], // no data
        total: 0,
        query: { limit: 20 }
      }
    },
    watch: {
      query: {
        handler () {
          this.fetchData()
        },
        deep: true
      }
    },
    methods: {
      fetchData () {
        this.data = []
        axios.get('/api/orders/history', { params: { query: this.query } })
             .then((response) => {
               response.data.orders.data.map((a, i) => {
                 this.data.push(a.attributes)
               })
               this.total = response.data.total
             })
      }
    }
  }
</script>

<style lang="scss">
</style>

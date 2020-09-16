<template>
  <div>
    <ul class='nav nav-tabs nav-tabs-inverse nav-justified nav-justified-mobile bg-black-transparent-7 text-white' data-sortable-id='index-2' style='border-bottom: 1px solid #ccc;'>
      <li class='nav-item'>
        <a class='nav-link active' data-toggle='tab' href='#settings'>
          <i class='fas fa-cog fa-lg m-r-5'></i>
          <span class='d-none d-md-inline'>Account Settings</span>
        </a>
      </li>
    </ul>
    <div class="tab-content">
			<div class="tab-pane fade active show" id="settings">
        <div class='row'>
          <div class='col-12'>
            <h3>
              <i class="fas fa-tachometer-alt"></i>
              Limits
            </h3>
          </div>
          <div class='col-md-6 col-sm-12 col-xs-12'>
            s
          </div>
          <div class='col-md-6 col-sm-12 col-xs-12'>
            d
          </div>
        </div>
			</div>
		</div>
  </div>
</template>

<script>

export default {
  data () {
    return {
    }
  }
}

</script>

<template>
  <div>
    <div class='feed h-100'>
      <div class='instagram-post m-b-20' v-for="post in posts">
        <div class="row align-items-center p-10">
          <div class="col-1">
            <img :src="post.attributes.target.profile_pic_url" class='rounded-circle' width='36' height='36' />
          </div>
          <div class='col-6 m-l-10 font-weight-bold fs-14'>
            <a :href="post.attributes.target.link" class='text-dark'>{{ post.attributes.target.username }}</a>
          </div>
        </div>
        <carousel :nav="false" :items='1'>
          <template class='span-prev' slot="prev" v-if="post.attributes.media.length > 1">
            <span class="prev"><i class='fas fa-angle-left rounded-circle'></i></span>
          </template>
          <template slot="next" v-if="post.attributes.media.length > 1">
            <span class="next"><i class='fas fa-angle-right rounded-circle'></i></span>
          </template>
          <div v-for="(item, index) in post.attributes.media">
            <img v-if="item.typename !== 'GraphVideo'" :alt="item.accessibility_caption" :width="item.dimensions.width" :height="item.dimensions.height" decoding='auto' :src="item.display_url">
            <video v-else :width="item.dimensions.width" :poster="item.display_url" :height="item.dimensions.height" controls muted loop controlsList="nofullscreen nodownload">
              <source :src="item.video_url" type='video/mp4'>
              Your browser does not support the video tag.
            </video>
          </div>
        </carousel>
        <div class="content">
          <div class="heart">
            <i class="fa-heart fas"></i>
            <span class="likes"><b>10</b> likes</span>
            <!-- :class="{'fas': !this.post.upVoted,  'fas': this.post.upVoted}" @click="like"></i> -->
          </div>
        </div>
    </div>
  </div>


    <infinite-loading @infinite="fetchData">
      <div class='hide' slot="no-more">No more posts</div>
      <template slot="no-results">No posts</template>
      <div slot="spinner" class='loader'></div>
    </infinite-loading>
  </div>
</template>

<script>
  import axios from 'axios'
  import InfiniteLoading from 'vue-infinite-loading'
  import carousel from 'vue-owl-carousel'

  export default {
    props: ['url'],
    components: {
      'infinite-loading': InfiniteLoading,
      'carousel': carousel
    },
    data () {
      return {
        posts: [],
        page: 1
      }
    },
    methods: {
      fetchData ($state) {
        if (this.posts.length == 0 && this.page == 2) {
          $state.loaded();
          return
        }

        axios.get(this.url, { params: { page: this.page } })
             .then((response) => {
               if (response.data.data.length) {
                 ++this.page
                   response.data.data.map((a, i) => {
                   this.posts.push(a)
                 } )
                 $state.loaded()
               }
               else {
                 $state.complete()
               }
             })
      }
    }
  }
</script>

<style lang="scss">
  #targets-feed {
    width: 620px;
    margin-left: auto;
    margin-right: auto;
    height: 100%;

    .feed {
      height: 100%;
      overflow-y: scroll;
      overflow-x: hidden;
    }

    .instagram-post {
      background: #fff;
    }

    .align-items-center {
      border: 1px solid #ccc;
      border-bottom: 0px;
      font-size: 14px;
    }

    .owl-dots {
      margin-top: -25px !important;
      position: relative;
    }

    .owl-theme .owl-dots .owl-dot.active span, .owl-theme .owl-dots .owl-dot:hover span {
      background: #ffffff;
    }

    .owl-theme .owl-dots .owl-dot span {
      background: #737070;
      width: 8px;
      height: 8px;
      margin: 5px 4px;
    }

    span.prev {
      position: absolute;
      top: 50%;
      z-index: 11;
      cursor: pointer;
    }

    span.next {
      position: absolute;
      z-index: 19;
      cursor: pointer;
      margin-left: 91%;
      width: 30px;
      height: 30px;
      top: 50%;
    }

    span.prev i {
      font-size: 29px;
      background: #e0d7d7;
      width: 28px;
      height: 28px;
      padding-left: 5px;
      margin-left: 5px;
      opacity: 0.8;
    }

    span.next i {
      font-size: 29px;
      background: #e0d7d7;
      width: 28px;
      height: 28px;
      padding-left: 6px;
      opacity: 0.8;
    }

    .content {
      margin: 7.5px 10px;
    }

    .far.fa-heart, .fas.fa-heart{
      cursor: pointer;
    }

    .fa-heart {
      color: red;
      font-size: 20px;
    }

    .likes {
      margin-left: 5px;
      margin-bottom: 5px !important;
      font-size: 14px;
      font-weight: bold;
    }
  }

</style>

<template>
  <div>
    <div class="gallery">
      <div v-for="post in posts" class="gallery-item" v-on:click='show(post)'>
        <img alt="Image may contain: one or more people" class="gallery-image" :srcset="post.attributes.thumbnail_resources" :src="post.attributes.thumbnail_src">
        <div v-if="post.attributes.typename == 'GraphSidecar'" class="gallery-item-type">
          <span class="visually-hidden">Gallery</span>
          <i class="fas fa-clone" aria-hidden="true"></i>
        </div>
        <div v-if="post.attributes.typename == 'GraphVideo'" class="gallery-item-type">
          <span class="visually-hidden">Video</span>
          <i class="fas fa-video" aria-hidden="true"></i>
        </div>
        <div class="gallery-item-info">
          <ul>
            <li class="gallery-item-likes">
              <span class="visually-hidden">Likes:</span>
              <i class="fas fa-heart" aria-hidden="true"></i> {{post.attributes.edge_media_preview_like}}
            </li>
            <li class="gallery-item-comments">
              <span class="visually-hidden">Comments:</span>
              <i class="fas fa-comment" aria-hidden="true"></i> {{post.attributes.edge_media_to_comment}}
            </li>
          </ul>
        </div>
      </div>
    </div>

    <infinite-loading @infinite="fetchData">
      <div class='hide' slot="no-more">No more posts</div>
      <template slot="no-results">No posts</template>
      <div slot="spinner" class='loader'></div>
    </infinite-loading>

    <modal name="post-details" :resizable='true' :scrollable="true" :reset='true' :min-height="450" :adaptive="true" width="915" height="auto">
      <div slot="top-right">
        <i class="fas fa-times" aria-hidden="true" @click="hide()"></i>
      </div>
      <div class='post-show row'>
        <div class='col-8'>
          <carousel :nav="false" :items='1'>
            <template class='span-prev' slot="prev">
              <span class="prev"><i class='fas fa-angle-left rounded-circle'></i></span>
            </template>
            <template slot="next" v-if="list.length > 1">
              <span class="next"><i class='fas fa-angle-right rounded-circle'></i></span>
            </template>
            <div v-for="(item, index) in list">
              <img v-if="item.typename !== 'GraphVideo'" :alt="item.accessibility_caption" :width="item.dimensions.width" :height="item.dimensions.height" decoding='auto' :src="item.display_url">
              <video v-else :width="item.dimensions.width" :poster="item.display_url" :height="item.dimensions.height" controls muted loop controlsList="nofullscreen nodownload">
                <source :src="item.video_url" type='video/mp4'>
                Your browser does not support the video tag.
              </video>
            </div>
          </carousel>
        </div>
        <div class='col'>
        </div>
      </div>
    </modal>
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
      page: 1,
      display_url: null,
      accessibility_caption: null,
      list: []
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
    },
    show (post) {
      this.resources = post.attributes.thumbnail_resources
      this.display_url = post.attributes.display_url
      this.accessibility_caption = post.attributes.accessibility_caption
      this.list = post.attributes.media

      this.$modal.show('post-details')
    },

    hide () {
      this.$modal.hide('post-details')
    }
  }

}
</script>

<style lang="scss">

  #targets-show {
    .v--modal-overlay {
      background: rgba(0,0,0,.5);
    }

    .v--modal-top-right {
      top: 70px;
      right: 15px;
      font-size: 32px;
      color: #FFF;
      cursor: pointer;
    }


    .post-show .image {
      width: 100%;
      object-fit: cover;
      padding: 0;
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
  }
</style>

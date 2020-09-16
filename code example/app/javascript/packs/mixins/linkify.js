export const linkify = {
  methods: {
    likifyInstagram: function(text) {
      if (text !== null) {
        return text.replace(/@([\w]+)/g, '<a href="https://www.instagram.com/$1" target="_blank">@$1</a>')
                   .replace(/#([\w]+)/g, '<a href="https://www.instagram.com/explore/tags/$1" target="_blank">#$1</a>')
      }
    }
  }
}

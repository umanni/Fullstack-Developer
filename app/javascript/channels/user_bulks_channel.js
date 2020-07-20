import consumer from "./consumer"

consumer.subscriptions.create("UserBulksChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    data.user_bulks.forEach(function (user_bulk) {
      $("#user_bulk_state_id_" + user_bulk.id).html(user_bulk.state);
      $("#user_bulk_state_id_" + user_bulk.id).removeClass().addClass("badge badge-pill badge-" + user_bulk.state)
    })
  },

  test: function() {
    return this.perform('test');
  }
});
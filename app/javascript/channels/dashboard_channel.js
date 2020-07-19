import consumer from "./consumer"

consumer.subscriptions.create("DashboardChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    $("#total_number_of_users").html(data.total_number_of_users)
    Object.keys(data.total_number_of_users_grouped).forEach(function (key, index){
      $("#" + key).html(Object.values(data.total_number_of_users_grouped)[index])
    })
  },

  test: function() {
    return this.perform('test');
  }
});
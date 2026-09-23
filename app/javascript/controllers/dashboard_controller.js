import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["total", "admins", "nonAdmins"]
  static values = {
    total: Number,
    admins: Number,
    nonAdmins: Number
  }

  connect() {
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create("DashboardChannel", {
      received: (data) => this.updateStats(data)
    })
  }

  disconnect() {
    this.subscription?.unsubscribe()
    this.consumer?.disconnect()
  }

  updateStats(data) {
    if (data.type !== "stats") return
    this.totalTarget.textContent = data.total
    this.adminsTarget.textContent = data.admins
    this.nonAdminsTarget.textContent = data.non_admins
  }
}

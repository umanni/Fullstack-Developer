import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["status", "percentLabel", "bar", "processed", "success", "failure", "error"]
  static values = {
    id: Number,
    status: String,
    percent: Number,
    processed: Number,
    total: Number,
    success: Number,
    failure: Number
  }

  connect() {
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "ImportChannel", id: this.idValue },
      { received: (data) => this.render(data) }
    )
  }

  disconnect() {
    this.subscription?.unsubscribe()
    this.consumer?.disconnect()
  }

  render(data) {
    const labels = {
      pending: "pendente",
      processing: "processando",
      completed: "concluída",
      failed: "falhou"
    }
    this.statusTarget.textContent = labels[data.status] || data.status
    this.percentLabelTarget.textContent = `${data.progress_percent}%`
    this.barTarget.style.width = `${data.progress_percent}%`
    this.processedTarget.textContent = `${data.processed_rows}/${data.total_rows}`
    this.successTarget.textContent = data.success_count
    this.failureTarget.textContent = data.failure_count

    if (data.error_message) {
      this.errorTarget.textContent = data.error_message
      this.errorTarget.classList.remove("hidden")
    }
  }
}

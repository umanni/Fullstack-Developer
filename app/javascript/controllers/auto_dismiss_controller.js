import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.element.style.transition = "opacity 300ms ease"
      this.element.style.opacity = "0"
      setTimeout(() => this.element.remove(), 320)
    }, 4500)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}

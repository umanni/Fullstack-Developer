import { Controller } from "@hotwired/stimulus"

// Briefly highlights an element whenever it is replaced by a Turbo Stream
// broadcast, so a "real-time" update (dashboard counts, import progress) is
// actually noticeable.
export default class extends Controller {
  static classes = ["highlight"]

  connect() {
    this.element.classList.add(...this.highlightClasses)
    this.timeout = setTimeout(() => {
      this.element.classList.remove(...this.highlightClasses)
    }, 700)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 3000 }
  }

  connect() {
    if (this.hasDelayValue) {
      setTimeout(() => {
        this.remove()
      }, this.delayValue)
    }
  }

  remove() {
    this.element.remove()
  }
}

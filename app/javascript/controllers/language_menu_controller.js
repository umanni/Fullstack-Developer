import { Controller } from "@hotwired/stimulus"

// <details> opens and closes on its own. What it does not do is close when the
// person's attention moves on, which is what a menu is expected to do.
export default class extends Controller {
  connect() {
    this.closeOnOutsideEvent = this.closeOnOutsideEvent.bind(this)
  }

  disconnect() {
    this.stopWatching()
  }

  // Watch only while open: a listener on every click of every page, to close a
  // menu that is already closed, is a listener not worth installing.
  toggled() {
    this.element.open ? this.startWatching() : this.stopWatching()
  }

  close() {
    this.element.open = false
    this.stopWatching()
  }

  closeOnOutsideEvent(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  startWatching() {
    document.addEventListener("click", this.closeOnOutsideEvent)
    document.addEventListener("focusin", this.closeOnOutsideEvent)
  }

  stopWatching() {
    document.removeEventListener("click", this.closeOnOutsideEvent)
    document.removeEventListener("focusin", this.closeOnOutsideEvent)
  }
}

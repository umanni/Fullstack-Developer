import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

  toggle() {
    this.menuTarget.classList.toggle("-translate-x-full")
    this.overlayTarget.classList.toggle("hidden")
  }

  close() {
    this.menuTarget.classList.add("-translate-x-full")
    this.overlayTarget.classList.add("hidden")
  }
}

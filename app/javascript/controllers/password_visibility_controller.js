import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  toggle(event) {
    const type = event.currentTarget.checked ? "text" : "password"
    this.inputTargets.forEach((input) => { input.type = type })
  }
}

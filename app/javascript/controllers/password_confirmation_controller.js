import { Controller } from "@hotwired/stimulus"

// Gives immediate feedback when the confirmation field doesn't match the
// password field yet, since HTML5 has no built-in cross-field validation.
export default class extends Controller {
  static targets = ["password", "confirmation"]

  validate() {
    const mismatch = this.confirmationTarget.value.length > 0 && this.confirmationTarget.value !== this.passwordTarget.value
    this.confirmationTarget.setCustomValidity(mismatch ? "As senhas não coincidem" : "")
  }
}

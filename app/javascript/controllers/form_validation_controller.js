import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fullName", "fullNameError",
    "email", "emailError",
    "password", "passwordConfirmation", "passwordError"
  ]

  validate() {
    this.toggle(this.fullNameErrorTarget, this.fullNameTarget.value.trim().length === 0)
    this.toggle(this.emailErrorTarget, !this.validEmail(this.emailTarget.value))

    const password = this.passwordTarget.value
    const confirmation = this.passwordConfirmationTarget.value
    const passwordInvalid = password.length > 0 && (password.length < 8 || password !== confirmation)
    this.toggle(this.passwordErrorTarget, passwordInvalid)
  }

  validEmail(value) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
  }

  toggle(el, show) {
    el.classList.toggle("hidden", !show)
  }
}

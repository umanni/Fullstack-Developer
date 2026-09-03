import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "error"]

  validate(event) {
    let valid = true

    this.fieldTargets.forEach((field) => {
      const rules = (field.dataset.validate || "").split(" ")
      const error = this.errorTargets.find((el) => el.dataset.for === field.name.replace("user[", "").replace("]", ""))
      const value = field.value.trim()
      let fieldValid = true

      if (rules.includes("presence") && !value) fieldValid = false
      if (rules.includes("length") && value && (value.length < 2 || value.length > 120)) fieldValid = false
      if (rules.includes("email") && value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) fieldValid = false
      if (rules.includes("password") && value.length < 8) fieldValid = false
      if (rules.includes("optional_password") && value && value.length < 8) fieldValid = false
      if (rules.includes("optional_url") && value && !/^https?:\/\/.+/i.test(value)) fieldValid = false

      if (error) error.classList.toggle("hidden", fieldValid)
      field.classList.toggle("border-rose-400", !fieldValid)
      if (!fieldValid) valid = false
    })

    if (event.type === "submit" && !valid) {
      event.preventDefault()
    }
  }
}

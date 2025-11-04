import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // Optional: initial validation state
  }

  validate(event) {
    const input = event.target
    const value = input.value || ""

    let message = null

    if (input.required && value.trim() === "") {
      message = "Campo obrigatório"
    } else if (input.type === "email" && value && !/^\S+@\S+\.\S+$/.test(value)) {
      message = "Formato de e-mail inválido"
    } else if (input.dataset.minlength) {
      const min = parseInt(input.dataset.minlength, 10)
      if (value.length > 0 && value.length < min) {
        message = `Mínimo de ${min} caracteres`
      }
    }

    this.setErrorFor(input, message)
  }

  setErrorFor(input, message) {
    const errorEl = this.errorElementFor(input)

    if (message) {
      input.classList.add('field-with-errors')
      input.setAttribute('aria-invalid', 'true')
      if (errorEl) {
        errorEl.textContent = message
        errorEl.style.display = 'block'
        input.setAttribute('aria-describedby', errorEl.id)
      }
    } else {
      input.classList.remove('field-with-errors')
      input.removeAttribute('aria-invalid')
      if (errorEl) {
        errorEl.textContent = ''
        errorEl.style.display = 'none'
        input.removeAttribute('aria-describedby')
      }
    }
  }

  errorElementFor(input) {
    // Look for an explicit error container with attribute data-form-validation-error-for
    const selector = `[data-form-validation-error-for="${input.name}"]`
    const explicit = this.element.querySelector(selector)
    if (explicit) return explicit

    // fallback: check next sibling
    const next = input.nextElementSibling
    if (next && next.classList.contains('error-message')) return next

    return null
  }

  onSubmit(event) {
    // Validate all inputs; block submit if any invalid
    let invalid = false
    this.inputTargets.forEach((input) => {
      const ev = { target: input }
      this.validate(ev)
      if (input.classList.contains('field-with-errors')) invalid = true
    })

    if (invalid) {
      event.preventDefault()
      const first = this.element.querySelector('.field-with-errors')
      if (first) first.focus()
    }
  }
}

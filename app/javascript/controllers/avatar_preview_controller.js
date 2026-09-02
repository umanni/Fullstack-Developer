import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "file", "image", "message", "url"]

  disconnect() {
    this.revokeObjectUrl()
  }

  fileChanged() {
    const file = this.fileTarget.files[0]
    if (!file) {
      this.fileTarget.setCustomValidity("")
      this.revokeObjectUrl()
      this.urlTarget.value.length > 0 ? this.urlChanged() : this.hidePreview()
      return
    }

    const validType = ["image/jpeg", "image/png", "image/webp"].includes(file.type)
    const validSize = file.size <= 5 * 1024 * 1024
    this.fileTarget.setCustomValidity(validType && validSize ? "" : "Choose a JPEG, PNG, or WebP image smaller than 5 MB.")
    if (!validType || !validSize) {
      this.hidePreview()
      return
    }

    this.revokeObjectUrl()
    this.objectUrl = URL.createObjectURL(file)
    this.show(this.objectUrl, "Local image selected")
  }

  urlChanged() {
    if (this.urlTarget.value.length === 0) {
      this.urlTarget.setCustomValidity("")
      if (!this.fileTarget.files[0]) this.hidePreview()
      return
    }

    try {
      const url = new URL(this.urlTarget.value)
      const valid = url.protocol === "https:" && !url.username && !url.password
      this.urlTarget.setCustomValidity(valid ? "" : "Use a public HTTPS URL without embedded credentials.")
      if (valid && !this.fileTarget.files[0]) {
        this.revokeObjectUrl()
        this.show(url.href, "Remote image selected")
      } else if (!valid) {
        this.hidePreview()
      }
    } catch (_error) {
      this.urlTarget.setCustomValidity("Enter a valid HTTPS URL.")
      this.hidePreview()
    }
  }

  show(source, message) {
    this.imageTarget.classList.remove("hidden")
    this.imageTarget.src = source
    this.messageTarget.textContent = message
    this.containerTarget.classList.remove("hidden")
    this.containerTarget.classList.add("flex")
  }

  imageFailed() {
    this.imageTarget.classList.add("hidden")
    this.messageTarget.textContent = "Preview unavailable — verify that the image is public."
  }

  hidePreview() {
    this.containerTarget.classList.add("hidden")
    this.containerTarget.classList.remove("flex")
    this.imageTarget.removeAttribute("src")
  }

  revokeObjectUrl() {
    if (!this.objectUrl) return

    URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = null
  }
}

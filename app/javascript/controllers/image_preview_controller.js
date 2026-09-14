import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "current"]

  show() {
    const [file] = this.inputTarget.files
    this.#releaseUrl()

    if (!file) return this.#showCurrent()

    this.url = URL.createObjectURL(file)
    this.previewTarget.src = this.url
    this.previewTarget.hidden = false
    this.currentTarget.hidden = true
  }

  // Turbo restores cached pages, so a revoked object URL would come back as a broken
  // image unless the preview is torn down here too.
  disconnect() {
    this.#releaseUrl()
    this.#showCurrent()
  }

  #showCurrent() {
    this.previewTarget.hidden = true
    this.previewTarget.removeAttribute("src")
    this.currentTarget.hidden = false
  }

  #releaseUrl() {
    if (this.url) URL.revokeObjectURL(this.url)
    this.url = null
  }
}

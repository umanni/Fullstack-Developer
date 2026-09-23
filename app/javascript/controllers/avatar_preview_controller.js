import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["url", "preview", "placeholder"]

  connect() {
    this.refresh()
  }

  refresh() {
    const url = this.urlTarget.value.trim()
    if (!url) {
      this.previewTarget.classList.add("hidden")
      this.previewTarget.removeAttribute("src")
      this.placeholderTarget.classList.remove("hidden")
      return
    }

    this.previewTarget.src = url
    this.previewTarget.classList.remove("hidden")
    this.placeholderTarget.classList.add("hidden")
  }

  onError() {
    this.previewTarget.classList.add("hidden")
    this.placeholderTarget.classList.remove("hidden")
  }
}

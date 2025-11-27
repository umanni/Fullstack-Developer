import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="application"
export default class extends Controller {
  connect() {
    console.log('Application controller connected')
  }
}


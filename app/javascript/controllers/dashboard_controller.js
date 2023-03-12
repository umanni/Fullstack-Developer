import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dashboard"
export default class DashboardController extends Controller {
  static targets = ["users_list"];

}

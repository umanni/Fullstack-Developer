// Import and register all your controllers from the import map under controllers/*

import { application } from 'application'

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'
eagerLoadControllersFrom(__dirname, application)


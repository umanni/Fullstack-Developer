// This entry point is the starting point for your application.
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

// Global functions for alerts
window.showAlert = function(message, type = 'success') {
  const alertDiv = document.createElement('div')
  alertDiv.className = `alert alert-${type} alert-dismissible fade show`
  alertDiv.setAttribute('role', 'alert')
  alertDiv.innerHTML = `
    ${message}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  `
  
  const container = document.querySelector('.container, .container-fluid, main')
  if (container) {
    container.insertBefore(alertDiv, container.firstChild)
  } else {
    document.body.insertBefore(alertDiv, document.body.firstChild)
  }
  
  // Auto dismiss after 5 seconds
  setTimeout(() => {
    if (alertDiv.parentNode) {
      alertDiv.remove()
    }
  }, 5000)
}

// Global function for dropdowns
window.initializeDropdowns = function() {
  // Bootstrap 5 dropdowns are initialized automatically, but we can add custom logic here if needed
  const dropdowns = document.querySelectorAll('.dropdown-toggle')
  dropdowns.forEach(dropdown => {
    dropdown.addEventListener('click', function(e) {
      // Bootstrap handles this automatically, but we can add custom behavior
    })
  })
}

// Initialize on page load
document.addEventListener("turbo:load", function() {
  initializeDropdowns()
})

// Initialize alerts
function initializeAlerts() {
  const alerts = document.querySelectorAll('.alert')
  alerts.forEach(alert => {
    // Auto-dismiss alerts after 5 seconds
    setTimeout(() => {
      if (alert.parentNode) {
        const bsAlert = new bootstrap.Alert(alert)
        bsAlert.close()
      }
    }, 5000)
  })
}

// Initialize alerts when Turbo loads
document.addEventListener("turbo:load", function() {
  initializeAlerts()
})

// Inicializa alerts no carregamento inicial
if (document.readyState === 'loading') {
  document.addEventListener("DOMContentLoaded", initializeAlerts)
} else {
  setTimeout(initializeAlerts, 100)
}

// Atualiza texto do file input para inglês
function updateFileInputText(input) {
  const textSpan = input.parentElement && input.parentElement.querySelector('.file-input-english-text')
  if (!textSpan) return
  
  if (input.files && input.files.length > 0) {
    const fileName = input.files[0].name
    textSpan.textContent = fileName
    textSpan.style.color = '#212529'
    textSpan.title = fileName // Tooltip com nome completo do arquivo
  } else {
    textSpan.textContent = 'No file chosen'
    textSpan.style.color = '#6c757d'
    textSpan.title = ''
  }
}

// Inicializar textos quando página carregar
function initFileInputs() {
  document.querySelectorAll('input[type="file"].form-control').forEach(input => {
    // Verificar se já tem listener
    if (input.dataset.listenerAttached === 'true') return
    
    // Marcar como tendo listener
    input.dataset.listenerAttached = 'true'
    
    // Atualizar estado inicial
    updateFileInputText(input)
    
    // Adicionar listener para mudanças
    input.addEventListener('change', function() {
      updateFileInputText(this)
    })
  })
}

// Função para inicializar quando necessário
function setupFileInputs() {
  initFileInputs()
}

// Inicializar quando página carregar
document.addEventListener("turbo:load", setupFileInputs)
document.addEventListener("turbo:render", setupFileInputs)
document.addEventListener("turbo:frame-load", setupFileInputs)

if (document.readyState === 'loading') {
  document.addEventListener("DOMContentLoaded", setupFileInputs)
} else {
  // Executar imediatamente
  setTimeout(setupFileInputs, 100)
}

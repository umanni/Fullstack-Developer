# Importmap configuration
# Ensure importmap serves files directly from app/javascript, not through Sprockets
# This prevents Sprockets from trying to compile importmap files

Rails.application.config.importmap.sweep_cache = true


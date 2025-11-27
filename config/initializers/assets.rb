# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# This project uses importmap for JavaScript, not Sprockets
# Exclude JavaScript files from Sprockets to avoid conflicts with importmap
# Sprockets should only handle CSS files
Rails.application.config.assets.precompile.delete('application.js') if Rails.application.config.assets.precompile.include?('application.js')

# Prevent Sprockets from trying to compile importmap JavaScript files
# Importmap serves files directly from app/javascript, not through Sprockets
Rails.application.config.assets.paths.delete(Rails.root.join('app/javascript').to_s) if Rails.application.config.assets.paths.include?(Rails.root.join('app/javascript').to_s)


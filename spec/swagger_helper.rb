require "rails_helper"

# The OpenAPI document is generated from the specs that exercise the API, so it
# cannot describe an endpoint the application does not have, or a field it does
# not return. `bin/rails rswag:specs:swaggerize` writes swagger/v1/swagger.yaml,
# and CI regenerates it and fails if the committed copy has drifted.
RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s
  config.openapi_format = :yaml

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Roster API",
        version: "v1",
        description: <<~TEXT
          The JSON side of Roster.

          Authentication is a bearer token: POST an email address and password
          to /api/v1/tokens and send the token back as
          `Authorization: Bearer <token>`. The token is signed rather than
          stored, lasts 24 hours, and is invalidated by a password change.

          Everything under /api/v1/users requires an administrator.
        TEXT
      },
      servers: [
        { url: "http://localhost:3000", description: "Development" },
        { url: "https://{host}", description: "Deployment",
          variables: { host: { default: "roster.example.com" } } }
      ],
      components: {
        securitySchemes: {
          bearer_auth: { type: :http, scheme: :bearer, bearerFormat: "signed token" }
        },
        schemas: {
          user: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              full_name: { type: :string, example: "Ada Lovelace" },
              email_address: { type: :string, format: :email, example: "ada@example.com" },
              role: { type: :string, enum: %w[user admin] },
              locale: { type: :string, enum: User::SUPPORTED_LOCALES },
              avatar_url: { type: :string, nullable: true },
              created_at: { type: :string, format: :"date-time" },
              updated_at: { type: :string, format: :"date-time" }
            },
            required: %w[id full_name email_address role locale]
          },
          pagination: {
            type: :object,
            properties: {
              page: { type: :integer }, pages: { type: :integer },
              count: { type: :integer }, limit: { type: :integer }
            },
            required: %w[page pages count limit]
          },
          error: {
            type: :object,
            properties: {
              error: { type: :string, example: "unauthorized" },
              details: { type: :object, nullable: true }
            },
            required: %w[error]
          }
        }
      }
    }
  }
end

Rswag::Api.configure do |c|
  # Where `rswag:specs:swaggerize` writes the generated document, and where the
  # middleware reads it from to serve /api-docs/v1/swagger.yaml.
  c.openapi_root = Rails.root.join("swagger").to_s
end

Rswag::Ui.configure do |c|
  c.openapi_endpoint "/api-docs/v1/swagger.yaml", "Roster API v1"
end

# Swagger UI ships its own content security policy -- `script-src 'self'
# 'unsafe-inline'`, which is what its inline bootstrap needs. Ours is stricter
# and, because a browser enforces every policy it is sent, the two together
# forbid everything the page does: no nonce, no script, a blank screen.
#
# So the application's policy steps aside for that one mount, and Swagger UI's
# own policy governs it. Nothing of ours is served from there: the engine
# serves its static assets and the generated document, and the document is
# public by design.
class ApiDocsWithoutTheApplicationPolicy
  MOUNT = "/api-docs".freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    env["action_dispatch.content_security_policy"] = nil if documentation?(env)

    @app.call(env)
  end

  private

  def documentation?(env)
    path = env["PATH_INFO"].to_s
    path == MOUNT || path.start_with?("#{MOUNT}/")
  end
end

Rails.application.config.middleware.insert_before(
  ActionDispatch::ContentSecurityPolicy::Middleware,
  ApiDocsWithoutTheApplicationPolicy
)

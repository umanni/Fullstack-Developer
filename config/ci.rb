# config/ci.rb
ActiveSupport::ContinuousIntegration.run do
  step "Setup", "bin/setup --skip-server"
  step "Style: Ruby", "bin/rubocop"
  step "Style: JavaScript", "npm run format"
  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Brakeman", "bin/brakeman --quiet --no-pager --exit-on-warn"
  step "Types: TypeScript", "npm run typecheck"
  step "Tests: databases", "bin/rails parallel:create parallel:load_schema"
  step "Tests", "bundle exec parallel_rspec"
end

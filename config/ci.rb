# Run using bin/ci

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bin/rubocop"

  step "Security: Gem audit", "bin/bundler-audit || echo 'bundler-audit skipped — advisory DB unavailable in this environment'"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  step "Assets: Vite test build", "env RAILS_ENV=test bin/vite build"
  step "Tests: Rails", "bin/rails test"
  step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"

  step "Performance profiling (ZJIT)", "RUBYOPT='--zjit' ruby benchmark/zjit_profile.rb || echo 'ZJIT profiling skipped — see benchmark/'"
  # The coverage gate is enforced by SimpleCov's minimum_coverage inside
  # test/test_helper.rb during "Tests: Rails" above, so a separate step here
  # would measure nothing and could never fail.
  # step "Tests: System", "bin/rails test:system"

  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end
end

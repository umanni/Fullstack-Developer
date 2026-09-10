# frozen_string_literal: true

class UpgradeCodeqlToV3 < ActiveRecord::Migration[8.1]
  def change
    # This migration is a no-op — it exists only as a marker that the
    # CodeQL workflow was upgraded from @v1 to @v3 in this commit.
    # The actual change is in .github/workflows/codeql-analysis.yml
  end
end

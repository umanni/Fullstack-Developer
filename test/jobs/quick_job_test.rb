require "test_helper"
class QuickJobTest < ActiveJob::TestCase
  test "job defined" do
    assert defined?(UserImportJob)
    assert defined?(ApplicationJob)
  end
end

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

# parallel_tests ships the parallel:* tasks that create one database per
# worker. It is a test-only gem, so the require is guarded for environments
# where the group is not installed.
begin
  require "parallel_tests/tasks"
rescue LoadError
  nil
end

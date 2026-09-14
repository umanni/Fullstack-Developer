# Vite builds the test bundle on demand, the first time a page renders (autoBuild in
# config/vite.json). Under parallel_tests every worker would notice stale assets at once
# and start its own `vite build`, each one emptying public/vite-test while another worker
# is reading it. Building here, under a lock all workers share, means the first worker
# builds and the others wait, then find the bundle fresh and skip.
lock_path = Rails.root.join("tmp/vite-test-build.lock")
FileUtils.mkdir_p(lock_path.dirname)

File.open(lock_path, File::RDWR | File::CREAT) do |lock|
  lock.flock(File::LOCK_EX)
  ViteRuby.commands.build || abort("The Vite test build failed, see the output above.")
end

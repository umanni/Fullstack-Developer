class AvatarDownloadJob < ApplicationJob
  queue_as :default

  # AvatarFetcher::FetchError covers permanent failures (bad/blocked URL, unsupported
  # content type, oversized file) that a retry wouldn't fix, so it's discarded rather
  # than retried — Solid Queue still records the discard instead of it being silently
  # swallowed by an ad hoc rescue.
  discard_on AvatarFetcher::FetchError do |job, error|
    user_id, url = job.arguments
    Rails.logger.warn("AvatarDownloadJob: failed to fetch avatar for user #{user_id} from #{url}: #{error.message}")
  end

  def perform(user_id, url)
    user = User.find_by(id: user_id)
    return unless user

    result = AvatarFetcher.new(url).fetch
    user.avatar.attach(io: result.io, filename: result.filename, content_type: result.content_type)
  end
end

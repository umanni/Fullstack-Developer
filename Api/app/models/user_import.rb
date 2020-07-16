class UserImport < ApplicationRecord
  mount_uploader :attachment, AttachmentUploader
end

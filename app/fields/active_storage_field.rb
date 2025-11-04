require "administrate/field/base"

class ActiveStorageField < Administrate::Field::Base
  def to_s
    data.attached? ? data.filename.to_s : ""
  end
end

# frozen_string_literal: true

module Helpers
  module ImageUpload
    extend ActionDispatch::TestProcess

    module_function

    def image_name
      'test_image.png'
    end

    def file_path
      Rails.root.join('spec', 'fixtures', 'images', image_name)
    end

    def fixture_image
      fixture_file_upload(file_path, 'image/png')
    end
  end
end

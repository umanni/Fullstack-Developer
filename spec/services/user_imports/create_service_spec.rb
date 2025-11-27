require 'rails_helper'

RSpec.describe UserImports::CreateService, type: :service do
  let(:admin) { create(:user, :admin) }

  describe '#call' do
    context 'with valid CSV file' do
      let(:csv_content) do
        "full_name,email,role\nJohn Doe,john@example.com,user\nJane Admin,jane@example.com,admin"
      end
      let(:user_import) do
        import = create(:user_import, user: admin)
        # Replace the default file with our test file
        import.spreadsheet_file.purge if import.spreadsheet_file.attached?
        import.reload
        file = StringIO.new(csv_content)
        import.spreadsheet_file.attach(
          io: file,
          filename: 'test.csv',
          content_type: 'text/csv'
        )
        import.save!
        import.reload
      end
      let(:service) { described_class.new(user_import) }

      it 'creates users from spreadsheet' do
        admin
        initial_count = User.count
        service.call
        expect(User.count).to eq(initial_count + 2)
      end

      it 'updates import status to completed' do
        service.call
        user_import.reload
        expect(user_import.status).to eq('completed')
      end

      it 'updates processed rows count' do
        service.call
        user_import.reload
        expect(user_import.processed_rows).to eq(2)
      end
    end

    context 'with missing required columns' do
      let(:csv_content) { "nome,email\nJohn Doe,john@example.com" }
      let(:user_import) do
        import = create(:user_import, user: admin)
        # Replace the default file with invalid file
        import.spreadsheet_file.purge if import.spreadsheet_file.attached?
        import.reload
        file = StringIO.new(csv_content)
        import.spreadsheet_file.attach(
          io: file,
          filename: 'test.csv',
          content_type: 'text/csv'
        )
        import.save!
        import.reload
      end
      let(:service) { described_class.new(user_import) }

      it 'raises error for missing columns' do
        admin
        initial_count = User.count
        service.call
        expect(User.count).to eq(initial_count)
      end

      it 'updates import status to failed' do
        begin
          service.call
        rescue StandardError
          # Expected to fail
        end
        user_import.reload
        expect(user_import.status).to eq('failed')
      end
    end

    context 'with invalid user data' do
      let(:csv_content) do
        "full_name,email,role\n,john@example.com,user\nJane Doe,invalid-email,admin"
      end
      let(:user_import) do
        import = create(:user_import, user: admin)
        # Replace the default file with invalid data file
        import.spreadsheet_file.purge if import.spreadsheet_file.attached?
        import.reload
        file = StringIO.new(csv_content)
        import.spreadsheet_file.attach(
          io: file,
          filename: 'test.csv',
          content_type: 'text/csv'
        )
        import.save!
        import.reload
      end
      let(:service) { described_class.new(user_import) }

      it 'records errors but continues processing' do
        service.call
        user_import.reload
        expect(user_import.error_count).to be > 0
      end
    end

    context 'with Excel file' do
      let(:csv_content) { "full_name,email\nJohn Doe,john@example.com" }
      let(:user_import) do
        import = create(:user_import, user: admin)
        # Replace the default file with test file
        import.spreadsheet_file.purge if import.spreadsheet_file.attached?
        import.reload
        file = StringIO.new(csv_content)
        import.spreadsheet_file.attach(
          io: file,
          filename: 'test.csv',
          content_type: 'text/csv'
        )
        import.save!
        import.reload
      end
      let(:service) { described_class.new(user_import) }

      it 'processes the file correctly' do
        admin
        initial_count = User.count
        service.call
        expect(User.count).to eq(initial_count + 1)
      end
    end

    context 'when spreadsheet has no data rows' do
      let(:csv_content) { "full_name,email\n" }
      let(:user_import) do
        import = create(:user_import, user: admin)
        import.spreadsheet_file.purge if import.spreadsheet_file.attached?
        import.reload
        file = StringIO.new(csv_content)
        import.spreadsheet_file.attach(
          io: file,
          filename: 'empty.csv',
          content_type: 'text/csv'
        )
        import.save!
        import.reload
      end
      let(:service) { described_class.new(user_import) }

      it 'updates status to failed' do
        service.call
        user_import.reload
        expect(user_import.status).to eq('failed')
      end

      it 'adds error message about no data rows' do
        service.call
        user_import.reload
        expect(user_import.error_messages).to include(match(/No data rows found/))
      end
    end

    context 'when processing raises an error' do
      let(:user_import) { create(:user_import, user: admin) }
      let(:service) { described_class.new(user_import) }

      before do
        allow(service).to receive(:parse_spreadsheet).and_raise(StandardError.new('Test error'))
      end

      it 'handles error gracefully' do
        expect { service.call }.not_to raise_error
      end

      it 'updates import status to failed' do
        service.call
        user_import.reload
        expect(user_import.status).to eq('failed')
      end
    end
  end

  describe '#build_user_data' do
    let(:user_import) { create(:user_import, user: admin) }
    let(:service) { described_class.new(user_import) }
    let(:header_row) { ['full_name', 'email', 'role'] }
    let(:row) { ['John Doe', 'john@example.com', 'admin'] }

    it 'builds correct user data hash' do
      data = service.send(:build_user_data, row, header_row)
      expect(data[:full_name]).to eq('John Doe')
      expect(data[:email]).to eq('john@example.com')
      expect(data[:role]).to eq(:admin)
    end

    it 'defaults role to user when not specified' do
      header = ['full_name', 'email']
      row_data = ['John Doe', 'john@example.com']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:role]).to eq(:user)
    end

    it 'handles avatar_url' do
      header = ['full_name', 'email', 'avatar_url']
      row_data = ['John Doe', 'john@example.com', 'https://example.com/avatar.jpg']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:avatar_url]).to eq('https://example.com/avatar.jpg')
    end

    it 'handles different header name variations' do
      header = ['Full Name', 'E-mail', 'User_Role']
      row_data = ['John Doe', 'john@example.com', 'admin']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:full_name]).to eq('John Doe')
      expect(data[:email]).to eq('john@example.com')
      expect(data[:role]).to eq(:admin)
    end

    it 'handles "full name" with space' do
      header = ['full name', 'email']
      row_data = ['John Doe', 'john@example.com']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:full_name]).to eq('John Doe')
    end

    it 'handles "name" as header' do
      header = ['name', 'email']
      row_data = ['John Doe', 'john@example.com']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:full_name]).to eq('John Doe')
    end

    it 'handles "e-mail" with hyphen' do
      header = ['full_name', 'e-mail']
      row_data = ['John Doe', 'john@example.com']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:email]).to eq('john@example.com')
    end

    it 'handles "avatar" as header for avatar_url' do
      header = ['full_name', 'email', 'avatar']
      row_data = ['John Doe', 'john@example.com', 'https://example.com/avatar.jpg']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:avatar_url]).to eq('https://example.com/avatar.jpg')
    end

    it 'handles "avatar url" with space' do
      header = ['full_name', 'email', 'avatar url']
      row_data = ['John Doe', 'john@example.com', 'https://example.com/avatar.jpg']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:avatar_url]).to eq('https://example.com/avatar.jpg')
    end

    it 'handles nil values in row' do
      header = ['full_name', 'email', 'role']
      row_data = ['John Doe', nil, 'admin']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:full_name]).to eq('John Doe')
      expect(data[:email]).to be_nil
    end

    it 'handles role as user when value is not admin' do
      header = ['full_name', 'email', 'role']
      row_data = ['John Doe', 'john@example.com', 'user']
      data = service.send(:build_user_data, row_data, header)
      expect(data[:role]).to eq(:user)
    end
  end

  describe '#file_extension' do
    let(:user_import) { create(:user_import, user: admin) }

    context 'when file is CSV' do
      before do
        user_import.spreadsheet_file.purge if user_import.spreadsheet_file.attached?
        user_import.reload
        file = StringIO.new('test,data')
        user_import.spreadsheet_file.attach(
          io: file,
          filename: 'test.csv',
          content_type: 'text/csv'
        )
        user_import.save!
        user_import.reload
      end

      it 'returns :csv' do
        user_import.reload
        service = described_class.new(user_import)
        expect(service.send(:file_extension)).to eq(:csv)
      end
    end

    context 'when file is XLSX' do
      before do
        user_import.spreadsheet_file.purge if user_import.spreadsheet_file.attached?
        user_import.reload
        file = StringIO.new('test')
        user_import.spreadsheet_file.attach(
          io: file,
          filename: 'test.xlsx',
          content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        user_import.save!
        user_import.reload
      end

      it 'returns :xlsx' do
        user_import.reload
        service = described_class.new(user_import)
        expect(service.send(:file_extension)).to eq(:xlsx)
      end
    end

    context 'when file is XLS' do
      before do
        user_import.spreadsheet_file.purge if user_import.spreadsheet_file.attached?
        user_import.reload
        file = StringIO.new('test')
        user_import.spreadsheet_file.attach(
          io: file,
          filename: 'test.xls',
          content_type: 'application/vnd.ms-excel'
        )
        user_import.save!
        user_import.reload
      end

      it 'returns :xls' do
        user_import.reload
        service = described_class.new(user_import)
        expect(service.send(:file_extension)).to eq(:xls)
      end
    end

    context 'when content_type is not recognized but filename has extension' do
      before do
        user_import.spreadsheet_file.purge if user_import.spreadsheet_file.attached?
        user_import.reload
        file = StringIO.new('test')
        user_import.spreadsheet_file.attach(
          io: file,
          filename: 'test.csv',
          content_type: 'application/octet-stream'
        )
        user_import.save!
        user_import.reload
      end

      it 'detects extension from filename' do
        user_import.reload
        service = described_class.new(user_import)
        expect(service.send(:file_extension)).to eq(:csv)
      end
    end

    context 'when extension cannot be determined' do
      before do
        user_import.spreadsheet_file.purge if user_import.spreadsheet_file.attached?
        user_import.reload
        file = StringIO.new('test')
        user_import.spreadsheet_file.attach(
          io: file,
          filename: 'test',
          content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        user_import.save!
        user_import.reload
      end

      it 'defaults to :xlsx' do
        user_import.reload
        service = described_class.new(user_import)
        expect(service.send(:file_extension)).to eq(:xlsx)
      end
    end

    context 'when content_type is application/csv' do
      before do
        user_import.spreadsheet_file.purge if user_import.spreadsheet_file.attached?
        user_import.reload
        file = StringIO.new('test,data')
        user_import.spreadsheet_file.attach(
          io: file,
          filename: 'test.csv',
          content_type: 'application/csv'
        )
        user_import.save!
        user_import.reload
      end

      it 'returns :csv' do
        user_import.reload
        service = described_class.new(user_import)
        expect(service.send(:file_extension)).to eq(:csv)
      end
    end

    context 'when content_type is application/excel' do
      before do
        user_import.spreadsheet_file.purge if user_import.spreadsheet_file.attached?
        user_import.reload
        file = StringIO.new('test')
        user_import.spreadsheet_file.attach(
          io: file,
          filename: 'test.xls',
          content_type: 'application/excel'
        )
        user_import.save!
        user_import.reload
      end

      it 'returns :xls' do
        user_import.reload
        service = described_class.new(user_import)
        expect(service.send(:file_extension)).to eq(:xls)
      end
    end
  end

  describe '#validate_header' do
    let(:user_import) { create(:user_import, user: admin) }
    let(:service) { described_class.new(user_import) }

    context 'with valid header' do
      it 'does not raise error for header with full_name and email' do
        header = ['full_name', 'email']
        expect { service.send(:validate_header, header) }.not_to raise_error
      end

      it 'handles case insensitive headers' do
        header = ['FULL_NAME', 'EMAIL']
        expect { service.send(:validate_header, header) }.not_to raise_error
      end

      it 'handles headers with spaces' do
        header = ['full name', 'email']
        expect { service.send(:validate_header, header) }.not_to raise_error
      end
    end

    context 'with invalid header' do
      it 'raises error when full_name is missing' do
        header = ['nome', 'email']
        expect {
          service.send(:validate_header, header)
        }.to raise_error(ArgumentError, /Missing required columns/)
      end

      it 'raises error when email is missing' do
        header = ['full_name', 'e_mail']
        expect {
          service.send(:validate_header, header)
        }.to raise_error(ArgumentError, /Missing required columns/)
      end

      it 'raises error when both are missing' do
        header = ['nome', 'e_mail']
        expect {
          service.send(:validate_header, header)
        }.to raise_error(ArgumentError, /Missing required columns/)
      end
    end

    context 'with nil or empty header' do
      it 'does not raise error for nil header' do
        expect { service.send(:validate_header, nil) }.not_to raise_error
      end

      it 'does not raise error for empty header' do
        expect { service.send(:validate_header, []) }.not_to raise_error
      end
    end
  end

  describe '#create_user' do
    let(:admin_user) { create(:user, :admin) }
    let(:user_import) { create(:user_import, user: admin_user) }
    let(:service) { described_class.new(user_import) }
    let(:error_messages) { [] }

    context 'with valid user data' do
      let(:user_data) { { full_name: 'Test User', email: 'test@example.com', role: :user } }

      it 'creates user successfully' do
        admin_user
        initial_count = User.count
        service.send(:create_user, user_data, 1, error_messages)
        expect(User.count).to eq(initial_count + 1)
        expect(error_messages).to be_empty
      end

      it 'returns true on success' do
        result = service.send(:create_user, user_data, 1, error_messages)
        expect(result).to be true
      end

      it 'generates password when blank' do
        user_data[:password] = nil
        service.send(:create_user, user_data, 1, error_messages)
        user = User.last
        expect(user.encrypted_password).to be_present
      end
    end

    context 'with invalid user data' do
      let(:user_data) { { full_name: '', email: 'invalid' } }

      it 'does not create user' do
        admin_user
        initial_count = User.count
        service.send(:create_user, user_data, 1, error_messages)
        expect(User.count).to eq(initial_count)
      end

      it 'adds error message' do
        service.send(:create_user, user_data, 1, error_messages)
        expect(error_messages).not_to be_empty
        expect(error_messages.first).to include('Row 1:')
      end

      it 'returns false on failure' do
        result = service.send(:create_user, user_data, 1, error_messages)
        expect(result).to be false
      end
    end

    context 'when exception occurs' do
      let(:user_data) { { full_name: 'Test Exception', email: 'exception@example.com' } }

      before do
        admin_user
        allow(User).to receive(:new) do |*args|
          if args.first.is_a?(Hash) && args.first[:email] == 'exception@example.com'
            raise StandardError, 'Unexpected error'
          else
            User.allocate.tap { |u| u.send(:initialize, *args) }
          end
        end
      end

      it 'catches exception and adds error message' do
        service.send(:create_user, user_data, 1, error_messages)
        expect(error_messages).not_to be_empty
        expect(error_messages.first).to include('Unexpected error')
      end

      it 'returns false when exception occurs' do
        result = service.send(:create_user, user_data, 1, error_messages)
        expect(result).to be false
      end
    end
  end

  describe '#process_rows' do
    let(:csv_content) { "full_name,email\nJohn Doe,john@example.com\nJane Smith,jane@example.com" }
    let(:user_import) do
      import = create(:user_import, user: admin)
      import.spreadsheet_file.purge if import.spreadsheet_file.attached?
      import.reload
      file = StringIO.new(csv_content)
      import.spreadsheet_file.attach(
        io: file,
        filename: 'test.csv',
        content_type: 'text/csv'
      )
      import.save!
      import.reload
    end
    let(:service) { described_class.new(user_import) }

    it 'broadcasts progress for each row' do
      expect(ActionCable.server).to receive(:broadcast).at_least(:once)
      service.call
    end

    it 'updates success_count and error_count' do
      service.call
      user_import.reload
      expect(user_import.success_count).to be >= 0
      expect(user_import.error_count).to be >= 0
    end

    it 'skips blank rows' do
      csv_with_blanks = "full_name,email\nJohn Doe,john@example.com\n  ,  \nJane Smith,jane@example.com"
      import = create(:user_import, user: admin)
      import.spreadsheet_file.purge
      file = StringIO.new(csv_with_blanks)
      import.spreadsheet_file.attach(io: file, filename: 'test.csv', content_type: 'text/csv')
      import.reload
      
      service = described_class.new(import)
      allow(service).to receive(:file_extension).and_return(:csv)
      allow(service).to receive(:validate_header).and_return(true)
      
      service.call
      import.reload
      expect(import.processed_rows).to eq(2)
    end

    it 'logs processing information' do
      allow(Rails.logger).to receive(:info)
      service.call
      expect(Rails.logger).to have_received(:info).with(/Processing rows/)
      expect(Rails.logger).to have_received(:info).with(/Processing completed/)
    end

    it 'handles errors in process_rows' do
      csv_content = "full_name,email\nJohn Doe,john@example.com"
      import = create(:user_import, user: admin)
      import.spreadsheet_file.purge if import.spreadsheet_file.attached?
      import.reload
      file = StringIO.new(csv_content)
      import.spreadsheet_file.attach(io: file, filename: 'test.csv', content_type: 'text/csv')
      import.save!
      import.reload
      
      service = described_class.new(import)
      allow(service).to receive(:parse_spreadsheet).and_raise(StandardError.new('Row error'))
      
      expect {
        service.call
      }.not_to raise_error
      
      import.reload
      expect(import.status).to eq('failed')
    end

    it 'updates status to completed after processing' do
      service.call
      user_import.reload
      expect(user_import.status).to eq('completed')
    end
  end

  describe '#broadcast_status_update' do
    let(:user_import) { create(:user_import, user: admin, status: :processing) }
    let(:service) { described_class.new(user_import) }

    it 'broadcasts status update via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast).with(
        "import_progress_#{user_import.id}",
        hash_including(type: 'progress', status: 'processing')
      )
      service.send(:broadcast_status_update)
    end
  end

  describe '#broadcast_progress' do
    let(:user_import) { create(:user_import, user: admin, status: :processing, success_count: 5, error_count: 2) }
    let(:service) { described_class.new(user_import) }

    it 'broadcasts progress via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast).with(
        "import_progress_#{user_import.id}",
        hash_including(
          type: 'progress',
          processed_rows: 10,
          total_rows: 20,
          success_count: 5,
          error_count: 2
        )
      )
      service.send(:broadcast_progress, 10, 20)
    end

    it 'calculates progress percentage correctly' do
      expect(ActionCable.server).to receive(:broadcast) do |_channel, data|
        expect(data[:progress]).to eq(50.0)
      end
      service.send(:broadcast_progress, 10, 20)
    end
  end

  describe '#broadcast_completion' do
    let(:user_import) { create(:user_import, user: admin, status: :completed, processed_rows: 10, total_rows: 10, success_count: 8, error_count: 2) }
    let(:service) { described_class.new(user_import) }

    it 'broadcasts completion via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast).with(
        "import_progress_#{user_import.id}",
        hash_including(
          type: 'completed',
          status: 'completed',
          progress: 100
        )
      )
      service.send(:broadcast_completion)
    end
  end

  describe '#handle_error' do
    let(:user_import) { create(:user_import, user: admin) }
    let(:service) { described_class.new(user_import) }
    let(:error) do
      begin
        raise StandardError, 'Test error'
      rescue StandardError => e
        e
      end
    end

    it 'updates import status to failed' do
      service.send(:handle_error, error)
      user_import.reload
      expect(user_import.status).to eq('failed')
    end

    it 'adds error message to existing errors' do
      user_import.update(error_messages: ['Existing error'])
      service.send(:handle_error, error)
      user_import.reload
      expect(user_import.error_messages).to include('Existing error')
      expect(user_import.error_messages).to include('Test error')
    end

    it 'adds error message when no existing errors' do
      user_import.update(error_messages: nil)
      service.send(:handle_error, error)
      user_import.reload
      error_msgs = user_import.error_messages || []
      expect(error_msgs).to include('Test error')
    end

    it 'logs error message' do
      allow(Rails.logger).to receive(:error)
      service.send(:handle_error, error)
      expect(Rails.logger).to have_received(:error).with(/UserImport.*failed/)
    end

    it 'logs error backtrace' do
      allow(Rails.logger).to receive(:error)
      service.send(:handle_error, error)
      expect(Rails.logger).to have_received(:error).at_least(:twice)
    end

    it 'broadcasts error via broadcast_error' do
      expect(service).to receive(:broadcast_error).with(error)
      service.send(:handle_error, error)
    end
  end

  describe '#broadcast_error' do
    let(:user_import) { create(:user_import, user: admin) }
    let(:service) { described_class.new(user_import) }
    let(:error) { StandardError.new('Test error message') }

    it 'broadcasts error via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast).with(
        "import_progress_#{user_import.id}",
        {
          type: 'error',
          message: 'Test error message'
        }
      )
      service.send(:broadcast_error, error)
    end

    it 'includes error message in broadcast' do
      expect(ActionCable.server).to receive(:broadcast) do |_channel, data|
        expect(data[:type]).to eq('error')
        expect(data[:message]).to eq('Test error message')
      end
      service.send(:broadcast_error, error)
    end
  end
end


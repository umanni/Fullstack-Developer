require 'rails_helper'

RSpec.describe UserImportJob, type: :job do
  let(:admin) { create(:user, :admin) }
  let(:user_import) { create(:user_import, user: admin) }

  describe '#perform' do
    it 'calls UserImports::CreateService' do
      service_double = instance_double(UserImports::CreateService)
      allow(UserImports::CreateService).to receive(:new).with(user_import).and_return(service_double)
      allow(service_double).to receive(:call)

      described_class.new.perform(user_import.id)
      expect(service_double).to have_received(:call)
    end

    it 'logs job start information' do
      allow(Rails.logger).to receive(:info)
      described_class.new.perform(user_import.id)
      expect(Rails.logger).to have_received(:info).at_least(:once)
    end

    it 'handles missing user import gracefully' do
      expect {
        described_class.new.perform(99999)
      }.not_to raise_error
    end

    it 'updates import status to failed on error' do
      allow(UserImports::CreateService).to receive(:new).and_raise(StandardError.new('Test error'))
      described_class.new.perform(user_import.id)
      user_import.reload
      expect(user_import.status).to eq('failed')
    end
  end
end


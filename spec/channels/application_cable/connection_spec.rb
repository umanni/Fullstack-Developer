require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }

  def create_test_connection(warden_user)
    connection = ApplicationCable::Connection.new(ActionCable.server, {
      'warden' => double('warden', user: warden_user)
    })
    connection
  end

  describe '#connect' do
    it 'connects with valid user via Warden' do
      connection = create_test_connection(user)
      
      expect {
        connection.connect
      }.not_to raise_error
      
      expect(connection.current_user).to eq(user)
    end

    it 'sets current_user when Warden has user' do
      connection = create_test_connection(user)
      connection.connect
      expect(connection.current_user).to eq(user)
    end
  end

  describe '#find_verified_user' do
    it 'returns user when Warden has user' do
      connection = create_test_connection(user)
      verified_user = connection.send(:find_verified_user)
      expect(verified_user).to eq(user)
    end

    it 'returns user when env has warden with user' do
      connection = create_test_connection(user)
      verified_user = connection.send(:find_verified_user)
      expect(verified_user).to eq(user)
    end

    it 'rejects connection when Warden user is nil' do
      connection = create_test_connection(nil)
      
      expect {
        connection.send(:find_verified_user)
      }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
    end

    it 'rejects connection when env has no warden' do
      connection = ApplicationCable::Connection.new(ActionCable.server, {})
      
      expect {
        connection.send(:find_verified_user)
      }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
    end

    it 'rejects connection when warden is nil' do
      connection = ApplicationCable::Connection.new(ActionCable.server, { 'warden' => nil })
      
      expect {
        connection.send(:find_verified_user)
      }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
    end

    it 'uses safe navigation operator when warden is nil' do
      connection = ApplicationCable::Connection.new(ActionCable.server, { 'warden' => nil })
      expect {
        connection.send(:find_verified_user)
      }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
    end

    it 'sets current_user through connect method' do
      connection = create_test_connection(user)
      connection.connect
      expect(connection.current_user).to eq(user)
    end

    it 'identifies connection by current_user' do
      connection = create_test_connection(user)
      connection.connect
      expect(connection.current_user).to be_present
    end
  end

  describe 'connection lifecycle' do
    it 'calls find_verified_user during connect' do
      connection = create_test_connection(user)
      expect(connection).to receive(:find_verified_user).and_call_original
      connection.connect
    end
  end

  describe 'identified_by' do
    it 'identifies connection by current_user' do
      connection = create_test_connection(user)
      connection.connect
      expect(connection.current_user).to eq(user)
      expect(connection).to respond_to(:current_user)
    end
  end

  describe 'complete connection flow' do
    it 'executes complete flow: connect -> find_verified_user -> set current_user' do
      connection = create_test_connection(user)
      connection.connect
      expect(connection.current_user).to eq(user)
    end

    it 'executes complete flow: connect -> find_verified_user -> reject' do
      connection = create_test_connection(nil)
      expect {
        connection.connect
      }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
    end

    it 'executes assignment in find_verified_user' do
      connection = create_test_connection(user)
      verified_user = connection.send(:find_verified_user)
      expect(verified_user).to eq(user)
      expect(verified_user).to be_present
    end

    it 'executes return statement in find_verified_user when user exists' do
      connection = create_test_connection(user)
      result = connection.send(:find_verified_user)
      expect(result).to eq(user)
    end
  end

  describe 'all lines execution' do
    it 'executes identified_by :current_user' do
      connection = create_test_connection(user)
      connection.connect
      expect(connection.current_user).to eq(user)
    end

    it 'executes connect method' do
      connection = create_test_connection(user)
      connection.connect
      expect(connection.current_user).to eq(user)
    end

    it 'executes private keyword' do
      expect(ApplicationCable::Connection.private_method_defined?(:find_verified_user)).to be true
    end

    it 'executes find_verified_user method definition' do
      connection = create_test_connection(user)
      expect(connection.private_methods.include?(:find_verified_user)).to be true
    end

    it 'executes if statement with assignment' do
      connection = create_test_connection(user)
      verified_user = connection.send(:find_verified_user)
      expect(verified_user).to eq(user)
    end

    it 'executes return verified_user' do
      connection = create_test_connection(user)
      result = connection.send(:find_verified_user)
      expect(result).to eq(user)
    end

    it 'executes else branch with reject_unauthorized_connection' do
      connection = create_test_connection(nil)
      expect {
        connection.send(:find_verified_user)
      }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
    end
  end
end


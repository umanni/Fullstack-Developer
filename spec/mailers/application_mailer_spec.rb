require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  it 'has default from email' do
    expect(ApplicationMailer.default[:from]).to be_present
  end

  it 'uses mail layout' do
    expect(ApplicationMailer._layout).to eq('mailer')
  end
end


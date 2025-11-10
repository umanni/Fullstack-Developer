require 'factory_bot_rails'

FactoryBot.create(:user, role: :admin, email: 'admin@email.com', password: '123456')
FactoryBot.create(:user, email: 'user@email.com', password: '123456')

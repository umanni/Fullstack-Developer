namespace :dev do
  desc "TODO"
  desc "Configura o ambiente de desenvolvimento"
  task setup: :environment do
    if Rails.env.development?
      %x(rails db:drop db:create db:migrate dev:add_default_user)
    else
      puts "Você não está em ambiente de desenvolvimento!"
    end
  end

  desc "Adiciona o usuário padrão"
  task add_default_user: :environment do
    users=[
        {
        email: 'adm@adm.com',
        password: 123456,
        password_confirmation: 123456,
        full_name: 'Adm',
        avatar_image: '',
        admin: true,
      },
      {
        email: 'user1@user.com',
        password: 123456,
        password_confirmation: 123456,
        full_name: 'User1',
        avatar_image: '',
        admin: false,
      },
      {
        email: 'user2@user.com',
        password: 123456,
        password_confirmation: 123456,
        full_name: 'User2',
        avatar_image: '',
        admin: false,

      }
    ]
    users.each do |user|

      User.create!(user)
    end

  end

end

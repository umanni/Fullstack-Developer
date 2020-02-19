# frozen_string_literal: true

User.create!(
  full_name: 'Admin Umanni',
  role: 1,
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password'
) if Rails.env.development?

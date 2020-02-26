# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 15, label: User.model_name.human(count: :many)

  permit_params :full_name, :email, :role, :password, :password_confirmation

  scope :all, default: true
  scope :non_admins
  scope :admins

  filter :full_name
  filter :email
  filter :role
  filter :current_sign_in_at
  filter :created_at

  index do
    selectable_column
    id_column
    column :full_name do |user|
      link_to user.full_name, admin_user_path(user)
    end
    column :email
    tag_column :role, interactive: true
    actions
  end

  show do
    attributes_table do
      row :full_name
      row :email
      row :role do |user|
        t(user.role, scope: 'activerecord.attributes.user.role')
      end
      row :current_sign_in_at
      row :sign_in_count
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :email
      f.input :role do |user|
        t(user.role, scope: 'activerecord.attributes.user.role')
      end
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    skip_before_action :verify_authenticity_token, only: :update

    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update : :update_without_password
      object.public_send(update_method, *attributes)
    end
  end
end

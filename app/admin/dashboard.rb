# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content do
    
    h2 "Admins: #{User.where(role: true).count}"
    h2 "Users: #{User.where(role: false).count}"
    h1 "Total: #{User.count}"
  end

end

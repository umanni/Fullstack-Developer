ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    panel t('users_count', scope: 'active_admin'),
      class: 'async-panel',
      'data-url' => counters_admin_users_path,
      'data-period' => 5.seconds
  end
end

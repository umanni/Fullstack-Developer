class AddLocaleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :locale, :string, null: false, default: "en"

    # The application ships three locales; anything else reaching the column
    # through a raw write would render a half-translated page.
    add_check_constraint :users, "locale IN ('en', 'pt-BR', 'es')",
                         name: "users_locale_supported"
  end
end

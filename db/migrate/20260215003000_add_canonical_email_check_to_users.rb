class AddCanonicalEmailCheckToUsers < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :users,
      "email = lower(email) AND email = btrim(email)",
      name: "users_email_canonical"
  end
end

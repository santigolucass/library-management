class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :genre, null: false
      t.string :isbn, null: false
      t.integer :total_copies, null: false, default: 0
      t.integer :available_copies, null: false, default: 0

      t.timestamps
    end

    add_index :books, :isbn, unique: true
    add_check_constraint :books, "total_copies >= 0", name: "books_total_copies_non_negative"
    add_check_constraint :books, "available_copies >= 0", name: "books_available_copies_non_negative"
    add_check_constraint :books, "available_copies <= total_copies", name: "books_available_within_total"
  end
end

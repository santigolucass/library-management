class CreateBorrowings < ActiveRecord::Migration[8.1]
  def change
    create_table :borrowings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.datetime :borrowed_at, null: false
      t.datetime :due_at, null: false
      t.datetime :returned_at

      t.timestamps
    end

    add_index :borrowings, :returned_at

    add_check_constraint :borrowings, "due_at > borrowed_at", name: "borrowings_due_after_borrowed"
    add_check_constraint :borrowings, "returned_at IS NULL OR returned_at >= borrowed_at", name: "borrowings_returned_after_borrowed"
  end
end

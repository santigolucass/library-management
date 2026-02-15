class AddActiveBorrowingUniquenessConstraint < ActiveRecord::Migration[8.1]
  def change
    add_index :borrowings, [ :user_id, :book_id ],
              unique: true,
              where: "returned_at IS NULL",
              name: "index_borrowings_on_user_and_book_when_active"

    add_index :borrowings, :due_at
  end
end

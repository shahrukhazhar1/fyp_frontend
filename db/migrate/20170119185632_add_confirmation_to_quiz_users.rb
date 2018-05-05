class AddConfirmationToQuizUsers < ActiveRecord::Migration
  def change
  	add_column :quiz_users, :confirmation_token, :string
  	add_column :quiz_users, :confirmed_at, :datetime
  	add_column :quiz_users, :confirmation_sent_at, :datetime
  	add_index :quiz_users, :confirmation_token,   unique: true
  end
end

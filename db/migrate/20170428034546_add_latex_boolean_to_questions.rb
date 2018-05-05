class AddLatexBooleanToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :latex, :boolean, default: false
  end
end

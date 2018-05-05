class AddLatexBooleanToAnswers < ActiveRecord::Migration
  def change
  	add_column :answers, :latex, :boolean, default: false
  end
end

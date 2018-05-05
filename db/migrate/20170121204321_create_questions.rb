class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
    	t.string  :text
    	t.string  :hint
    	t.text  :comment
      t.integer :priority
      t.integer :quiz_id
      t.timestamps
    end
  end
end

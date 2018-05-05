class AddGuideFilenameToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :guide_filename, :string
  end
end

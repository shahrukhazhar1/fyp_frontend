class AddPreviewUrlToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :question_guide_pdf_preview_url, :string
  end
end

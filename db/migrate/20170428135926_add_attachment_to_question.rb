class AddAttachmentToQuestion < ActiveRecord::Migration
  def change
  	add_column :questions, :attachment_url, :string
  end
end

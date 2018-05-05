class AddAttachmentToAnswer < ActiveRecord::Migration
  def change
  	add_column :answers, :attachment_url, :string
  end
end

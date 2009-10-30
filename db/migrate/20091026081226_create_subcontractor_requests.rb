class CreateSubcontractorRequests < ActiveRecord::Migration
  def self.up
    create_table :subcontractor_requests do |t|
      t.references :subcontractor, :survey_step
      t.text    :job_needed
      t.float   :price
      t.string  :attachment_file_name, :attachment_content_type
      t.integer :attachment_file_size
    end
  end

  def self.down
    drop_table :subcontractor_requests
  end
end

class AddExtractedTextToMedicalReports < ActiveRecord::Migration[7.1]
  def change
    add_column :medical_reports, :extracted_text, :text
  end
end

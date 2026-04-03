class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.string :file_name
      t.text :extracted_text
      t.json :findings
      t.json :possible_conditions
      t.json :biomarkers
      t.string :risk_level
      t.text :summary

      t.timestamps
    end
  end
end

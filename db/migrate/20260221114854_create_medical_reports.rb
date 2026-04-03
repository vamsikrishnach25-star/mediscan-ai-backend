class CreateMedicalReports < ActiveRecord::Migration[7.1]
  def change
    create_table :medical_reports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end

class AddAiAnalysisToMedicalReports < ActiveRecord::Migration[7.1]
  def change
    add_column :medical_reports, :ai_analysis, :jsonb
  end
end

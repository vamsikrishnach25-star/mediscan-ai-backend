class HealthDashboardService

  def self.generate

    reports = Report.all

    total_reports = reports.count

    high = reports.where(risk_level: "High").count
    moderate = reports.where(risk_level: "Moderate").count
    low = reports.where(risk_level: "Low").count

    latest_report = reports.order(created_at: :desc).first

    latest_health_score = latest_report&.summary ? latest_report.risk_level : nil

    trend_data = HealthTrendService.analyze(reports.order(created_at: :asc))

    {
      total_reports: total_reports,
      high_risk_reports: high,
      moderate_risk_reports: moderate,
      low_risk_reports: low,
      latest_risk_level: latest_report&.risk_level,
      trend: trend_data[:trend]
    }

  end

end
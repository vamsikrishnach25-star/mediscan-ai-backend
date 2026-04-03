class HealthTrendService

  RISK_SCORE = {
    "Low" => 1,
    "Moderate" => 2,
    "High" => 3,
    "Critical" => 4
  }

  def self.analyze(reports)

    history = reports.map do |report|
      {
        report_id: report.id,
        risk: report.risk_level
      }
    end

    scores = reports.map { |r| RISK_SCORE[r.risk_level] }.compact

    trend =
      if scores.last < scores.first
        "Improving"
      elsif scores.last > scores.first
        "Worsening"
      else
        "Stable"
      end

    {
      trend: trend,
      report_history: history
    }

  end

end
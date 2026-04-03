require "faraday"
require "json"

class AiMedicalAnalyzerService

  GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"

  def self.analyze(report_text)

    api_key = ENV["GROQ_API_KEY"]

    response = Faraday.post(GROQ_URL) do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["Authorization"] = "Bearer #{api_key}"

      req.body = {
        model: "llama-3.3-70b-versatile",
        messages: [
          {
            role: "user",
            content: "
Return ONLY JSON in this format:

{
  \"findings\": [],
  \"possible_conditions\": [],
  \"biomarkers\": {},
  \"risk_level\": \"\",
  \"summary\": \"\",
  \"recommendations\": []
}

Instructions:
- Identify abnormal biomarkers
- Suggest possible medical conditions
- Provide safe lifestyle or medical recommendations
- Recommendations must be general guidance, not prescriptions

Medical data:
#{report_text}
"
          }
        ]
      }.to_json
    end

    parsed = JSON.parse(response.body)

    content = parsed["choices"][0]["message"]["content"]

    cleaned = content.gsub(/```json|```/, "").strip

    analysis = JSON.parse(cleaned)
    analysis["biomarkers"] = analysis["biomarkers"].transform_values { |v| v.to_f if v }
    abnormal_markers = detect_abnormal_biomarkers(analysis["biomarkers"])

    analysis["abnormal_markers"] = abnormal_markers
    analysis["risk_level"] = calculate_risk(abnormal_markers)
    analysis["severity_score"] = abnormal_markers.length
    analysis["health_score"] = calculate_health_score(abnormal_markers)
    analysis["highlighted_biomarkers"] = highlight_biomarkers(analysis["biomarkers"])
    analysis["patient_summary"] = generate_patient_summary(analysis)

    analysis

  rescue StandardError => e
    { error: e.message }
  end


  def self.normalize_biomarker_value(name, value)

    numeric_value = value.to_f

    if name == "Total RBC count" && numeric_value > 20
      numeric_value = numeric_value / 10.0
    end

    if name == "Platelet Count" && numeric_value < 1000
      numeric_value = numeric_value * 1000
    end

    numeric_value
  end


  def self.detect_abnormal_biomarkers(biomarkers)

    normal_ranges = {
      "Hemoglobin (Hb)" => { min: 120, max: 170 },
      "Total RBC count" => { min: 4.5, max: 5.5 },
      "Packed Cell Volume (PCV)" => { min: 40, max: 50 },
      "Mean Corpuscular Volume (MCV)" => { min: 80, max: 100 },
      "Total WBC count" => { min: 4000, max: 11000 },
      "Platelet Count" => { min: 150000, max: 450000 }
    }

    abnormalities = []

    biomarkers.each do |marker, value|

      next unless normal_ranges[marker]

      range = normal_ranges[marker]

      numeric_value = normalize_biomarker_value(marker, value)

      if numeric_value < range[:min]
        abnormalities << "#{marker} LOW (#{numeric_value})"
      elsif numeric_value > range[:max]
        abnormalities << "#{marker} HIGH (#{numeric_value})"
      end
    end

    abnormalities
  end


  def self.calculate_risk(abnormal_markers)

    count = abnormal_markers.length

    return "Low" if count <= 1
    return "Moderate" if count <= 3
    return "High" if count <= 5

    "Critical"
  end


  def self.calculate_health_score(abnormal_markers)

    score = abnormal_markers.length * 20

    score = 100 if score > 100

    score
  end


  def self.highlight_biomarkers(biomarkers)

    ranges = {
      "Hemoglobin (Hb)" => { min: 120, max: 170 },
      "Total RBC count" => { min: 4.5, max: 5.5 },
      "Packed Cell Volume (PCV)" => { min: 40, max: 50 },
      "Mean Corpuscular Volume (MCV)" => { min: 80, max: 100 },
      "Total WBC count" => { min: 4000, max: 11000 },
      "Platelet Count" => { min: 150000, max: 450000 }
    }

    highlighted = []

    biomarkers.each do |name, value|

      next unless ranges[name]

      numeric_value = normalize_biomarker_value(name, value)

      status =
        if numeric_value < ranges[name][:min]
          "LOW"
        elsif numeric_value > ranges[name][:max]
          "HIGH"
        else
          "NORMAL"
        end

      highlighted << {
        name: name,
        value: numeric_value,
        status: status
      }
    end

    highlighted
  end

  def self.generate_patient_summary(analysis)

  findings = analysis["findings"] || []
  risk = analysis["risk_level"]
  score = analysis["health_score"]
  recommendations = analysis["recommendations"] || []

  {
    risk_level: risk,
    health_score: score,
    key_findings: findings,
    advice: recommendations.first
  }

  end

  def self.generate_patient_summary(analysis)

  findings = analysis["findings"] || []
  risk = analysis["risk_level"]
  score = analysis["health_score"]
  recommendations = analysis["recommendations"] || []

  {
    risk_level: risk,
    health_score: score,
    key_findings: findings,
    advice: recommendations.first
  }

  end

end
require "faraday"
require "json"

class GeminiService

  GEMINI_URL = "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent"

  def self.analyze(report_text)

    api_key = ENV["GEMINI_API_KEY"]

    response = Faraday.post("#{GEMINI_URL}?key=#{api_key}") do |req|

      req.headers["Content-Type"] = "application/json"

      req.body = {
        contents: [
          {
            parts: [
              {
                text: "Analyze this health report data and summarize the key observations:\n\n#{report_text}"
              }
            ]
          }
        ]
      }.to_json

    end

    parsed = JSON.parse(response.body)

    if parsed["error"]
      return {
        success: false,
        message: parsed["error"]["message"]
      }
    end

    {
      success: true,
      result: parsed
    }

  rescue StandardError => e
    {
      success: false,
      message: e.message
    }

  end
end
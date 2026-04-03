module Api
  module V1
    class ReportsController < ApplicationController

      def upload
        file = params[:file]   # ✅ FIXED

        if file.nil?
          Rails.logger.debug("PARAMS: #{params.inspect}") # debug
          return render json: { error: "No file uploaded" }, status: :bad_request
        end

        path = Rails.root.join("tmp", file.original_filename)

        File.open(path, "wb") do |f|
          f.write(file.read)
        end

        extracted_text = OcrService.extract_text(path)

        analysis = AiMedicalAnalyzerService.analyze(extracted_text)

        report = Report.create!(
          file_name: file.original_filename,
          extracted_text: extracted_text,
          findings: analysis["findings"],
          possible_conditions: analysis["possible_conditions"],
          biomarkers: analysis["biomarkers"],
          risk_level: analysis["risk_level"],
          summary: analysis["summary"]
        )

        render json: {
          message: "Report analyzed successfully",
          report_id: report.id,   # ✅ IMPORTANT (frontend needs this)
          analysis: analysis
        }
      end


      def index
        reports = Report.order(created_at: :desc)
        render json: reports
      end


      def show
        report = Report.find_by(id: params[:id])

        if report.nil?
          return render json: { error: "Report not found" }, status: :not_found
        end

        render json: report
      end


      def health_trend
        reports = Report.order(created_at: :asc)

        if reports.empty?
          return render json: { message: "No reports found" }
        end

        trend_analysis = HealthTrendService.analyze(reports)

        render json: trend_analysis
      end


      def dashboard
        dashboard_data = HealthDashboardService.generate
        render json: dashboard_data
      end

    end
  end
end
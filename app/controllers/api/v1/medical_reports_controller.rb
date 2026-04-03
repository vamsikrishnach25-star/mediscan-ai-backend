module Api
  module V1
    class MedicalReportsController < ApplicationController
      before_action :authorize_request

      def upload
        return render json: { error: "File is required" }, status: :unprocessable_entity unless params[:file]

        report = @current_user.medical_reports.new(status: "uploaded")
        report.report_file.attach(params[:file])

        if report.save
          # ---------------------------
          # OCR TEXT EXTRACTION
          # ---------------------------
          require 'rtesseract'

          file_path = ActiveStorage::Blob.service.path_for(report.report_file.key)
          extracted_text = RTesseract.new(file_path).to_s

          # ---------------------------
          # AI ANALYSIS
          # ---------------------------
          analysis = AiMedicalAnalyzerService.analyze(extracted_text)

          # ---------------------------
          # SAVE ANALYSIS TO DATABASE
          # ---------------------------
          report.update(
            ai_analysis: analysis,
            status: "analyzed"
          )

          render json: {
            message: "Medical report uploaded & analyzed",
            report_id: report.id,
            text: extracted_text,
            ai_analysis: analysis
          }, status: :created
        else
          render json: {
            errors: report.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # ---------------------------
      # GET ALL REPORTS
      # ---------------------------
      def index
        reports = @current_user.medical_reports.order(created_at: :desc)

        render json: reports.map { |report|
          {
            id: report.id,
            status: report.status,
            created_at: report.created_at,
            ai_analysis: report.ai_analysis
          }
        }
      end

      # ---------------------------
      # GET SINGLE REPORT
      # ---------------------------
      def show
        report = @current_user.medical_reports.find_by(id: params[:id])

        return render json: { error: "Report not found" }, status: :not_found unless report

        render json: {
          id: report.id,
          status: report.status,
          created_at: report.created_at,
          ai_analysis: report.ai_analysis
        }
      end

    end
  end
end
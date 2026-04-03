module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authorize_request

      def index
        render json: {
          message: "Welcome to MediScan Dashboard",
          user: {
            id: @current_user.id,
            name: @current_user.name,
            email: @current_user.email,
            role: @current_user.role
          }
        }
      end
    end
  end
end

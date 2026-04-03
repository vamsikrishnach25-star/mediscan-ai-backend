module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorize_request, only: [:login, :register]

      def register
        user = User.new(user_params)
        if user.save
          render json: { message: "User created successfully" }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])

        if user && user.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:name, :email, :password)
      end
    end
  end
end
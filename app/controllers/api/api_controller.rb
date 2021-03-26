module Api
  class ApiController < ApplicationController
    protect_from_forgery with: :null_session

    before_action :authenticate!

    rescue_from Api::AuthenticateError, with: :not_authenticated
    rescue_from ActiveRecord::RecordNotUnique, with: :unprocessable_entity
    rescue_from ActiveRecord::NotNullViolation, with: :unprocessable_entity
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    def current_user
      @current_user ||= User.find(decoded_token[:user_id])
    rescue ActiveRecord::RecordNotFound
      raise AuthenticateError
    end

    def authenticate!
      raise AuthenticateError unless decoded_token[:scope] == 'api'
    end

    def jwt_key
      ENV.fetch('SECRET_KEY_BASE')
    end

    def not_authenticated
      render plain: 'Not Authenticated', status: 401
    end

    def not_authorized
      render plain: 'Not Authorized', status: 403
    end

    def unprocessable_entity
      render plain: 'Unprocessable Entity', status: 422
    end

    def not_found
      render plain: 'Not Found', status: 404
    end
  end
end
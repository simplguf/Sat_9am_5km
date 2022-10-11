# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_request

  def create
    @user = User.new(user_params)
    @user.transaction do
      @user.skip_confirmation!
      @user.confirm
      @user.save!
      link_user_to_athlete
    end

    render json: { message: 'Регистрация успешно завершена.' }
  end

  def update
    @user = User.find(params[:user_id])
    @user.transaction do
      @user.update!(user_params)
      link_user_to_athlete
    end

    render json: { message: 'Участник успешно привязан.' }
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    Rails.logger.error e.inspect
    errors = {}
    errors[:user] = @user.errors.full_messages if @user.invalid?
    errors[:athlete] = @athlete.errors.full_messages if @athlete&.invalid?

    render json: { errors: errors }, status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name, :telegram_id, :telegram_user)
  end

  def athlete_params
    params.require(:athlete).permit(:name, :male, :parkrun_code, :fiveverst_code)
  end

  def authorize_request
    return if request.headers['Authorization'] == Rails.application.credentials.internal_api_key

    render json: { error: 'Token invalid' }, status: :unauthorized
  end

  def link_user_to_athlete
    if params[:athlete_id]
      @athlete = Athlete.find(params[:athlete_id])
      @athlete.update!(user: @user)
    else
      @athlete = @user.create_athlete!(athlete_params)
    end
  end
end

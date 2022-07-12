# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :validate_email_on_allowlist, only: :create # rubocop:disable Rails/LexicallyScopedActionFilter

protected

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(_resource)
    users_confirmations_pending_path
  end

  def validate_email_on_allowlist
    gateway = Gateways::S3.new(
      bucket: ENV.fetch("S3_SIGNUP_ALLOWLIST_BUCKET"),
      key: ENV.fetch("S3_SIGNUP_ALLOWLIST_OBJECT_KEY"),
    )
    checker = UseCases::Administrator::CheckIfAllowlistedEmail.new(gateway:)
    allowlisted = checker.execute(sign_up_params[:email])[:success]

    if allowlisted == false
      logger.info("Unsuccessful signup attempt: #{sign_up_params[:email]}")
    end

    set_user_object_with_errors && return_user_to_registration_page unless allowlisted
  end

  def set_user_object_with_errors
    @user = User.new(sign_up_params)
    @user.errors.add(:email, "Email address must be from a government or a public sector domain. If you're having trouble signing up, contact us.")
  end

  def return_user_to_registration_page
    render :new, resource: @user
  end
end

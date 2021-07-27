class Users::TwoFactorAuthenticationSetupController < ApplicationController
  # Skips 2FA so User can set up the totp via QR code
  skip_before_action :handle_two_factor_authentication
  # Skips 2FA setup confirmation callback in ApplicationController.
  skip_before_action :confirm_two_factor_setup, :redirect_user_with_no_organisation

  def show
    @otp_secret_key = ROTP::Base32.random_base32
  end

  def update
    @otp_secret_key = params[:otp_secret_key]
    if current_user.authenticate_totp(params[:code], otp_secret_key: @otp_secret_key)
      current_user.update!(otp_secret_key: @otp_secret_key)

      flash[:notice] = "Two factor authentication setup successful"
      disable_2fa_checks_for_session
    else
      flash[:alert] = "Six digit code is not valid"
      render "show"
    end
  end

  def qr_code_uri
    provisioning_uri = current_user.provisioning_uri(
      current_user.email,
      otp_secret_key: @otp_secret_key,
      issuer: "GovWifi (#{ENV['RACK_ENV']})",
    )
    qr_code = RQRCode::QRCode.new(provisioning_uri, level: :m)
    qr_code.as_png(size: 180, fill: ChunkyPNG::Color::TRANSPARENT).to_data_url
  end
  helper_method :qr_code_uri

  def twofa_key
    @otp_secret_key.scan(/.{4}/).join("&nbsp;&nbsp;").html_safe
  end
  helper_method :twofa_key

private

  def disable_2fa_checks_for_session
    request.env["warden"].session(:user)[TwoFactorAuthentication::NEED_AUTHENTICATION] = false
    redirect_to stored_location_for(:user) || root_path
  end
end

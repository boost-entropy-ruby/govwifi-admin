class AuthenticationMailer < ::Devise::Mailer
  helper :application
  include Rails.application.routes.url_helpers
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, _opts = {})
    opts = {
      email: record.email,
      locals: { confirmation_url: confirmation_url(record, confirmation_token: token) },
      template_id: GOV_NOTIFY_CONFIG["confirmation_email"]["template_id"],
      reference: "confirmation_email",
    }
    Services.email_gateway.send_email(opts)
  end

  # Overrides https://github.com/plataformatec/devise/blob/master/app/mailers/devise/mailer.rb#L12
  def reset_password_instructions(record, token, _opts = {})
    opts = {
      email: record.email,
      locals: { reset_url: edit_password_url(record, reset_password_token: token) },
      template_id: GOV_NOTIFY_CONFIG["reset_password_email"]["template_id"],
      reference: "reset_password_email",
    }
    Services.email_gateway.send_email(opts)
  end

  def unlock_instructions(record, token, _opts = {})
    opts = {
      email: record.email,
      locals: { unlock_url: unlock_url(record, unlock_token: token) },
      template_id: GOV_NOTIFY_CONFIG["unlock_account"]["template_id"],
      reference: "unlock_account",
    }
    Services.email_gateway.send_email(opts)
  end

  def invitation_instructions(record, token, _opts = {})
    opts = {
      email: record.email,
      locals: { invite_url: accept_invitation_url(record, invitation_token: token) },
      template_id: GOV_NOTIFY_CONFIG["invite_email"]["template_id"],
      reference: "invite_email",
    }
    Services.email_gateway.send_email(opts)
  end

  def membership_instructions(record, token, opts = {})
    opts = {
      email: record.email,
      locals: { invite_url: confirm_new_membership_url(token:),
                organisation: opts.fetch(:organisation).name },
      template_id: GOV_NOTIFY_CONFIG["cross_organisation_invitation"]["template_id"],
      reference: "invite_email",
    }
    Services.email_gateway.send_email(opts)
  end
end

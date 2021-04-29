module ApplicationHelper
  include ActionView::Helpers::OutputSafetyHelper

  def field_error(resource, key)
    resource&.errors&.include?(key.to_sym) ? "govuk-form-group--error" : ""
  end

  def active_tab(*identifiers)
    classes = %w[govuk-link govuk-link--no-visited-state]

    classes << "active" if identifiers.any? { |i| request.path.include?(i) }

    classes.join(" ")
  end

  def infer_page_title
    safe_join([content_for(:page_title), SITE_CONFIG["default_page_title"]].reject(&:nil?), " - ")
  end

  def user_2fa_authenticated?
    request.env["warden"].session(:user)[TwoFactorAuthentication::NEED_AUTHENTICATION]==false
  end
end

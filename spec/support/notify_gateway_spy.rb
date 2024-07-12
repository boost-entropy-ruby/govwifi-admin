class NotifyGatewaySpy
  attr_reader :email_parameters, :sms_parameters

  def initialize(_)
    @email_parameters = []
    @sms_parameters = []
  end

  def last_email_parameters
    @email_parameters.last
  end

  def last_confirmation_url
    @email_parameters.last.dig(:personalisation, :confirmation_url)
  end

  def last_invite_url
    @email_parameters.last.dig(:personalisation, :invite_url)
  end

  def last_reset_password_url
    @email_parameters.last.dig(:personalisation, :reset_url)
  end

  def send_email(opts)
    @email_parameters << opts
  end

  def send_sms(opts)
    @sms_parameters << opts
  end

  def reset
    @email_parameters = []
    @sms_parameters = []
  end

  def get_all_templates
    NotifyTemplates::TEMPLATES.map { |name| OpenStruct.new(name:, id: "#{name}_template") }
  end

  def count_all_emails
    @email_parameters.count
  end

  def count_emails_with_template(template_id)
    @email_parameters.count { |parameters| parameters[:template_id] == template_id }
  end

  def count_sms_with_template(template_id)
    @sms_parameters.count { |parameters| parameters[:template_id] == template_id }
  end
end

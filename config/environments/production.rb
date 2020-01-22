require 'railgun/mailer'
require 'railgun/message'

Jets.application.configure do
  # Example:
  # config.function.memory_size = 2048

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # Docs: http://rubyonjets.com/docs/email-sending/
  # config.action_mailer.raise_delivery_errors = false
  
  ## Mailgun 이메일 설정
  # config.action_mailer.add_delivery_method :mailgun
  # config.action_mailer.delivery_method = :mailgun
  # config.action_mailer.mailgun_settings = {
  #   api_key: ENV['MAILGUN_API'],
  #   domain: ENV['MAILGUN_DOMAIN']
  # }
end

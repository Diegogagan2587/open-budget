class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    locale = user.locale.presence || I18n.default_locale
    I18n.with_locale(locale) do
      mail subject: I18n.t("mailer.passwords.reset_subject"), to: user.email_address
    end
  end
end

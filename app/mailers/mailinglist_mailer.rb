class MailinglistMailer < ActionMailer::Base
  default from: 'projectfiremind@gmail.com'

  def ai_mistake_email(ai_mistake)
    @ai_mistake = ai_mistake
    mail(to: MAGARENA_MAILINGLIST, subject: "New AI mistake reported #{@ai_mistake.id}")
  end
end

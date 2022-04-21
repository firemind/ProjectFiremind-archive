class CsmMailer < ActionMailer::Base
  default from: 'no-reply@firemind.ch'

  def check_failed_email(duel)
    @duel = duel
    @csm = duel.card_script_submission
    mail(to: @csm.user.email, subject: "CSM #{@csm.card} failed")
  end
end

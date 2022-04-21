class DeckReportMailer < ActionMailer::Base
  add_template_helper(DecksHelper)
  default from: 'no-reply@firemind.ch'

  def deck_enabled_email(deck)
    @deck = deck
    mail(to: deck.author.email, subject: "Deck is now active")
  end

  def weekly_report_email(user)
    @user = user
    @ratings_per_format = []
    @decks = user.decks.active.legal
    deck_ids = @decks.collect(&:id)
    @formats = Format.enabled

    @forks = Deck.where(forked_from_id: deck_ids).where("created_at > ?", 7.days.ago)

    mail(to: user.email, subject: "[Project Firemind] weekly deck report")
  end

end

class SystemMailer < ActionMailer::Base
  default from: ''
  default to: ''

  def archetype_name_suggestion_email(deck_list, user)
    @user = user
    @deck_list = deck_list
    mail(subject: "New Archetype name suggested #{@deck_list.id}")
  end

  def archetype_updated_email(deck_list, user)
    @user = user
    @deck_list = deck_list
    mail(subject: "Archetype was updated for #{@deck_list.id}")
  end

  ARCHETYPE_DECK_THRESH=3
  def decks_imported_email(subject, format, unknown_archetypes, changed_archetypes)
    @deck_list_groups = [
        [
            "Unknown Archteypes with at least #{SystemMailer::ARCHETYPE_DECK_THRESH} decks",
            unknown_archetypes.select{|k,v|v.size >= ARCHETYPE_DECK_THRESH}
        ], [
            "Unknown Archteypes with less than #{SystemMailer::ARCHETYPE_DECK_THRESH} decks",
            unknown_archetypes.select{|k,v|v.size < ARCHETYPE_DECK_THRESH}
        ]
    ]
    @changed_archetypes = changed_archetypes
    @format = format
    mail(subject: subject)
  end
end

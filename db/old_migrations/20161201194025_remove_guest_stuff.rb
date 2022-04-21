class RemoveGuestStuff < ActiveRecord::Migration[5.0]
  def change
    return if Rails.env.test?
    dummy = User.dummy_user 
    User.where(name: "guest").each do |u|
      u.card_requests.each do |cr|
        puts "Card Request #{cr.id}"
        cr.user = dummy
        cr.save!
      end

      u.ai_mistakes.each do |cr|
        puts "AI Mistake #{cr.id}"
        cr.user = dummy
        cr.save!
      end

      u.card_script_submissions.each do |cr|
        puts "CSM #{cr.id}"
        cr.user = dummy
        cr.save!
      end

      u.duels.each do |cr|
        puts "Duel #{cr.id}"
        cr.user = dummy
        cr.save(validate: false)
      end

      u.meta.each do |cr|
        puts "Meta #{cr.id}"
        cr.user = dummy
        cr.save!
      end

      u.mulligan_decisions.each do |cr|
        puts "Meta #{cr.id}"
        cr.user = dummy
        cr.save!
      end
      u.destroy

    end
  end
end

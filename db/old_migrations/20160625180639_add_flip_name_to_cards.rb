class AddFlipNameToCards < ActiveRecord::Migration
  def change
    add_column :cards, :flip_name, :string
    {
      "Akki Lavarunner" => "Tok-Tok, Volcano Born",
      "Kitsune Mystic" => "Autumn-Tail, Kitsune Sage",
      "Cunning Bandit" => "Azamuki, Treachery Incarnate",
      "Budoka Gardener" => "Dokai, Weaver of Life",
      "Erayo, Soratami Ascendant" => "Erayo's Essence",
      "Initiate of Blood" => "Goka the Unjust",
      "Homura, Human Ascendant" => "Homura's Essence",
      "Budoka Pupil" => "Ichiga, Who Topples Oaks",
      "Faithful Squire" => "Kaiso, Memory of Loyalty",
      "Kuon, Ogre Ascendant" => "Kuon's Essence",
      "Nezumi Graverobber" => "Nighteyes the Desecrator",
      "Rune-Tail, Kitsune Ascendant" => "Rune-Tail's Essence",
      "Sasaya, Orochi Ascendant" => "Sasaya's Essence",
      "Orochi Eggwatcher" => "Shidako, Broodmistress",
      "Nezumi Shortfang" => "Stabwhisker the Odious",
      "Student of Elements" => "Tobita, Master of Winds",
      "Jushi Apprentice" => "Tomoya the Revealer",
      "Bushi Tenderfoot" => "Kenzo the Hardhearted",
    }.each do |name, flip_name|
      Card.where(name: name).update_all(flip_name: flip_name)
    end
  end
end

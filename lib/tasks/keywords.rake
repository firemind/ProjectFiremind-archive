namespace :keywords do
  task :assign => :environment do
    keyword_map = Keyword.all.map{|r| [r.name.to_s, r]}.to_h
    Card.select("id", "name", "ability").where.not(ability: nil).each do |card|
      keyword_map.each do |n,r|
        if card.ability.include?(n)
          unless card.keywords.include? r
            puts "#{card.name} << #{r.name}"
            card.keywords |= [r]
          end
        end
      end
    end
  end
end

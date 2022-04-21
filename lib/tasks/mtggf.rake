namespace :mtggf do
  task :verify => :environment do
    require 'colorize'
    scope = TournamentResult.where.not(mtggf_id: nil)
    progress_bar = ProgressBar.new(scope.count)
    scope.each do |tr|
      deck = tr.deck
      unless deck
        puts "No deck for #{tr.inspect}".red
        next
      end
      begin 
        list, side = tr.fetch_decklist
        list = list.split("\n").reject{|l| l.blank? || l[0] == '#'}
        saved_list = deck.deck_list.as_text
        saved_list = saved_list.split("\n").reject{|l| l.blank? || l[0] == '#'}
        if list.sort != saved_list.sort
          puts "Diff in #{tr.inspect}"
          puts tr.mtggf_url
          puts "#{saved_list-list}".green
          puts "#{list-saved_list}".red
        end

        side = side.gsub("\r",'').split("\n").reject{|l| l.blank? || l[0] == '#'}
        saved_side_list = deck.sideboard_entries.map{|r| "#{r.amount} #{r.card.name}"}
        if side.sort != saved_side_list.sort
          puts "Diff in sideboard #{tr.inspect}"
          puts tr.mtggf_url
          puts "#{saved_side_list-side}".green
          puts "#{side-saved_side_list}".red
          if saved_side_list.empty?
            deck.sideboard = side.join "\n"
            deck.save!
          end
        end
      rescue
        puts "Error on #{tr.mtggf_url}"
      end
      progress_bar.increment

    end
  end
end

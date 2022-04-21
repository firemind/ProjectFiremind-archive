namespace :firemind do
  desc "List hanging duels"
  task :list_hanging_duels => :environment do
    REQUE_TIMES=5
    queue_status = $redis.lrange(:new, 0, -1).map &:to_i
    if Game.where("updated_at > ?", 1.hour.ago).size == 0
      puts "No game created in the last hour. Maybe the workers are down?"
    end
    DuelQueue.default.duels.waiting.where("created_at < ?", 4.hours.ago).each do |duel|
      if duel.duel_queue.count < 10 && !queue_status.include?(duel.id)
        duel.requeue!
      end
    end
    Duel.started.where("updated_at < ?", 3.hours.ago).each do |duel|
      if duel.requeue_count < REQUE_TIMES && !queue_status.include?(duel.id)
        duel.requeue!
      else
        puts "Duel requeued #{REQUE_TIMES} times. Moving it to failed. Id: #{duel.id}"
        puts duel.failure_message
        duel.state = 'failed'
        duel.error_acknowledged = true
        duel.save!
      end
    end
    Duel.failed.where(error_acknowledged: false).each do |duel|
      if duel.requeue_count < REQUE_TIMES && !queue_status.include?(duel.id)
        duel.requeue!
      else
        puts "failed after #{duel.requeue_count} attempts: #{duel.id} created at #{duel.created_at}"
        puts duel.failure_message
        duel.error_acknowledged = true
        duel.save(validate: false)
      end
    end
  end
  desc "Feed queue"
  task :feed_queue => :environment do
    queue = DuelQueue.default
    sys_user = User.get_sys_user
    formats = Format.enabled.auto_queue
    (10-queue.duels.waiting.size).times do
      formats.each do |format|
        rating = format.ratings.order("whr_uncertainty desc, rand()").joins(deck_list: :decks).where(decks: {format_id: format.id}).first
        no_rating_scope = format.deck_lists.enabled.joins("LEFT OUTER JOIN ratings ON ratings.deck_list_id = deck_lists.id AND ratings.format_id = #{format.id}").having("count(ratings.id) = 0").order("RAND()").group("deck_lists.id")
        deck_list1 = if rating && rating.deck_list.legal_in?(format)
                       rating.deck_list
                     else
                       puts "No rated deck found. Picking both without in #{format}"
                       no_rating_scope.first
                     end
        if deck_list1
          deck_list2 = no_rating_scope.where.not(deck_lists: {id: deck_list1.id}).first || format.deck_lists.where.not(deck_lists: {id: deck_list1.id}).enabled.order("rand()").first
        end
        if deck_list1 && deck_list2
          duel = Duel.new(
            deck_list1: deck_list1,
            deck_list2: deck_list2,
            user: sys_user,
            state: 'waiting',
            format: format,
            games_to_play: 5,
            duel_queue_id: queue.id
          )

          duel.save!
        else
          puts "No duel created in #{format} because no decks were found."
        end
      end
    end
  end

  desc "Send out weekly report email"
  task :deliver_weekly_report => :environment do
    User.not_guest.where(receive_weekly_report: true).where.not(email: nil).find_each(batch_size: 100) do |u|
      if u.decks.active.count > 0
        begin
          DeckReportMailer.weekly_report_email(u).deliver
        rescue  Exception => e
          puts "Couldn't send email to #{u} #{u.email} (#{u.id})"
          puts e.inspect
        end
      else
        # TODO send mail with incentive to create deck
      end
      sleep 5
    end
  end

  task :create_deck_variations => :environment do
    Deck.where(id: MaybeEntry.distinct(:deck_id).collect{|me| me.deck_id }).order("RAND()").first(5).each do |deck|
      next if deck.forks.where(auto_generated: true).count > 4
      Deck.transaction do
        original_decklist = deck.decklist
        new_deck = Deck.new
        new_deck.title = deck.title
        new_deck.forked_from_id = deck.id
        new_deck.author = deck.author
        new_deck.format = deck.format
        new_deck.decklist = original_decklist
        new_deck.avatar = deck.avatar
        new_deck.save!
        replacement_list = []
        deck.maybe_entries.each do |me|
          if [true, false].sample
            new_amount = (me.min_amount..me.max_amount).to_a.sample
            me.deck_entry_cluster.deck_entries.each do |old_de|
              replace_amount = (0..[new_amount, old_de.amount, me.max_amount].min).to_a.sample
              if replace_amount > 0
                #puts "Replacing #{replace_amount} #{old_de.card} with #{replace_amount} #{me.card}"
                de = new_deck.deck_list.deck_entries.where(card_id: old_de.card_id).first
                if de && de.amount >= replace_amount
                  if de.amount > replace_amount
                    de.amount -= replace_amount
                    de.save
                  else
                    de.destroy
                  end
                  raise "needs refactoring since this would break existing deck lists"
                  nde = new_deck.deck_list.deck_entries.where(card_id: me.card_id).first_or_create
                  nde.group_type ||= case(me.card.card_type)
                                     when /(Basic |Snow )?Land( - .*)?/i
                                       'lands'
                                     when /Creature (- .*)?/i
                                       'creatures'
                                     else
                                       'spells'
                                     end
                  nde.amount ||= 0
                  nde.amount += replace_amount
                  nde.save
                  new_amount -= replace_amount
                  replacement_list << "#{replace_amount} #{de.card} with #{replace_amount} #{nde.card}"
                end
                #original_decklist.gsub!(/^#{old_de.amount} #{old_de.card}/, "#{old_de.amount - replace_amount} #{old_de.card}")
                #original_decklist += "\n#{replace_amount} #{me.card}"
                break if new_amount == 0
                raise "This shouldn't happen" if new_amount < 0
              end
            end
          end
        end
        udi = DeckList.get_udi_by_list(new_deck.deck_list.deck_entries.collect{|de| "#{de.amount} #{de.card}"}.sort.join(''))
        if dl = DeckList.find_by_udi(udi)
          raise ActiveRecord::Rollback
        else
          new_deck.deck_list.udi = udi
          new_deck.deck_list.save!
        end
        new_deck.description = "Automatically generated variation of #{deck.title}\n" + replacement_list.join("\n")
        new_deck.auto_generated = true
        new_deck.save!
        FormatCalcWorker.perform_async(new_deck.deck_list.id)
        if (na = new_deck.deck_list.deck_entries.sum(:amount)) > 60
          puts "WARNING decksize is > 60 - #{deck} id: #{deck.id} cards: #{na}"
        end
      end
    end
  end

  #task :delete_failed_deck_variations => :environment do
  #ids = Deck.select(:forked_from_id).where(auto_generated: true).collect(&:forked_from_id).uniq
  #Deck.where(id: ids).each do |deck|
  #rating = deck.current_rating
  #next unless rating
  #deck.forks.where(auto_generated: true).each do |fork_deck|
  #fork_rating = fork_deck.current_rating
  #next unless fork_rating
  #if fork_rating.whr_uncertainty < 20 && fork_rating.whr_rating < (rating.whr_rating-3)
  #fork_deck.duels.destroy_all
  #fork_deck.destroy
  #end
  #end
  #end
  #end

  task :fetch_dailies => :environment do
    require 'open-uri'
    fetch_tournaments_for_format("modern")
    fetch_tournaments_for_format("standard")
    fetch_tournaments_for_format("legacy")
    fetch_tournaments_for_format("vintage")
    fetch_tournaments_for_format("pauper")
  end

  def fetch_tournaments_for_format(format_name)
    user = User.dummy_user
    new_count = 0
    unknown_archetypes = []
    changed_archetypes = []
    format = Format.where(name: format_name).first!
    page = Nokogiri::HTML(open("https://www.mtggoldfish.com/metagame/#{format_name}"))
    page.css('div.decks-sidebar h4 a').each do |link|
      #puts link.text
      vals = link.text.split(" ")
      next unless vals.size > 1
      if vals[0] == 'States'
        paper = true
        tournament = Tournament.where({format: format, tournament_type: vals.join(" "), identifier: link['href'].split('/').last}).first_or_create!
      elsif vals[0].downcase == "competitive" || vals[0].downcase == "friendly"
        # competitive or friendly league league
        paper = false
        if vals[2] == 'League'
          tournament = Tournament.where({format: format, tournament_type: vals[0..2].join(' '), identifier: vals[3]}).first_or_create!
        else
          puts "Unknown tournament type #{link.text}"
        end
      elsif vals[0].downcase == "pauper" && vals[1].downcase == "league"
        paper = false
        tournament = Tournament.where({format: format, tournament_type: vals[0..1].join(' '), identifier: vals[2]}).first_or_create!
      elsif vals[1] == 'League'
        # normal mtgo league
        paper = false
        tournament = Tournament.where({format: format, tournament_type: vals[1], identifier: vals[2]}).first_or_create!
      elsif vals[2] && vals[2][0] == '#'
        # normal mtgo daily
        paper = false
        tournament = Tournament.where({format: format, tournament_type: vals[1], identifier: vals[2][1..-1] }).first_or_create!
      elsif vals[3] && vals[3][0] == '#'
        # ptq or something
        paper = false
        tournament = Tournament.where({format: format, tournament_type: vals[0..2].join(' '), identifier: vals[2][1..-1] }).first_or_create!
      else
        # paper tournament
        paper = true
        tournament = Tournament.where({format: format, tournament_type: vals.join(" "), identifier: link['href'].split('/').last}).first_or_create!
      end
      format ||= Format.where(name: format_name).first
      url = "https://www.mtggoldfish.com/"+link['href']
      begin 
        tpage = Nokogiri::HTML(open(url))
        tpage.css('.table-tournament tr')[1..-1].each do |tr|
          tds = tr.css('td')
          next unless tds.size > 1
          deck_name = tds[paper ? 1 : 2].text
          next if deck_name.blank?
          mtggf_id = tds[paper ? 1 : 2].css('a')[0]['href'].split('/').last
          if mtggf_id.blank?
            raise "no mtggf_id found in #{tds.inspect}"
          end
          tournament_result = TournamentResult.where({
            tournament: tournament,
            wins: paper ? 0 : tds[0].text, # todo work with placements like 3rd Place etc
            losses: paper ? 0 : tds[1].text,
            mtgo_nick: tds[paper ? 2 : 3].text,
            mtggf_id: mtggf_id
          }).first_or_create
          tournament_result.save
          unless tournament_result.errors.empty?
            puts url
            puts "problem creating tournament result #{tournament_result.errors.messages.inspect}"
            next
          end
          #puts "#{tournament_result.wins}/#{tournament_result.losses} #{tournament_result.mtgo_nick} #{tournament_result.mtggf_id}"
          archetype = Archetype.find_with_alias(deck_name, format.id)
          unless archetype
            unknown_archetypes << [deck_name, url] unless deck_name.gsub(/[WUBRG]/, '').blank? || deck_name == 'Unknown'
          end
          unless deck = Deck.where(tournament_result_id: tournament_result.id).first
            deck = Deck.new
            deck.title = deck_name
            deck.author = user
            deck.format = format
            deck.auto_generated = true
            list, side = tournament_result.fetch_decklist
            deck.decklist = list
            deck.sideboard = side
            deck.tournament_result_id = tournament_result.id
            #puts "New #{deck_name}" unless deck_name == 'Unknown'
            new_count +=1
            unless deck.save
              puts "Deck invalid: #{deck.errors.messages.inspect}"
              puts url
              next
            end
            dl = deck.deck_list
            FormatCalcWorker.new.perform dl.id
            dl.formats.reload
            if !dl.legal_in?(format)
              puts url
              puts list
              raise "Decklist not legal in #{format}"
            end
          else
            dl = deck.deck_list
          end
          deck.save

          if archetype && dl.human_archetype != archetype
            if dl.human_archetype
              changed_archetypes << {
                dl: dl,
                new_archetype: archetype,
                url: url
              } unless dl.human_archetype_confirmed
            else
              dl.human_archetype = archetype
              dl.archetype = archetype
              FormatCalcWorker.new.perform dl.id
              dl.formats.reload
              dl.save!
              # do not try to fix things for now
              #unless dl.save
                #puts url
                #puts dl.errors.messages.inspect
                #puts dl.as_text
                #puts deck.tournament_result.inspect
                #deck.decklist = deck.tournament_result.fetch_decklist
                #dl = deck.deck_list
                #FormatCalcWorker.new.process_dl dl
                #dl.human_archetype = archetype
                #dl.archetype = archetype
                #dl.save!
              #end
            end
          end
        end
      rescue Exception => e  
        puts "Exception on url #{url}"
        puts e.message
        puts e.backtrace
      end
    end
    SystemMailer.decks_imported_email("#{new_count} new deck lists in #{format_name}", format, unknown_archetypes.group_by{|r| r[0]}.map{|k,v| [k,v.map(&:last)]}.to_h.sort, changed_archetypes).deliver
  end
  #task :fetch_mtgo_results => :environment do
    #base_url = "http://magic.wizards.com"
    #require 'open-uri'
    #page = Nokogiri::HTML(open("#{base_url}/en/gameinfo/products/magiconline/decklists"))
    #page.css('.articles-listing .metaText span.section a').each do |link|
      #dailyname = link['href'].split('/').last
      #tournament = Tournament.new
      #tournament.tournament_type = "Daily"
      #format = Format.where(name: dailyname.split('-').first).first
      #next unless format && format.name != 'Pauper'
      #tournament.format = format
      #url = "#{base_url}#{link['href']}"
      #puts url
      #dailypage = Nokogiri::HTML(open(url))
      #daily_nr = /[^#]+ \#(\d+) [^#]+/.match(dailypage.css('h3')[0].text)[1]
        #tournament.nr = daily_nr
      #if tournament.save
        #dailypage.css('div.deck-group').each do |dg|
          #dl_link = dg.css('a.download-icon')[0]
          #dl_link['href']
          #mtgonick = dg.css('h4')[0].text.split(' ')[0]
          #result = dg.css('h4')[0].text.split(' ')[-1]
          #uri = URI.parse("#{base_url}#{dl_link['href']}")
          #response = Net::HTTP.get_response uri
          #deck_list = response.body.split("\r\n\r\n\r\n")
          #d = Deck.new
          #d.title = "#{dailyname} #{daily_nr} #{mtgonick} #{result}"
          #d.description = <<-EOF
          #Sideboard:
          ##{deck_list[1]}
          #EOF
          #d.decklist = deck_list[0]
          #d.author = User.get_sys_user
          #d.format = format
          #res = result.split('-')
          #if res.size == 2
            #wins = res[0].gsub('(','').to_i
            #losses = res[1].gsub(')','')
            #tr = tournament.tournament_results.build(
              #wins: wins,
              #losses: losses,
              #mtgo_nick: mtgonick
            #)
            #tr.save!
            #d.tournament_result = tr
          #else
            #puts "Can't parse result #{result}"
          #end
          #d.public = false
          #d.save!
          #dl = d.deck_list
          #archetype = Archetype.where(name: deck_name, format_id: format.id).first_or_create
          #dl.human_archetype = archetype
          #dl.save!
        #end
      #end
    #end

  #end
  task :find_disabled_decks_with_ratings, [:cleanup] => :environment do |t,args|
    DeckList.
      joins({deck_entries: :card}, :ratings).
      group("deck_lists.id").
      having("count(cards.id) > 0").
      where(cards: {enabled: false}).
      having("count(ratings.id) > 0").
      each do |dl|
        puts "Disabled Deck List with Rating #{dl.id}"
        if args[:cleanup]
          dl.ratings.destroy_all
        end
      end
  end
  task :cleanup_versions=> :environment do
    Version.where("created_at < ?", 8.days.ago).where(item_type: "Rating").delete_all
  end

  task :sync_missing_scripts => :environment do
    path = Rails.configuration.x.magarena_tracking_repo
    g = Git.open path
    g.pull
    diff = g.diff ProcessedCommit.last.name
    (diff.size > 0 ? diff :  []).each do |d|
      if d.path =~ /^release\/Magarena\/scripts_missing\//
        item = d.path.split('/').last

        unless File.exists? "#{path}/release/Magarena/scripts_missing/#{item}"
          if File.exists? "#{path}/release/Magarena/scripts/#{item}"
            content = File.read("#{path}/release/Magarena/scripts/#{item}").split("\n")
            cardname = content.first.split('=')[1].chomp
            card = Card.find_with_varying_name(cardname)
            if card && !card.enabled
              puts "Card enabled in next release #{card}"
              card.added_in_next_release = true
              card.save!
              next
            else
              raise "No disabled card found for #{item}"
            end
          else
            if item[0..4] == "_ther" || /__ther/ =~ item 
              # Ignore deletion of _ther cards that were renamed because of ligature change
              next
            else
              raise "Item does not exist in scripts_missing or scripts #{item}"
            end
          end
        end

        content = File.read("#{path}/#{d.path}").split("\n")
        cardname = content.first.split('=')[1].chomp
        card = Card.find_with_varying_name(cardname)
        unless card
          raise "Card not found #{cardname}"
        end
        if card.enabled
          if File.exists? "#{path}/release/Magarena/scripts/#{item}"
            puts "Card is both missing and not missing #{card} #{item}"
            next
          else
            puts "Disabling previously enabled card: #{card}"
            card.enabled = false
            card.save!
          end
        end

        if needs_groovy_line = content.select {|l| l =~ /^status=needs groovy/ }.first
          card.needs_groovy = true
          card.save!
        end

        reasons = []
        not_supported_line = content.select {|l| l =~ /^status=not supported:/ }.first
        if not_supported_line
          not_supported_line.split(":")[1].split(',').each do |reason|
            reason = NotImplementableReason.escape_name reason.strip
            r = NotImplementableReason.where(name: reason).first
            unless r
              r = NotImplementableReason.create(name: reason, user: User.get_sys_user)
            end
            unless reasons.include? r
              reasons << r
            end
          end
        end
        if (removed = card.not_implementable_reasons - reasons).size > 0
          puts "Removing reasons #{removed.map &:name} from #{card}"
        end
        if (added = reasons - card.not_implementable_reasons).size > 0
          puts "Adding reasons #{added.map &:name} to #{card}"
        end
        card.not_implementable_reasons = reasons
        card.save!
      end
    end
    ProcessedCommit.log g.log[0].sha
  end

  task :create_rpush_app => :environment do
    app = Rpush::Gcm::App.new
    app.name = "android_app"
    app.auth_key = 'AIzaSyAjG-FmkOmjvH5M6ViMNX8IQIdphhaapz8'
    app.connections = 1
    app.save!
  end

  task :report => :environment do
    interval = 1.hour
    User.where("created_at > ?", interval.ago).each do |u|
      puts "New User #{u.email}"
    end
    Deck.where("created_at > ?", interval.ago).where.not(author_id: User.dummy_user.id).each do |r|
      puts "New deck by #{r.author} #{r.title}"
    end
    mull_scope = MulliganDecision.where("created_at > ?", interval.ago)
    count = mull_scope.count
    puts "New decisions: #{count} (#{mull_scope.map(&:source).uniq.join(',')})" if count > 0
    count = DealtHand.where("created_at > ?", interval.ago).count
    puts "New dealt_hand: #{count}" if count > 0
    duel_scope = Duel.where("created_at > ?", interval.ago).where.not(user_id: User.get_sys_user)
    count = duel_scope.count
    puts "New duel: #{count} (#{duel_scope.map(&:user).uniq.join(',')})" if count > 0
  end

end

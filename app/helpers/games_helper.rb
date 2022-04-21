module GamesHelper


  def parse_log_file(file)
    output = ''
    decision = false
    options = []
    choice = []
    choice_counter = 0
    ln = 0
    lifecount = {'1' => 20, '2' => 20}
    text= File.open(file).read
    text.each_line do |line|
      ln += 1
      next if match_uninteresting_lines(line)
      if m = /^(MCTS|MMAB) cheat=false index=(\d) life=(\d+) turn=(\d+) phase=([^ ]+) .*/.match(line)
        player = m[2].to_i + 1
        life = m[3].to_i
        turn = m[4].to_i
        output += "<p><span class='label secondary'>Turn #{turn} - Phase #{m[5]}</span></p>"
        output += "<p><span class='label alert'>Player #{player} at #{life} Life</span></p>" if lifecount[player] != life
        lifecount[player] = life
      elsif line =~ /^( |\*) \[/
        if ! decision
          decision = true
        end
        options << line
        if line =~ /^\* \[/
          choice << line.split("]")[1]
        end
      else
        if decision
          choice_counter += 1
          output += <<-HTML
            <a href="#" data-dropdown="contentDrop#{choice_counter}">Decided on</a> #{choice.join(" ")}
            <div id="contentDrop#{choice_counter}" class="f-dropdown content medium" data-dropdown-content>
              <h4>Options were</h4>
              <ul>
            #{options.collect{|o| format_log_line(o)}.join('')}
              </ul>
              <a href="/report_ai_mistake/#{@game.id}/#{ln-1}">That decision was stupid!</a>
            </div>
            HTML
            options = []
            decision = false
            choice = []
        end
        output += format_log_line(line)
      end
    end
    @game.winning_deck_list.deck_entries.each do |de|
      card = de.card
      output.gsub!(card.name, card_link(card))
    end
    @game.losing_deck_list.deck_entries.each do |de|
      card = de.card
      output.gsub!(card.name, card_link(card))
    end
    output.html_safe
  end


  def format_log_line(line)
    line.gsub!(/^LOG \(P\)/, "<span class='label success'>Deck 1</span>")
    line.gsub!(/^LOG \(C\)/, "<span class='label'>Deck 2</span>")
    populate_manasymbols(line)
    "<p>#{line}</p>"
  end

  def match_uninteresting_lines(line)
    line =~ /^MCTS cached=0$/ ||
    line =~ /^MMAB cached=0$/
  end

end

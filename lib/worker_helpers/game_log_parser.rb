class GameLogParser
  VERSION=2
  def initialize(log_data)
    @root_object = {}
    @meta_data = {
      on_play: nil,
      players: {
        P: {
          decision_count: 0,
          action_count: 0,
        },
        C: {
          decision_count: 0,
          action_count: 0,
        }
      }
    }
    parse_log_file(log_data)
  end

  def meta_data
    @meta_data
  end

  def to_json
    @root_object.to_json
  end

  def parse_log_file(text)
    players = {
      P: {},
      C: {},
    }
    output = ''
    decision = false
    options = []
    choice = []
    choice_counter = 0
    lifecount = {'1' => 20, '2' => 20}
    current_turn_num = 0
    current_turn = nil
    current_phase = nil
    current_player = nil
    phase_part = nil
    line_count = 0

    @root_object[:turns] = []

    begin 
      text.each_line do |line|
        line_count += 1
        # MAGARENA GAME LOG


        if m = /^MAGARENA GAME LOG$/.match(line)

        # MCTS cached=0
        elsif m = /^(MMAB|MCTS) cached=(\d+)$/.match(line)

        # CREATED ON 2016/02/22 17:58:59
        elsif m = /^CREATED ON (.*)$/.match(line)
          @root_object[:created_on] = m[1]

        # MAGARENA VERSION 1.70, JRE 1.8.0_60, OS Linux_3.13.0-77-generic amd64
        elsif m = /^MAGARENA VERSION (\d+)\.(\d+), (.*)$/.match(line)
          @meta_data[:magarena_version] = "#{m[1]}.#{m[2]}"
          @root_object[:system] = m[3]

        # LOG (P): Player1 may (no) take a mulligan.
        elsif m = /LOG \((C|P)\):( ([A-Za-z0-9]+) may \((yes|no)\) take a mulligan\.)+/.match(line)
          short = m[1].to_sym
          line.chomp.split('.').each do |part|
            next unless m = / ([A-Za-z0-9]+) may \((yes|no)\) take a mulligan$/.match(part)
            players[short][:num_mull] ||= 0
            players[short][:full] ||= m[1].to_sym
            players[short][:num_mull] += 1 if m[2] == "yes"
          end

        # MCTS cheat=false index=1 life=20 turn=1 phase=FirstMain sims=30 time=6043
        elsif m = /^(MCTS|MMAB) cheat=(true|false) index=(\d) life=(\d+) turn=(\d+) phase=([^ ]+) (slice|sims)=(\d+) time=(\d+)$/.match(line)
          current_player = players.keys[m[3].to_i]
          if current_turn_num < m[5].to_i
            current_turn_num = m[5].to_i
            if current_turn_num == 1
              raise "Writing on play twice" if @meta_data[:on_play]
              @meta_data[:on_play] = current_player
            end
            current_turn = {
              active_player: current_player,
              number: current_turn_num,
              phases: {} 
            }
            current_phase_name = nil
            @root_object[:turns] << current_turn
          end
          if current_phase_name != m[6]
            current_phase_name = m[6]
            current_turn[:phases][current_phase_name.to_sym] ||= []
            current_phase = current_turn[:phases][current_phase_name.to_sym]
          end
          phase_part = {
              life_active_player: m[4].to_i,
              active_player: current_player,
              options: [],
              actions: []
          }
          current_phase << phase_part

        # * [99/2/?] ([Serra Ascendant, Mirran Crusader])
        elsif phase_part && m = /^( |\*) \[\d+\/\d+\/(.*)\] \(((\[.*\])+|(.*))\)/.match(line)
          @meta_data[:players][current_player.to_sym][:decision_count] += 1
          phase_part[:options] << line.chomp
   
        elsif phase_part && m = /^LOG \((C|P)\): (.*)/.match(line)
          @meta_data[:players][m[1].to_sym][:action_count] += 1
          phase_part[:actions] << {
            active_player: m[1],
            text: m[2]
          }
        elsif /^\s*$/.match(line) # ignore empty lines
        else
          @root_object[:unmatched_lines] ||= []
          @root_object[:unmatched_lines] << line
        end
      end

      @root_object[:players] = players

      @meta_data[:win_by_turn] = current_turn_num
    rescue => e
      puts "Exception on line #{line_count}"
      raise e 
    end


  end

end

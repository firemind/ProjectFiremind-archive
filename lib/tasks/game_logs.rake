namespace :game_logs do
  task :convert_files => :environment do
    require 'fileutils'
    Game.where("id < ?", 1783450).find_each(batch_size: 100){|g|
      path = "#{LOGFILE_BASEDIR}/duels/#{g.duel.id}/games/game#{g.game_number}.log"
      next unless File.exists? path
      puts path
      new_dest = LOGFILE_BASEDIR+g.json_log_path
      FileUtils.mkdir_p File.dirname(new_dest)
      begin
        parser = GameLogParser.new(File.read(path))
        File.open(new_dest, 'w') { |file| 
          file.write(parser.to_json)
        }
        new_log_path = LOGFILE_BASEDIR+ g.log_path 
        FileUtils.mkdir_p File.dirname(new_log_path)
        `mv #{path} #{new_log_path}`
        `gzip #{new_log_path}`
      rescue
        puts "broken file"
        File.delete(path) if g.created_at < 1.year.ago
      end
    }
  end

  task :reparse_game_log_files, [:from] => :environment do |t, args|
    scope = Game.where("parsed_by is null or parsed_by < ?", GameLogParser::VERSION)
    if args[:from]
      scope = scope.where("id >= ?", args[:from])
    end

    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 100) do |g|
      #puts LOGFILE_BASEDIR+g.log_path
      begin
        ReparseGameLogWorker.new.perform(g.id)
      rescue
        puts "Error on #{g.id}"
      end

      progress_bar.increment
    end
  end

end

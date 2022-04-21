class ParseGameLogWorker
  include Sidekiq::Worker

  def perform(game_id)
    game = Game.find game_id 
    path = LOGFILE_BASEDIR+game.log_path
    if File.exists? path
      parser = GameLogParser.new(File.read(path).encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''))
      new_dest = LOGFILE_BASEDIR+game.json_log_path
      FileUtils.mkdir_p File.dirname(new_dest)
      File.open(new_dest, 'w') { |file|
        file.write(parser.to_json)
      }
      `gzip #{path}`
      `gzip #{new_dest}`
      game.update_meta_data!(parser.meta_data)
    end
  end
end



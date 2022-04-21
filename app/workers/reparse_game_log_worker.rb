class ReparseGameLogWorker
  include Sidekiq::Worker

  def perform(game_id)
    game = Game.find game_id 
    path = LOGFILE_BASEDIR+game.log_path+".gz"
    if File.exists? path
      parser = GameLogParser.new(Zlib::GzipReader.new(open(path)))
      new_dest = LOGFILE_BASEDIR+game.json_log_path
      FileUtils.mkdir_p File.dirname(new_dest)
      File.delete("#{new_dest}.gz") if File.exists?"#{new_dest}.gz"
      File.open(new_dest, 'w') { |file|
        file.write(parser.to_json)
      }
      `gzip #{new_dest}`

      game.update_meta_data!(parser.meta_data)
    end
  end
end



namespace :metagame do
  task :fetch=> :environment do
   # fetch_metagame_for_format("pauper")
   #  fetch_metagame_for_format("vintage")
   #  fetch_metagame_for_format("legacy")
    fetch_metagame_for_format("modern")
   #  fetch_metagame_for_format("standard")
  end

  def fetch_metagame_for_format(format_name)
    user = User.find 49
    format = Format.find_by_name(format_name)
    meta = user.meta.where(format_id: format.id).first_or_create
    meta.name ||= "My #{format_name} meta"
    meta.save
    puts meta.inspect
    client = MtggfClient.new
    client.update_meta(format_name, meta)
  end
end


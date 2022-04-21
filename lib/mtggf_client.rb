class MtggfClient

  def update_meta(format_name, meta)
    require 'open-uri'
    page = Nokogiri::HTML(open("https://www.mtggoldfish.com/metagame/#{format_name}/full"))
    format = Format.find_by_name(format_name)
    meta.meta_fragments.destroy_all
    page.css('.archetype-tile').each do |tile|
      at_name = tile.css("h2 .deck-price-online")[0].text.gsub(/[[:space:]]/, ' ').strip
      archetype = Archetype.find_with_alias(at_name, format.id)
      if archetype
        mf = meta.meta_fragments.where(archetype_id: archetype.id).first_or_initialize
        mf.meta = meta

        percentage = tile.css("table.stats .percentage")[0].text.gsub(/[[:space:]]/, ' ').strip
        occ = (percentage.gsub(/%/,'').to_f * 100).to_i
        puts "#{archetype} #{occ}"

        mf.occurances ||= 0
        mf.occurances += occ
        mf.save!
      else
        puts "Don't know archetype #{at_name}"
      end
    end
  end

end

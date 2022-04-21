class MlbotApi
  @@base_url = "https://www.mtgolibrary.com/web_shops/"

  def set_numbers
    http_get @@base_url, "set_numbers", default_params
  end

  def cards
    http_get @@base_url, "cards", default_params
  end

  def inventory(set_name=nil, rarity='R')
    params = default_params
    params.merge!(set_name: set_name) if set_name
    params.merge!(rarity: rarity) if rarity
    http_get @@base_url, "inventory", params
  end

  def default_params
    {
      bot: Rails.application.secrets.mlbot_api['bot'],
      key: Rails.application.secrets.mlbot_api['key']
    }
  end

  private
  def http_get(domain,path,params)
    uri = URI("#{@@base_url}/#{path}?#{params.collect { |k,v| "#{k}=#{URI.escape(v.to_s)}" }.join('&')}")
    request = Net::HTTP.get_response(uri)
    if request.is_a?(Net::HTTPSuccess)
      JSON.parse(request.body) unless request.body.length < 3
    else
      puts uri
      raise "Error "+request.to_s
    end
  end
end

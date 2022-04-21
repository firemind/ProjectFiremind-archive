module ArchetypeHelper
  def banner_url(archetype)
    "#{BANNER_SERVER_URL}archetypes/#{archetype.id}.jpg"
  end
end

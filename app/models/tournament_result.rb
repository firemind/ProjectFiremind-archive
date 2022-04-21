class TournamentResult < ApplicationRecord
  belongs_to :tournament
  has_one :deck
  validates_presence_of :tournament


  def mtggf_url
    raise "No mtggf_id set #{self.inspect}" unless mtggf_id
    "https://www.mtggoldfish.com/deck/download/#{mtggf_id}"
  end

  def fetch_decklist
    path = mtggf_url
    list = []
    sideboard_list = []
    open(path) { |io|
      data = io.read.force_encoding('UTF-8')
      sideboard= false
      data.split("\n").each do |line|
        if line.strip.empty?
          sideboard=true
          next
        end
        if sideboard
          sideboard_list << line unless line =~ /^\/\/.*/
        else
          list << line unless line =~ /^\/\/.*/
        end
      end
    }
    #[list.join("\n").encode("UTF-8"), sideboard_list.join("\n").encode("UTF-8")]
    [list.join("\n"), sideboard_list.join("\n")]
  end

  def ranking
    "#{wins}-#{losses}"
  end
end

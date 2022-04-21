module FormatHelper
  def pagination_link
    link_to_next_page(@cards, 'Next Page', :remote => true, url: cards_format_path(id: @format.name.downcase))
  end
end

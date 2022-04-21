ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Internal Workers" do
          area_chart Duel.where(assignee_id: 49).finished
            .includes(:format, deck_list1: :archetype, deck_list2: :archetype)
            .where("created_at > ?", 10.days.ago)
            .group_by(&:format)
            .map{|k,v| [k, v.group_by_day{|u| u.created_at }.map{|k2,v2| [k2, v2.count]}]}.map{|k,v| {name: k.to_s, data: v}}

        end
      end
      column do
        panel "User action" do
          lines = [
            {name: "Duels CS", rel: Duel.finished.where.not(assignee_id: [71, 49])  },
            {name: "Decks created", rel: Deck.where.not(author_id: User.get_sys_user.id) },
            {name: "User sign ups", rel: User }
          ]
          line_chart lines.map{|line|
            {name: line[:name], data: line[:rel].where("created_at > ?", 2.months.ago).group_by_week(:created_at).count}
          }
        end
      end
    end
    columns do
      column do
        panel "Failed Duels" do
          ul do
            Duel.failed.order("updated_at desc").includes(deck_list1: :archetype, deck_list2: :archetype).limit(5).each do |duel|
              li link_to "#{duel.deck_list1} vs #{duel.deck_list2} #{duel.updated_at}", duel, title: duel.failure_message&.truncate(200)
            end
          end
        end
        panel "Mulligan Decisions" do
          ul do
            li "Total MDs: #{MulliganDecision.count}"
            li "MD source count: #{MulliganDecision.select("distinct(source_ip)").count}"
            li "MD user count: #{MulliganDecision.select("distinct(user_id)").count}"
            li "Keep/Mull: #{MulliganDecision.where(mulligan:false).count}/#{MulliganDecision.where(mulligan:true).count}"
          end
        end
      end
      column do
        panel "Mull Decisions Tiemline" do
          rel= MulliganDecision.where("created_at > ?", 7.days.ago).includes(:user)
          top = rel.group_by{|r| r.user || r.source_ip}.map{|k,v| [k, v.size] }.sort{|r| r[1]}
          top10 = top.last(10)
          lines = top10.map{|k,v|
            {name: "#{k}", rel: (k.is_a?(User) ? rel.where(user_id: k.id) : rel.where(user_id: nil, source_ip: k)) }
          }
          if top.size > 10
            lines += [{name: "Other", rel: rel.where.not(
              user_id: top10.map{|k,v| k.is_a?(User) ? k.id : nil }.compact, 
              source_ip: top10.map{|k,v| k.is_a?(User) ? nil : k }.compact
            )}]
          end
          line_chart lines.map{|line|
            {name: line[:name], data: line[:rel].group_by_hour(:created_at).count}
          }
        end
      end
    end
    #columns do
      #column do
        #panel "Top Stock" do
          #bar_chart CardPrint.where("mlbot_inventory > 0").order("mlbot_sell_price desc").first(10).map{|r| [r.name, r.mlbot_sell_price]}
        #end
      #end
      #column do
        #panel "Stock Overview" do
          #pie_chart CardPrint.where("mlbot_inventory > 0").group("rarity").sum("mlbot_inventory*mlbot_sell_price")
        #end
      #end
      #column do
        #panel "Stock Stats" do
          #ul do
            #li "Total Cards: #{CardPrint.where("mlbot_inventory > 0").sum("mlbot_inventory")}"
            #li "Total Value: #{CardPrint.where("mlbot_inventory > 0").sum("mlbot_inventory*mlbot_sell_price")}"
          #end
        #end
      #end
    #end
    columns do
      #column do
        #panel "Price Changes" do
          #line_chart PriceChange.where("created_at > ?", 24.hours.ago).group(:source).group_by_hour(:created_at).count
        #end
      #end
      column do
        panel "Last Duels by user" do
          games = Game.includes(duel: :user).last(100) #.where("created_at > ?", 1.hour.ago)
          pie_chart games.group_by{|g| g.duel.user }.map{|k,v| ["#{k.to_s} #{k.email}", v.size]}
        end
      end
      column do
        panel "Last Duels by archetype" do
          games = Game.includes(duel: {deck_list1: {archetype: :format}, deck_list2: {archetype: :format}}).last(100) #.where("created_at > ?", 1.hour.ago)
          decks = games.collect {|g| [g.duel.deck_list1, g.duel.deck_list2] }.flatten
          archetypes = decks.collect{|d| d.archetype}.compact.group_by{|a| "#{a.to_s} #{a.format.to_s}"}
          pie_chart archetypes.map{|k,v| [k, v.size]}
        end
      end
    end
    render partial: 'shared/chartjs'
    render inline: "<%= yield(:custom_js) %>"
  end

  # Here is an example of a simple dashboard with columns and panels.
  #
  # columns do
  #   column do
  #     panel "Recent Posts" do
  #       ul do
  #         Post.recent(5).map do |post|
  #           li link_to(post.title, admin_post_path(post))
  #         end
  #       end
  #     end
  #   end

  #   column do
  #     panel "Info" do
  #       para "Welcome to ActiveAdmin."
  #     end
  #   end
  # end
end # content

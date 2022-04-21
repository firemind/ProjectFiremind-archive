class Api::V1::ArchetypesController < ApplicationController
  respond_to :json

  def classify
    @deck = DeckClassification.new(
      decklist: params['decklist'],
      source_ip: request.remote_ip
    )
    respond_to do |format|
      if params['format_name']
        f=Format.where(name: params['format_name']).first
        if f
          @deck.format = f
        else
          format.json { render json: {error: "Format not found: #{params['format_name']}"}, status: :unprocessable_entity }
          return
        end
      end

      if @deck.save
        begin
          client = TfArchetypeClient.new
          res = client.query([@deck.deck_list])[0]
          @at, val = res[:predicted], res[:score]
        rescue => e
          flash[:error] = "Error in classification"
          Rails.logger.error e.message
          e.backtrace.each { |line| Rails.logger.error line }
          raise e unless Rails.env.production?
        end

        format.json { render json: {
          archetype: {
            name: @at.name
          },
          score: val
        }, 
        status: :created }
      else
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

end

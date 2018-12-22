class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'

    # callbackアクションのCSRFトークン認証を無効
    protect_from_forgery :except => [:callback]

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
    
    def callback
      body = request.body.read
  
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
        error 400 do 'Bad Request' end
      end
  
      events = client.parse_events_from(body)
  
      events.each { |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: event.message['text'] + "べし"
            }
            client.reply_message(event['replyToken'], message)
          when Line::Bot::Event::MessageType::Location
            latitude_reverse = (event.message['latitude'] * -1).to_s
            if event.message['longitude'].to_f >= 0
              longitude_reverse = (event.message['longitude'] - 180).to_s
            else
              longitude_reverse = (180 - (event.message['longitude'] * -1)).to_s
            end
            logger.info("latitude:" + latitude_reverse)
            message = {
              type: "location",
              title: "地球の裏側",
              address: event.message['address'],
              latitude: latitude_reverse,
              longitude: longitude_reverse
            }
            client.reply_message(event['replyToken'], message)
          end
        end
      }
  
      head :ok
    end
end

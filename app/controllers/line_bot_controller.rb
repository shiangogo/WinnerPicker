class LineBotController < ApplicationController
  require "json"

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }

          if event.message['text'].start_with?('抽') && event['source']['type'] == 'group'
            input_string = event.message['text'].sub(/^抽\s*/, "")
            if input_string.blank?
              return
            end
            names_and_weights = input_string.split.map do |pair|
              if pair.include?(':')
                name, weight = pair.split(':')
                weight = weight.try(:to_i) || 1
                next [name, weight]
              end
              next [pair, 1]
            end
            total_weight = names_and_weights.map { |pair| pair[1] }.sum
            random_number = rand(0...total_weight)

            selected_name = nil
            current_weight = 0
            names_and_weights.each do |pair|
              current_weight += pair[1]
              if random_number < current_weight
                selected_name = pair[0]
                break
              end
            end
            client.reply_message(event['replyToken'], {type: "text", text: "抽到的是#{selected_name}，恭喜恭喜！"})
          end
        end
      end
    end
    render status: 200
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_ACCESS_TOKEN"]
    end
  end
end

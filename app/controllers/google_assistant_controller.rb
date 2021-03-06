class GoogleAssistantController < ApplicationController

  def conversation
    puts "REQUEST PARAMS:"
    puts params.as_json

    assistant_response = GoogleAssistant.respond_to(params, response) do |assistant|

      puts "user_id: #{assistant.user.id}"
      puts "state: #{assistant.conversation.state}"
      puts "data: #{assistant.conversation.data}"
      puts "arguments:"
      assistant.arguments.each do |argument|
        puts "    #{argument.text_value}"
      end

      assistant.intent.main do
        assistant.conversation.state = "asking name permission"

        assistant.ask_for_permission("To know who you truly are", GoogleAssistant::Permission::NAME)
      end

      assistant.intent.permission do
        if !assistant.permission_granted?
          assistant.tell("<speak>Aw man, you don't trust me?</speak>")
        else

          case assistant.conversation.state
          when "asking name permission"
            if assistant.permission_granted?
              assistant.conversation.data["name"] = assistant.user.given_name
            end

            assistant.conversation.state = "asking coarse location"

            assistant.ask_for_permission("To know approximately where you are", GoogleAssistant::Permission::DEVICE_COARSE_LOCATION)
          when "asking coarse location"
            if assistant.permission_granted?
              assistant.conversation.data["zip_code"] = assistant.device.zip_code
              assistant.conversation.data["city"] = assistant.device.city
            end

            assistant.conversation.state = "asking precise location"

            assistant.ask_for_permission("To know where exactly you live", GoogleAssistant::Permission::DEVICE_PRECISE_LOCATION)
          when "asking precise location"
            if assistant.permission_granted?
              assistant.conversation.data["address"] = assistant.device.formatted_address
              assistant.conversation.data["coordinates"] = assistant.device.coordinates
            end

            assistant.conversation.state = "asking first word"

            thanks = "Thanks, #{assistant.conversation.data["name"]} from #{assistant.conversation.data["city"]}!"

            assistant.ask(
              "<speak>#{thanks} Say a word, please.</speak>",
              [
                "<speak>What was that?</speak>",
                "<speak>Did you say something?</speak>"
              ]
            )
          else
            assistant.tell("<speak>The state must've gotten corrupted. Whoops!</speak>")
          end
        end
      end

      assistant.intent.text do
        case assistant.conversation.state
        when "asking first word"
          assistant.conversation.state = "asking second word"
          assistant.conversation.data["word"] = assistant.arguments[0].text_value

          assistant.ask(
            "<speak>Great! Now say another word, please.</speak>",
            [
              "<speak>What was that?</speak>",
              "<speak>Did you say something?</speak>"
            ]
          )
        when "asking second word"
          name = assistant.conversation.data["name"]
          thanks = name.present? ?
            "Thanks, #{name}!" :
            "Thanks!"
          assistant.tell("<speak>#{thanks} First you said #{assistant.conversation.data["word"]}, then you said #{assistant.arguments[0].text_value}!</speak>")
        else
          assistant.tell("<speak>The state must've gotten corrupted. Whoops!</speak>")
        end
      end
    end

    render json: assistant_response
  end
end

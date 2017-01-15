class GoogleAssistantController < ApplicationController

  def conversation
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
        assistant.conversation.state = "asking permission"

        assistant.ask_for_permission(context: "To know who you truly are", permissions: GoogleAssistant::Permission::NAME)
      end

      assistant.intent.permission do
        case assistant.conversation.state
        when "asking permission"
          if assistant.permission_granted?
            assistant.conversation.data["name"] = assistant.user.given_name
          end

          assistant.conversation.state = "asking first word"

          thanks = assistant.conversation.data["name"].present? ?
            "Thanks, #{assistant.conversation.data["name"]}!" :
            "Thanks!"

          assistant.ask(
            prompt: "<speak>#{thanks} Say a word, please.</speak>",
            no_input_prompt: [
              "<speak>What was that?</speak>",
              "<speak>Did you say something?</speak>"
            ]
          )
        else
          assistant.tell("<speak>The state must've gotten corrupted. Whoops!</speak>")
        end
      end

      assistant.intent.text do
        case assistant.conversation.state
        when "asking permission"
          assistant.conversation.state = "asking first word"

          assistant.ask(
            prompt: "<speak>Thanks! Say a word, please.</speak>",
            no_input_prompt: [
              "<speak>What was that?</speak>",
              "<speak>Did you say something?</speak>"
            ]
          )
        when "asking first word"
          assistant.conversation.state = "asking second word"
          assistant.conversation.data["word"] = assistant.arguments[0].text_value

          assistant.ask(
            prompt: "<speak>Great! Now say another word, please.</speak>",
            no_input_prompt: [
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

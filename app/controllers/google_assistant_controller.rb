class GoogleAssistantController < ApplicationController

  def conversation
    puts params.as_json

    assistant_response = GoogleAssistant.new(params, response).respond_to do |assistant|

      puts "state: #{assistant.conversation.state}"
      puts "data: #{assistant.conversation.data}"
      puts "arguments:"
      assistant.arguments.each do |argument|
        puts "    #{argument.text_value}"
      end

      assistant.intent.main do
        assistant.conversation.state = "init"

        assistant.ask(
          prompt: "<speak>Hi there! Say a word, please.</speak>",
          no_input_prompt: [
            "<speak>What was that?</speak>",
            "<speak>Did you say something?</speak>"
          ]
        )
      end

      assistant.intent.text do
        if assistant.conversation.state == "init"
          assistant.conversation.state = "step two"
          assistant.conversation.data["word"] = assistant.arguments[0].text_value

          assistant.ask(
            prompt: "<speak>Great! Now say another word, please.</speak>",
            no_input_prompt: [
              "<speak>What was that?</speak>",
              "<speak>Did you say something?</speak>"
            ]
          )
        elsif assistant.conversation.state == "step two"
          assistant.tell("<speak>Thanks! First you said #{assistant.conversation.data["word"]}, then you said #{assistant.arguments[0].text_value}!</speak>")
        end
      end
    end

    render assistant_response
  end
end

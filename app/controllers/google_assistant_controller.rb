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
        input_prompt = assistant.build_input_prompt(
          true,
          "<speak>Hi there! Say a word, please.</speak>",
          ["<speak>What was that?</speak>", "<speak>Did you say something?</speak>"]
        )

        assistant.conversation.state = "init"

        assistant.ask(input_prompt)
      end

      assistant.intent.text do
        if assistant.conversation.state == "init"
          assistant.conversation.state = "step two"
          assistant.conversation.data["word"] = assistant.arguments[0].text_value

          input_prompt = assistant.build_input_prompt(
            true,
            "<speak>Great! Now say another word, please.</speak>",
            ["<speak>What was that?</speak>", "<speak>Did you say something?</speak>"]
          )

          assistant.ask(input_prompt)
        elsif assistant.conversation.state == "step two"
          assistant.tell("<speak>Thanks! First you said #{assistant.conversation.data["word"]}, then you said #{assistant.arguments[0].text_value}!</speak>")
        end
      end
    end

    render assistant_response
  end
end

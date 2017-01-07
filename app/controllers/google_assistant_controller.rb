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
          "<speak>Say something please?</speak>",
          ["<speak>What was that?</speak>", "<speak>Did you say something?</speak>"]
        )

        assistant.conversation.state = "this is a state"
        assistant.conversation.data["something"] = "or other"

        assistant.ask(input_prompt)
      end

      assistant.intent.text do
        assistant.tell("<speak>I heard you! You said #{assistant.arguments[0].text_value}!</speak>")
      end
    end

    render assistant_response
  end
end

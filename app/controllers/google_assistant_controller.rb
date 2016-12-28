class GoogleAssistantController < ApplicationController

  def conversation
    puts params.as_json

    assistant_response = GoogleAssistant.new(params).respond_to do |assistant|
      assistant.intent.main do
        logger.debug("main intent")
        input_prompt = assistant.build_input_prompt(true, "<speak>Say something please?</speak>", ["<speak>What was that?</speak>"])
        assistant.ask(input_prompt, { "this is data" => "yes, it is"}.as_json.to_s)
      end

      assistant.intent.text do
        logger.debug("text intent")
        assistant.tell("<speak>I heard you!</speak>")
      end
    end

    render assistant_response
  end
end

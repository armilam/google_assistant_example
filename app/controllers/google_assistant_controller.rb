require "#{Rails.root}/lib/google-assistant-ruby/google_assistant"

class GoogleAssistantController < ApplicationController

  def conversation
    puts params.as_json

    assistant_response = GoogleAssistant.new(params).respond_to do |assistant|
      assistant.intent.main do
        logger.debug("main intent")
        assistant.tell("<speak>I can speak!</speak>")
      end

      assistant.intent.text do
        logger.debug("text intent")
      end
    end

    render assistant_response
  end
end

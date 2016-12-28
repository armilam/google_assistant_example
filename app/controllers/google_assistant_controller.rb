class GoogleAssistantController < ApplicationController

  def conversation
    logger.debug(params)

    assistant_response = GoogleAssistant.new(params).respond_to do |intent|
      intent.main do
        logger.debug("main intent")
      end

      intent.text do
        logger.debug("text intent")
      end
    end

    render assistant_response
  end
end

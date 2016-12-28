# frozen_string_literal: true

class GoogleAssistant
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def respond_to(&block)
    yield(intent)

    {
      json: {
        status: :ok
      }.as_json
    }
  end

  private

  def intent
    @_intent ||= Intent.new("???")
  end
end

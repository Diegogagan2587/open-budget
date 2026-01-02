# frozen_string_literal: true

class AddButtonComponent < ViewComponent::Base
  def initialize(label:, path:)
    @label = label
    @path  = path
  end
end

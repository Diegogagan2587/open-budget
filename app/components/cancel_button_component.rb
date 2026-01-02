# frozen_string_literal: true

class CancelButtonComponent < ViewComponent::Base
  def initialize(path:, label: "Cancel")
    @path = path
    @label = label
  end

  def classes
    "px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400"
  end
end


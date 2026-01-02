# frozen_string_literal: true

class AddButtonComponent < ViewComponent::Base
  def initialize(label:, path:)
    @label = label
    @path  = path
  end

  def classes
   "px-4 py-2 bg-gradient-to-r from-green-500 to-green-600 text-white rounded shadow-md hover:shadow-lg hover:from-green-600 hover:to-green700 transition-all duration-200 flex items-center gap-2"
  end
end

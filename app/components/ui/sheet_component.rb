# frozen_string_literal: true

module Ui
  class SheetComponent < ViewComponent::Base
    def initialize(title: nil, description: nil)
      @title = title
      @description = description
    end
  end
end

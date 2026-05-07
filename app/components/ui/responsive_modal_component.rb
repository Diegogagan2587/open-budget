# frozen_string_literal: true

module Ui
  class ResponsiveModalComponent < ViewComponent::Base
    def initialize(title: nil, description: nil)
      @title = title
      @description = description
    end
  end
end

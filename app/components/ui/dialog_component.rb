# frozen_string_literal: true

module Ui
  class DialogComponent < ViewComponent::Base
    def initialize(title: nil, description: nil, show: false)
      @title = title
      @description = description
      @show = show
    end
  end
end

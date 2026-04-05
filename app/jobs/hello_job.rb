class HelloJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "[HelloJob]: Hi! how are you doing?"
  end
end

class HelloJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "[HeloJob] Hi from hello job"
    # we console.log if we are on development
    if Rails.env.development?
      puts "[HelloJob]: Hi from Hello job"
    end
  end
end

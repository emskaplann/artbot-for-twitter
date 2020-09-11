require 'clockwork'
require 'active_support/time'
require './artbot.rb'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  # this where i configure the interval for posting tweets
  every(3.hour, 'ArtBot posting tweet rn.') {ArtBot.run}
  # every(3.minutes, 'less.frequent.job')
  # every(1.hour, 'hourly.job')

  # every(1.day, 'midnight.job', :at => '00:00')
end

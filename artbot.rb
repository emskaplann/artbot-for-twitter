require 'twitter'
require 'pry'
require 'json'
require 'rest-client'
require 'mechanize'
require 'dotenv'
Dotenv.load

class ArtBot

  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["A_CONSUMER_KEY"]
    config.consumer_secret     = ENV["A_CONSUMER_SECRET_KEY"]
    config.access_token        = ENV["A_ACCESS_TOKEN"]
    config.access_token_secret = ENV["A_ACCESS_SECRET_TOKEN"]
  end

  @my_tweets = @client.user_timeline(1211824798239621120).map(&:text).join(' ')

  def self.get_photos
      @randNumber = rand(1..10)
      @page_token = ""
      while @randNumber != 0 do
        response_str = RestClient.get("https://www.wikiart.org/en/api/2/MostViewedPaintings?paginationToken=#{@page_token}")
        @page_token = JSON.parse(response_str)["paginationToken"]
        if @randNumber == 1
          return JSON.parse(response_str)
        else
          @randNumber -= 1
        end
      end
  end

  def self.download_photo(link)
    agent = Mechanize.new
    agent.get(link).save"./images/#{File.basename(link)}"
    return "./images/#{File.basename(link)}"
  end

  def self.run
    @photos = ArtBot.get_photos
    x = 1
    while x == 1 do
      @photo = @photos["data"][rand(0..@photos["data"].length)]
      if @my_tweets.include?(@photo["title"])
        @photo = @photos["data"][rand(0..@photos["data"].length)]
      else
        x = 0
      end
    end
    @local_path = ArtBot.download_photo(@photo["image"])
    @client.update_with_media("#{@photo["title"]} \n -#{@photo["completitionYear"]}, #{@photo["artistName"]} \n #art #paintings ##{@photo["artistName"].split().join('').downcase}", @local_path)
  end

  # binding.pry
  # 0
end

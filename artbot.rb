require 'twitter' # to interact with the Twitter's API
require 'pry' # for debugging
require 'json' # for parsing the response i get from the WikiArt's API
require 'rest-client' # for making a GET request to the WikiArt's API
require 'mechanize' # for downloading a painting with a link onto our local server
require 'dotenv' # for hiding sensitive twitter credentials i use to access my account
Dotenv.load

# main objective on this project is to fetch a painting from the WikiArt API's Most Viewed Category and post it on my Twitter Account
class ArtBot

  # creating the twitter client & using credentials from dotenv
  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["A_CONSUMER_KEY"]
    config.consumer_secret     = ENV["A_CONSUMER_SECRET_KEY"]
    config.access_token        = ENV["A_ACCESS_TOKEN"]
    config.access_token_secret = ENV["A_ACCESS_SECRET_TOKEN"]
  end

  # main challenge in this project is to post a painting that i didn't post in last 20 days

  # i'm collecting the text i used on our tweets, since our tweets contains the title of the paintings,...
  # ... i can check if i ever posted the same painting on our twitter account by checking the title of the painting
  # i fetch last 160 tweet which means 20 day because the bot is configured to post 8 posts a day with a 3 hour interval
  @my_tweets = @client.user_timeline(1211824798239621120, options: {count: 160}).map(&:text)

  # after fetching the last 20 day's tweets i need to create helper functions for splitting the work load

  # STEPS #
  # 1- Get paintings
  # 2- Select an unposted painting
  # 3- Download the selected painting
  # 4- And post the painting to the Twitter

  # i created all my functions as a class function because I don't need to create instances in order to achieve my goal
  # fetching paintings from WikiArt's API, this function doesn't return 100% unique paintings, because there is a limit on request to their API
  def self.get_paintings
      # assigning a random number in order to decide how many page i will inquiry from the API
      @rand_number = rand(1..10)
      # declaring a page token variable because their API asks for the token on the previous page, so i need to store it as i pass through pages
      @page_token = ""
      while @rand_number != 0 do
        response_str = RestClient.get("https://www.wikiart.org/en/api/2/MostViewedPaintings?paginationToken=#{@page_token}") # making the request to the API
        @page_token = JSON.parse(response_str)["paginationToken"] # parsing the pagination token for further requests
        if @rand_number == 1 # when our random number value is equal to 1 this means that i completed the process and i should return our response
          return JSON.parse(response_str)
        else # i decrease the value of our random variable as i move to the next page
          @rand_number -= 1
        end
      end
  end

  def self.select_an_unposted_painting(paintings)
    @x = 1 # i declare this variable to check whether i found an unposted painting or not
    @y = 1 # i declare this variable to check whether i found an untried random number
    @tried_numbers = [] # i store all the numbers i tried, to not check the array with a number i already tried

    while x == 1 && @tried_numbers.length != paintings["data"].length do # while i don't have a unique painting i'll check the paintings array with a new random number
      while y == 1 do
        @rand_number = rand(0..paintings["data"].length)
        if @tried_numbers.include?(@rand_number) # if i tried the random number, i need to try with another random number
          # just need to try again with a new random number
        else
          y = 0 # else means that i found an untried number, so i can exit the while loop
        end
      end
      @painting = paintings["data"][@rand_number] # selecting a painting from the paintings array with an untried random number
      if @my_tweets.include?(@painting["title"]) # i check if i posted this painting
        @tried_numbers.push(@rand_number) # if i already posted it, i add the number to "tried_numbers" so i can check with an untried number
      else
        x = 0 # in this case else mean either i found an unposted painting or i tried every possible random number
      end
    end

    if @tried_numbers.length == paintings["data"].length # i check if our while loop ended after trying all possible random numbers
      @painting = paintings["data"][rand(0..paintings["data"].length)] # if it did, this means that the post i'm selecting here is already posted on our twitter account
      # this a very small possibility and it's not free to check more pages, that's why i didn't try to check another page from wikiart's api
    end

    return @painting
  end

  # this function is utilizing Mechanize Library in order to download the painting i selected from the API
  def self.download_painting(link)
    # creating an instance of Mechanize Class
    agent = Mechanize.new
    # using the get() & save() functions of Mechanize Class - using them together gives us the downloaded painting on a local folder
    # i host my app on heroku, and they run an ephemeral file system - which means you can write files to the server, files are lost when dyno's are rebooted (every 24 hours) or when you deploy/restart you application. 
    # in our case 24 hours is more than enough to post tweets
    agent.get(link).save"./images/#{File.basename(link)}"
    # i'm returning the new downloaded paintings location to use it on our tweet
    return "./images/#{File.basename(link)}"
  end

  # the function where i call the helper functions & create a execution flow
  def self.run
    @paintings = ArtBot.get_paintings # i'm calling the pre defined function for fetching paintings from the WikiArt's API
    @painting = ArtBot.select_an_unposted_painting(@paintings) # i'm trying to select a painting that i didn't post it before, however there is a small possiblity to repost a painting
    @local_path = ArtBot.download_painting(@painting["image"]) # i'm downloading the selected painting
    # and finally i post a tweet with the selected painting!
    @client.update_with_media("#{@painting["title"]} \n -#{@painting["completitionYear"]}, #{@painting["artistName"]} \n #art #paintings ##{@painting["artistName"].split().join('').downcase}", @local_path)
  end

  # binding.pry
  # 0
end

require 'twitter'
require 'pry'
require 'json'
require 'ibm_watson'
require 'dotenv'
Dotenv.load
include IBMWatson
include Twitter

  @visual_recognition = IBMWatson::VisualRecognitionV3.new(
    version: "2018-03-19",
    iam_apikey: ENV["IBM_WATSON_API_KEY"]
  )

  # Classifier Id => Baddiesv2_1513509502

  # binding.pry
  # 0

  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["B_CONSUMER_KEY"]
    config.consumer_secret     = ENV["B_CONSUMER_SECRET_KEY"]
    config.access_token        = ENV["B_ACCESS_TOKEN"]
    config.access_token_secret = ENV["B_ACCESS_SECRET_TOKEN"]
  end

  @current_user_id = @client.user.id

  # binding.pry
  # 0

  ### -START- first search query - 1 - ###
    begin
      @client.search("from:AIIBaddie OR from:baddiesmilfTR OR from:baddiespor min_faves:100 -filter:retweet filter:media", result_type: "recent").take(12).collect do |tweet|
          if @client.retweeters_of(tweet, {ids_only: true}).include?(@current_user_id)
            puts "already retweeted."
            sleep(3)
          else
            begin
              @client.retweet(tweet)
              # where the rating starts
                @four_image_total_rate = 0
                tweet.media.each do |photo|
                  begin
                    @response = @visual_recognition.classify(
                      url: photo.media_url.to_s,
                      classifier_ids: ["Baddiesv2_1513509502"],
                      threshold: 0.0
                    )
                    @response.result["images"].each do |img|
                      @max_result_for_two_class = img["classifiers"][0]["classes"].max_by do |efso|
                        efso["score"]
                      end
                      @four_image_total_rate += @max_result_for_two_class["score"]
                    end
                  rescue
                    puts "Something Was Wrong With IBM Watson"
                    sleep(2)
                  end
                end
                @rating_result = ((@four_image_total_rate / tweet.media.length) * 10).to_s.chars.first(3).join
              # where the rating ends
              @client.fav(tweet)
              sleep(0.5)
              @client.update("@#{tweet.user.screen_name} biz, #{@rating_result} diyoruz. -beta v1.0.2", {in_reply_to_status: tweet})
              puts "new retweet created."
              sleep(3)
            rescue
              puts "already retweeted / type2"
              sleep(3)
            end
          end
      end
      puts "one round completed"
    rescue Twitter::Error::TooManyRequests
      puts "something was wrong with the request"
      sleep error.rate_limit.reset_in + 1
    end
  ### - END - first search query - 1 - ###

  ### -START- second search query - 2 - ###
    begin
      @client.search("from:BaddiesAllround OR from:BaddieGods min_faves:100 -filter:retweet filter:media", result_type: "recent").take(12).collect do |tweet|
          if @client.retweeters_of(tweet, {ids_only: true}).include?(@current_user_id)
            puts "already retweeted."
            sleep(3)
          else
            begin
              @client.retweet(tweet)
              # where the rating starts
               @four_image_total_rate = 0
               tweet.media.each do |photo|
                 begin
                   @response = @visual_recognition.classify(
                     url: photo.media_url.to_s,
                     classifier_ids: ["Baddiesv2_1513509502"],
                     threshold: 0.0
                   )
                   @response.result["images"].each do |img|
                     @max_result_for_two_class = img["classifiers"][0]["classes"].max_by do |efso|
                       efso["score"]
                     end
                     @four_image_total_rate += @max_result_for_two_class["score"]
                   end
                 rescue
                   puts "Something Was Wrong With IBM Watson"
                   sleep(2)
                 end
               end
               @rating_result = ((@four_image_total_rate / tweet.media.length) * 10).to_s.chars.first(3).join
              # where the rating ends
              @client.fav(tweet)
              sleep(0.5)
              @client.update("@#{tweet.user.screen_name} biz, #{@rating_result} diyoruz. -beta v1.0.2", {in_reply_to_status: tweet})
              puts "new retweet created."
              sleep(3)
            rescue
              puts "already retweeted / type2"
              sleep(3)
            end
          end
      end
      puts "one round completed"
    rescue Twitter::Error::TooManyRequests
      puts "something was wrong with the request"
      sleep error.rate_limit.reset_in + 1
    end
  ### -END- second search query - 2 - ###

  ### -START- third search query for #rateme - 3 - ###
  begin
    @client.search("#rateme -filter:retweet filter:media", lang: "tr", result_type: "recent").take(10).collect do |tweet|
        if @client.retweeters_of(tweet, {ids_only: true}).include?(@current_user_id)
          puts "already retweeted."
          sleep(3)
        else
          begin
            # where the rating starts
             @four_image_total_rate = 0
             tweet.media.each do |photo|
               begin
                 @response = @visual_recognition.classify(
                   url: photo.media_url.to_s,
                   classifier_ids: ["Baddiesv2_1513509502"],
                   threshold: 0.0
                 )
                 @response.result["images"].each do |img|
                   @max_result_for_two_class = img["classifiers"][0]["classes"].max_by do |efso|
                     efso["score"]
                   end
                   @four_image_total_rate += @max_result_for_two_class["score"]
                 end
               rescue
                 puts "Something Was Wrong With IBM Watson"
                 sleep(2)
               end
             end
             @rating_result = ((@four_image_total_rate / tweet.media.length) * 10).to_s.chars.first(3).join
            # where the rating ends
            if ((@four_image_total_rate / tweet.media.length) * 10) > 5
              @client.retweet(tweet)
              @client.fav(tweet)
            else
              #do nothing just reply
            end

            sleep(0.5)
            @client.update("@#{tweet.user.screen_name} biz, #{@rating_result} diyoruz. -beta v1.0.2", {in_reply_to_status: tweet})
            puts "new retweet created."
            sleep(3)
          rescue
            puts "already retweeted / type2"
            sleep(3)
          end
        end
    end
    puts "one round completed"
  rescue Twitter::Error::TooManyRequests
    puts "something was wrong with the request"
    sleep error.rate_limit.reset_in + 1
  end
  ### -END- third search query for #rateme - 3 - ###

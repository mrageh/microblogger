require "jumpstart_auth"
require "pry"
require "certified"
require 'bitly'

class MicroBlogger
  attr_reader :client
  attr_reader :friends

  def initialize
    @client = JumpstartAuth.twitter
    @friends = client.friends
  end

  def tweet(message)
    send_tweet(message)
    puts "Posted tweet: #{message}"
  end

  def send_tweet(message)
    if message.length <= 140
      client.update(message)
    else
      puts "Sorry, your message is too long, please keep it below 140 characters!! "
    end
  end

  def direct_message(username, message)
    if my_followers.include?(username)
      puts "Sending a DM to #{username} with content \"#{message}\""
      send_tweet("dm #{username} #{message}")
    else
      puts "You can only send direct messages to followers "
    end
  end

  def sorted_friends
    friends.sort_by { |a| a.screen_name.downcase }
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"

    Bitly.use_api_version_3

    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts bitly.shorten(original_url).short_url
  end

  def everyones_last_tweet
    sorted_friends.each do |user|
      puts ""
      puts "#{user.status.text}"
      time = user.status.created_at
      nice_time = time.strftime("%A, %b %d")
      puts "at #{nice_time}"
      puts "by #{user.name} (@#{user.screen_name})"
    end
  end

 def my_followers
    followers = client.followers
    followers.collect do |f|
      f.screen_name
    end
  end

  def spam(message)
    my_followers.each do |follower|
      direct_message(follower, message)
    end
  end

  def run
    puts "Welcome to MicroBlogger!"
    command = ""

    until command == "q"
      printf "enter command:"
      input = gets.chomp
      parts = input.split
      command = parts[0]
      username = parts[1]
      original_url = parts[-1]
      puts "Got command: #{command.inspect}"

      case command
        when 'q' then
          quit
        when 't' then
          tweet_message(message)
        when 'dm' then
          message = parts[2..-1].join(" ")
          direct_message(username, message)
        when 'f' then
          puts my_followers
        when 'spam' then
          message = parts[1..-1].join(" ")
          spam(message)
        when 'elt' then
          everyones_last_tweet
        when 's' then
          shorten(original_url)
        when 'turl'
          tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        else
          puts "Sorry I don't how to '#{command}'"
      end
    end
  end

  def tweet_message(message)
    message = parts[1..-1].join(" ")
    tweet(message)
  end

  def quit
    puts 'Goodbye!'
  end

end

mb = MicroBlogger.new
mb.run

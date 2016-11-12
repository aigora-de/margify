require 'octokit'
require 'csv'

# The user includes a keyword argument to seed the user network, e.g. 'bitcoin'
subject, page = ARGV
users = Hash.new
user_count =0

client = Octokit::Client.new(:login => 'user.name', :password => 'password')

# Search GitHub users with the keyword 'subject'
puts "Querying GitHub users for " + subject + "..."
results = client.search_users(subject)
total_count = results.total_count
last_response = client.last_response
number_of_pages = last_response.rels[:last].href.match(/page=(\d+).*$/)[1]
puts "There are #{total_count} users over #{number_of_pages} pages!"

f1 = open(subject+".csv", 'w')
f2 = open(subject+"_followers.csv", 'w')
csv1 = CSV.new(f1, headers: true)
csv2 = CSV.new(f2, headers: true)
items = results.items
headers = client.user(items[0].login).to_h.keys
csv1 << headers
csv2 << ["follower_id", "following_id"]
until last_response.rels[:next].nil?
  items.each { |i|
    if users.key?(i.id) then
      puts i.login + ' already added!'
    else
      user = client.user(i.login)
      users[i.id] = user.to_h.values
      user_count = user_count + 1
    end

    # Get i.login's followers
    followers = client.followers(i.login)
    followers.each {|f|
      csv2 << [f.id, i.id]
      if users.key?(f.id) then
        puts f.login + ' already added!'
      else
        user = client.user(f.login)
        users[f.id] = user.to_h.values
        user_count = user_count + 1
      end
    }

    # Get i.login's followings
    followings = client.following(i.login)
    followings.each {|f|
      csv2 << [i.id, f.id]
      if users.key?(f.id) then
        puts f.login + ' already added!'
      else
        user = client.user(f.login)
        users[f.id] = user.to_h.values
        user_count = user_count + 1
      end
    }
  }
  last_response = last_response.rels[:next].get
  items = last_response.data.items
end
puts users.count.to_s + ' users added!'
puts user_count.to_s + ' users counted!'
users.each_value {|value| csv1 << value }
csv1.close
csv2.close
f1.close
f2.close

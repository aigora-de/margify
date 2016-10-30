require 'octokit'

# The user includes a keyword argument to seed the user network, e.g. 'bitcoin'
#subject, output = ARGV
subject = ARGV.first


client = Octokit::Client.new :access_token => ENV['YOUR TOKEN HERE']

# Search GitHub users with the keyword 'subject'
puts subject
results = client.search_users(subject)
total_count = results.total_count
last_response = client.last_response
puts "There are #{total_count} results!"
number_of_pages = last_response.rels[:last].href.match(/page=(\d+).*$/)[1]

users_file = open(subject+".txt", 'w')
followers_file = open(subject+"_followers.txt", 'w')
following_file = open(subject+"_following.txt", 'w')
#puts "There are #{total_count} results, on #{number_of_pages} pages!"
items = results.items
#items[0].each { |h| users_file.write ( "#{h[0]}," ) }
users_file.write("login,id,score\n")
until last_response.rels[:next].nil?
  #users_file.write("\n")
  items.each { |i|
    followers_file.write("#{i.login}, #{i.id}, #{i.followers_url}\n")
    following_file.write("#{i.login}, #{i.id}, #{i.following_url}\n")
    #users_file.write ("[\n")
    #i.each { |j| users_file.write ( "#{j[1]}," ) }
    users_file.write("#{i.login},#{i.id},#{i.score}\n")
    #users_file.write ("\n")
  }
  last_response = last_response.rels[:next].get
  items = last_response.data.items
end
users_file.close
followers_file.close
following_file.close

#file = open(output, 'w')
#puts "There are #{total_count} results, on #{number_of_pages} pages!"
#items = results.items
#until last_response.rels[:next].nil?
#  items.each { |i| file.write( "#{i.login}, #{i.followers_url}\n" ) }
#  last_response = last_response.rels[:next].get
#  items = last_response.data.items
#end
#file.close

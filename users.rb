require 'octokit'

subject, output = ARGV

client = Octokit::Client.new :access_token => ENV['YOUR TOKEN']
results = client.search_users(subject)
total_count = results.total_count
last_response = client.last_response
number_of_pages = last_response.rels[:last].href.match(/page=(\d+).*$/)[1]

file = open(output, 'w')
puts "There are #{total_count} results, on #{number_of_pages} pages!"
items = results.items
until last_response.rels[:next].nil?
  #items.each { |i| file.write( "#{i.login}, #{i.followers_url}\n" ) }
  items.each { |i|
    file.write ( "[\n" )
    i.each { |j| file.write ( "#{j}\n" ) }
    file.write ( "]\n" )
  last_response = last_response.rels[:next].get
  items = last_response.data.items
end
file.close

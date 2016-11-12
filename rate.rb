require 'octokit'
require 'rest-client'
require 'json'

client = Octokit::Client.new(:login => 'user.name', :password => 'password') #:token = 'YOUR-TOKEN')
rate = client.rate_limit
puts rate

response = RestClient.get('https://api.github.com/rate_limit?client_id=&client_secret=')
json = JSON.parse(response)
jj json
puts json.fetch("resources").fetch("core").fetch("reset") - Time.now.to_i

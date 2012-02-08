# average_time_to_load.rb
require 'open-uri'

time_start = Time.now
url = ARGV[0]
raise "Ops.  Please call me with a URI." if url.nil?
puts "Fetching #{url}..."
5.times do
	open(url).read
end
puts "Took an average of #{((Time.now-time_start)/5).to_i.to_s}s to load 5 times."
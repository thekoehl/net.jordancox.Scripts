require "rubygems"
require "active_record"

require 'digest/md5'
require 'uri'
require 'open-uri'

require 'time'
require 'date'

class TestTwitter < Thor
	desc "list_members LIST_SLUG OWNER_NAME", "Count the members!"
	def list_members(list_slug, owner_name)
		members_uri = "https://api.twitter.com/1/lists/members.json?slug=#{list_slug}&owner_screen_name=#{owner_name}&skip_status=true"
		members = list_members_recursive(members_uri, -1)

		puts "You've got #{members.count.to_s} members on your list."
	end
	desc "list_members_recursive MEMBERS_URI CURSOR_START", "Count the members fully!"
	def list_members_recursive(members_uri, current_cursor)		
		content = ""
		members = []
		begin
		    open(members_uri + "&cursor=" + current_cursor.to_s) do |s| content = s.read end
		    puts "Fetched #{members_uri + "&cursor=" + current_cursor.to_s} as #{Digest::MD5.hexdigest(content)}."
			members_json = ActiveSupport::JSON.decode(content)
			count = members_json['users'].length
			members = members_json['users'].map do |m|
				m['from_user']
			end

			unless members_json['next_cursor'].nil? || members_json['next_cursor'] == '' || members_json['next_cursor'] == 0 || members_json['next_cursor'] == '0'
				members += list_members_recursive members_uri, members_json['next_cursor']
			end
		rescue OpenURI::HTTPError
			puts "Aw, there was an error fetching the http stream from Twitter.  Probably too many connections.  Gonna wait around a bit."
			puts "Incidentally, we were trying to fetch #{members_uri + "&cursor=" + current_cursor.to_s}."

			rate_limit_uri = "https://api.twitter.com/1/account/rate_limit_status.json"
			content = ""
			open(rate_limit_uri) do |s| content = s.read end
			rate_limit = ActiveSupport::JSON.decode(content)
			puts rate_limit.to_s
		end
		return members
	end
end
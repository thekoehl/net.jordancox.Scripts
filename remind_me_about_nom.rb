require 'rubygems'
require 'mechanize'
require 'yaml'

LOGIN_URI = 'https://nom.nerdery.com/Nom/index/login'
ORDER_URI = 'https://nom.nerdery.com/Nom/Ordering/list-order'

class RemindMeAboutNom
	def initialize
		config_path = File.expand_path('~/.remind_me_about_nom.conf')
		raise "Could not locate configuration file at #{config_path}" unless File.exists? config_path
		config = YAML::load( File.open( config_path ) )
		@username = config['username']
		@password = config['password']
		raise "Could not locate username in configuration file." if @username.nil?
		raise "Could not locate password in configuration file." if @password.nil?
	end	
	def remind_me_if_needed
		if has_ordered_today?
			`/usr/bin/osascript -e 'tell application "System Events" to display alert "You have ordered today.  Good job!"'`
		else
			`/usr/bin/osascript -e 'tell application "System Events" to display alert "OMG YOU HAVE NOT ORDERED FOOD.  GOGOGOGOGOGOGOO!!"'`
		end
	end
private
	def has_ordered_today?
		a = Mechanize.new

		a.get(LOGIN_URI) do |login_page|
			login_form = login_page.forms[0]
			login_form.userName = @username
			login_form.password = @password
			
			splash_page = login_form.submit

			order_page = a.click splash_page.link_with(:text => /View/)
			confirmed_link = order_page.link_with :text => /Delete/
			return !confirmed_link.nil?
		end
	end		
end

app = RemindMeAboutNom.new
app.remind_me_if_needed
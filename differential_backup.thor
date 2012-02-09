require "rubygems"
require "active_record"
require "action_pack"
require "action_view"

require 'digest/md5'
require 'uri'
require 'open-uri'

require 'time'
require 'date'
require 'yaml'



class DifferentialBackup < Thor
	desc "backup", "Backup all the things!"
	def backup
		config = YAML::load( File.open( '/Users/jordantcox/Desktop/differential_backup.yml' ) )
		dp = DifferentialBackupProgram.new config
		dp.perform_backup
	end
end

class DifferentialBackupProgram
	def initialize config
		validate_and_set_parameters config
	end
	def perform_backup
		total_bytes_sent = 0
		timestamp = Time.now.strftime("%Y%m%d-%H.%M")
		@destinations.each do |destination|
			create_destination! destination + "/current"
			@sources.each do |source|
				dhash = DifferentialBackupProgram.get_destination_hash destination
				link_dest = "--link-dest=#{dhash[:directory]}/current"

				rsync_cmd = "#{@rsync_location} #{@rsync_options} #{link_dest} #{source} #{destination}/#{timestamp} 2>&1"
				Logger.log "Beginning backup of [source: #{source}, destination: #{destination}]..."
				Logger.log "- exec: #{rsync_cmd}"
				output = `#{rsync_cmd}`
				errors = get_errors output
				if errors.length > 0
					Logger.log "ERROR: " + errors[0]
					next			
				end
				bytes_sent = get_bytes_sent output				
				Logger.log "#{bytes_sent/1024/1024} Mbytes Sent."
				rotate_latest_as_current destination, timestamp
			end
		end
	end
	def self.is_destination_remote? destination
		return destination.include? "@"
	end
	def self.get_destination_hash destination
		match = destination.match(/(.*?)@(.*?)\:(.*)/)
		unless match && match.length == 4
			raise "Could not properly split apart remote destination #{destination}"
		end
		return {:username => match[1], :host => match[2], :directory => match[3]}
	end
private
	def create_destination! destination
		if DifferentialBackupProgram.is_destination_remote? destination
			destination_hash = DifferentialBackupProgram.get_destination_hash destination
			ssh_cmd = "ssh #{destination_hash[:username]}@#{destination_hash[:host]} mkdir -p #{destination_hash[:directory]}/current 2>&1"
			Logger.log("- exec: #{ssh_cmd}")
			results = `#{ssh_cmd}`
			if $?.exitstatus > 0
				puts results
				raise "Could not create remote directory #{destination_hash.inspect}"
			end
		else
			unless Dir.exists? destination
				Logger.log("#{destination} did not exist, creating it now...")
				FileUtils.mkdir_p destination
			end
		end
	end
	def get_bytes_sent output
		match = output.match(/sent ([0-9]+)/)
		return 0 unless match && match.length > 0
		return match[1].to_i
	end
	def get_errors output
		match = output.match(/.*? does not exist.*?/)
		return [] unless match && match.length > 0

		return [match.to_s]
	end
	def rotate_latest_as_current destination, timestamp
		destination_hash = DifferentialBackupProgram.get_destination_hash destination
		ssh_cmd = "ssh #{destination_hash[:username]}@#{destination_hash[:host]} rm -rf #{destination_hash[:directory]}/current 2>&1"
		Logger.log("- exec: #{ssh_cmd}")
		results = `#{ssh_cmd}`
		if $?.exitstatus > 0
			puts results
			raise "Could not rm remote current directory #{destination_hash.inspect}"
		end
		ssh_cmd = "ssh #{destination_hash[:username]}@#{destination_hash[:host]} ln -s #{destination_hash[:directory]}/#{timestamp} #{destination_hash[:directory]}/current 2>&1"
		Logger.log("- exec: #{ssh_cmd}")
		results = `#{ssh_cmd}`
		if $?.exitstatus > 0
			puts results
			raise "Could not link directory #{destination_hash.inspect}"
		end
	end
	def validate_and_set_parameters config
		config['sources'].each do |dir|
			raise "Source directory '#{dir}' does not exist." unless Dir.exists? dir
		end
		@sources = config['sources']

		raise "Rsync does not exist at the specified location." unless File.exists? config['rsync_location']
		@rsync_location = config['rsync_location']
		@rsync_options = config['rsync_options']
		@destinations = config['destinations']
	end
end
class Logger
	def self.log message
		puts "[#{Time.now.strftime("%Y%m%d-%H.%M")}] #{message}"
	end
end
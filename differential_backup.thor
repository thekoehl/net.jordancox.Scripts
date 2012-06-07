# Filename:  		differential_backup.thor
# Author: 			Jordan T. Cox
# Creation Date: 	2012-06-06
# Description:      A really simple to use differential backup task that uses rsync
# 					to provide cross-platform backups locally and remotely.
# 					
# 					Wanna install this to cron and are using rvm?  This'll help.
#  1 # Minute  Hour   Day of Month   Month              Day of Week        Command    
#  2 # (0-59)  (0-23)  (1-31)        (1-12 or Jan-Dec)  (0-6 or Sun-Sat)   
#  3   46      20      *             *                  *                  (/bin/bash -l -c 'thor differential_backup:backup') &> /var/log/backup.log

require "rubygems"
require "active_record"
require "action_pack"
require "action_view"
require 'iconv'

require 'digest/md5'
require 'uri'
require 'open-uri'

require 'time'
require 'date'
require 'yaml'

class DifferentialBackup < Thor
	desc "backup", "Backup all the things!"
	def backup
		config = YAML::load( File.open( '/etc/differential_backup.cfg' ) )
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
			dhash = DifferentialBackupProgram.get_destination_hash destination
			if DifferentialBackupProgram.is_destination_remote?(destination) && !Ping.is_up?(dhash[:host])
				Logger.log "#{dhash[:host]} was not up.  Skipping backing up to this destination."
				next
			end
			
			create_destination! destination + "/current"
			@sources.each do |source|
				link_dest = "--link-dest=#{dhash[:directory]}/current"

				rsync_cmd = "#{@rsync_location} #{@rsync_options} #{@excludes} #{link_dest} #{source} #{destination}/#{timestamp} 2>&1"
				Logger.log "Beginning backup of [source: #{source}, destination: #{destination}]..."
				Logger.log "- exec: #{rsync_cmd}"
				output = `#{rsync_cmd}`
				output = String.to_valid_utf8(output)
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
		if self.is_destination_remote? destination
			match = destination.match(/(.*?)@(.*?)\:(.*)/)
			unless match && match.length == 4
				raise "Could not properly split apart remote destination #{destination}"
			end
			raise "Destination was empty." if match[3].nil? || match[3] == ""
			return {:username => match[1], :host => match[2], :directory => match[3]}
		else
			raise "Destination was empty." if destination.nil? || destination == ""
			return {:username => nil, :host => nil, :directory => destination}
		end
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
		is_remote = DifferentialBackupProgram.is_destination_remote? destination
		destination_hash = DifferentialBackupProgram.get_destination_hash destination		
		cmd = ""
		if is_remote
			cmd = "ssh #{destination_hash[:username]}@#{destination_hash[:host]} rm -rf #{destination_hash[:directory]}/current 2>&1"
		else
			cmd = "rm -rf #{destination_hash[:directory]}/current 2>&1"
		end
		Logger.log("- exec: #{cmd}")
		results = `#{cmd}`
		if $?.exitstatus > 0
			puts results
			raise "Could not rm remote current directory #{destination_hash.inspect}"
		end
		if is_remote
			cmd = "ssh #{destination_hash[:username]}@#{destination_hash[:host]} ln -s #{destination_hash[:directory]}/#{timestamp} #{destination_hash[:directory]}/current 2>&1"
		else
			cmd = "ln -s #{destination_hash[:directory]}/#{timestamp} #{destination_hash[:directory]}/current 2>&1"
		end
		Logger.log("- exec: #{cmd}")
		results = `#{cmd}`
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
		@excludes = config['excludes']
	end
end
class Logger
	def self.log message
		puts "[#{Time.now.strftime("%Y%m%d-%H.%M")}] #{message}"
	end
end
class Ping
	def self.is_up? host
		ping_count = 2
		server = host
		result = `ping -q -c #{ping_count} #{server}`
		if ($?.exitstatus == 0)
		  return true
		end
		return false
	end
end
class String
	def self.to_valid_utf8(str)
		ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
		valid_string = ic.iconv(str + ' ')[0..-2]

		return valid_string
	end
end

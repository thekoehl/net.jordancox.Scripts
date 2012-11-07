require "rubygems"

require "yaml"

class Monicle < Thor
	desc "update_datapoints", "Update the configured datapoints."
	def update_datapoints
		@config = YAML::load( File.open( File.expand_path("~/.monicle.yml") ) )
        load_and_validate_config
        @sensors.each do |sensor|
            puts "- Polling for #{sensor['name']}"
            puts "- exec: #{sensor['script']}"
            results = `#{sensor['script']}`.strip!
            if $?.exitstatus > 0
                raise "Could not completely execute #{sensor['script']}.  Output from the command is found above."
            end
            send_data_to_monocle sensor, results
            puts "    ! Received #{results}#{sensor['units']} back."
        end
	end
private
    def load_and_validate_config
        @api_location = @config['api_location']
        @api_key = @config['api_key']
        @sensors = @config['sensors']
        raise "No  API location specified" unless @api_location && @api_location.length > 0
        raise "No API key specified" unless @api_key && @api_key.length > 0
        raise "No sensors specified" unless @sensors && @sensors.length > 0
    end
    def send_data_to_monocle sensor, value
        cmd = "curl -d \"data_point[value]=#{value}&sensor[name]=#{sensor['name'].gsub(' ', '%20')}&user[api_key]=#{@api_key}&data_point[reporter]=192.168.2.1&data_point[units]=#{sensor['units']}\" #{@api_location}/data_points"
        puts cmd
        results = `#{cmd}`
        puts results
        if $?.exitstatus > 0 || !results.include?("success\":true")
            raise "Could not update a sensor.  Output from the command is found above."
        end
        return true
    end
end

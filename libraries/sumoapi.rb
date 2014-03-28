require 'chef/recipe'
require 'json'
require 'rest-client'

class Chef::Recipe::Sumo

  #Create RestClient object using Sumologic api URL and username/password from databag
  def self.api_conn( username, password )
    apibaseurl = "https://api.sumologic.com/api"

    RestClient::Resource.new( apibaseurl, username, password )
  end

  def self.get_collector( conn, name )
    collectorshref = "/v1/collectors"

    allcollectors = JSON.parse( conn[collectorshref].get )["collectors"]
    collectors = allcollectors.select { |item| item["name"] == name }

    if collectors.count == 1
      collector = collectors[0]
    else
      raise "Unable to match collector or matched more than one"
    end

    collector
  end
  
  #Get existing source list from the API
  def self.get_sources( conn, collector )
    JSON.parse( conn[self.source_href( collector )].get )["sources"]
  end
  
  #Get sources defined by Chef from JSON file
  def self.find_sources( filename )
    JSON.parse( File.read( filename ) )["sources"]
  end
  
  #Determine the actions necessary to converge the existing sources with the sources defined in Chef.  Return Array of sources each with :apiaction key.
  def self.sources_diff( target, existing )
    changes = Array.new

    #Iterate through the target sources to determine which are new, updated or unchanged.  Push new and updated to "changes" array.
    target.each do |targetsrc|
      matchsrcs = existing.select { |item| item["name"] == targetsrc["name"] }

      case matchsrcs.count
      when 0
        Chef::Log.info( "New Sumologic source: #{ targetsrc["name"] }" )
        targetsrc[:apiaction] = :create
        changes.push( targetsrc )
      when 1
        %w(remoteHost remotePort remoteUser remotePassword keyPath keyPassword remotePath authMethod logNames domain username password hosts protocol port commands file workingDir timeout script cronExpression pathExpression blacklist name description category hostName timeZone automaticDateParsing multilineProcessingEnabled useAutolineMatching manualPrefixRegexp forceTimeZone defaultDateFormat filters sourceType).each do |fieldname|
          if matchsrcs[0][fieldname] != targetsrc[fieldname]
            Chef::Log.info( "Changed Sumologic source: #{targetsrc["name"]}" )
            targetsrc['id'] = matchsrcs[0]['id']
            targetsrc[:changedelement] = fieldname
            targetsrc[:apiaction] = :update
            changes.push( targetsrc )
            break
          end
        end
      else
        Chef::Log.warn( "Something weird happened, ignoring source #{ matchsrcs[0]['name'] } because there are multiple" )
      end
    end
    
    #Iterate through existing sources to determine which are no longer defined by Chef.  Push removals to "changes" array.
    existing.each do |existingsrc|
      matchsrcs = target.select { |item| item["name"] == existingsrc["name"] }

      if matchsrcs.count < 1
        Chef::Log.info( "Unwanted Sumologic source: #{ existingsrc["name"] }" )
        existingsrc[:apiaction] = :delete
        changes.push( existingsrc )
      end
    end
    changes
  end

  def self.create_source( conn, collector, src )
    var = Hash.new
    var["source"] = src
    conn[self.source_href( collector )].post var.to_json, :content_type => "application/json"
  end

  def self.update_source( conn, collector, src )
    var = Hash.new
    var["source"] = src
    etag = conn["/v1/collectors/#{ collector['id'] }/sources/#{src['id']}"].get.headers[:etag]
    apitarget = self.source_href( collector ) + "/" + src['id'].to_s
    conn[apitarget].put var.to_json, { :content_type => "application/json", "if-match" => etag }
  end

  def self.delete_source( conn, collector, src )
    apitarget = self.source_href( collector ) + "/" + src['id']
    conn[apitarget].delete
  end

  #Reusable method to get sources path for a collector
  def self.source_href( coll )
    collectorsources = coll["links"].select { |item| item["rel"] == "sources" }
    collectorsources[0]["href"]
  end

end
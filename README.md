sumologic-collector Cookbook
============================
This cookbook installs the Sumo Logic collector on Linux using the shell script
installer or RPM installer for RHEL, CentOS, Scientific and Fedora. Here are the steps it follows:

1. Sets up `sumo.conf` and `sumo.json` with standard Linux logs
2. Downloads latest installer
3. Runs installer
4. Starts collector and registers with the Sumo Logic service
5. Adds, removes and updates sources as configured using the Sumologic API

The collector Requires outbound access to https://collectors.sumologic.com.
Add the appropriate sumo-* recipe to your run list to add default system logs.  Additionally,
use the sumologic-collector_source resource provided to configure additional logs in any recipe.
After installation you can [test connectivity](https://service.sumologic.com/ui/help/Default.htm#Testing_Connectivity.htm).


Installation
------------
1. Create an [Access Key](http://help.sumologic.com/i19.69v2/Default.htm#Generating_Collector_Installation_API_Keys.htm)
2. Install the cookbook in your Chef repo:

```knife cookbook github install SumoLogic/sumologic-collector-chef-cookbook```

3. Specify data bag and item with your access credentials.  The data item should
contain attributes `accessID` and `accessKey`.  The default data bag/item is
`['sumo-creds']['api-creds']`

4. Upload the cookbook to your Chef Server:

```knife cookbook upload sumologic-collector```

5. Add the `sumologic-collector` receipe to your node run lists.  This step depends
on your node configuration, so specifics will not be described in this README.md.

6. Add appropriate sources as necessary useing the sumologic-collector_source resource.

Attributes
----------

<table>
  <tr>
    <td>['sumologic']['ephemeral']</td>
    <td>Boolean</td>
    <td>Sumo Logic Ephemeral Setting</td>
    <td>Required</td>
  </tr>
  <tr>
    <td>['sumologic']['installDir'] </td>
    <td>String</td>
    <td>Sumo Logic Install Directory</td>
    <td>Required</td>
  </tr>
  <tr>
    <td>['sumologic']['credentials']['bag_name']</td>
    <td>String</td>
    <td>Name of the data bag.</td>
    <td>Required</td>
  </tr>
  <tr>
    <td>['sumologic']['credentials']['item_name']</td>
    <td>String</td>
    <td>Name of the item within the data bag. </td>
    <td>Required</td>
  </tr>
  <tr>
    <td>['sumologic']['credentials']['secret_file']</td>
    <td>String</td>
    <td>Path to the local file containing the encryption secret key.</td>
    <td>Optional</td>
  </tr>
  <tr>
    <td>['sumologic']['sources']</td>
    <td>String</td>
    <td>Manually specified source list using JSON syntax</td>
    <td>Optional</td>
  </tr>
</table>

Resources/Providers
------------
### source

This resource will configure the locally installed SumoLogic collector with the specified source.  This is dependant on the sumologic-collector::sumojson recipe being part of your node's run list (this is automatically added by the sumologic-collector::default recipe if node['sumologic']['sources'] == nil).  The recipe will aggregate the sources and configure the sumo.json file and call the sumoapi recipe to update the collector via the API.

#### Actions
- :create - Configures a Sumologic source.

#### Parameter attributes:
- `sourceType` - Specify the type of SumoLogic source: "LocalFile" , "RemoteFile" , "LocalWindowsEventLog" , "RemoteWindowsEventLog" , "Syslog" , "Script"
# Please see the SumoLogic documentation for the appropriate attributes below: https://service.sumologic.com/ui/help/Default.htm#Using_JSON_to_configure_Sources.htm
- `remoteHost`
- `remotePort`
- `remoteUser`
- `remotePassword`
- `keyPath`
- `keyPassword`
- `remotePath`
- `authMethod`
- `logNames`
- `domain`
- `username`
- `password`
- `hosts`
- `protocol`
- `port`
- `commands`
- `file`
- `workingDir`
- `timeout`
- `script`
- `cronExpression`
- `pathExpression`
- `blacklist`
- `name`
- `description`
- `category`
- `hostName`
- `timeZone`
- `automaticDateParsing`
- `multilineProcessingEnabled`
- `useAutolineMatching`
- `manualPrefixRegexp`
- `forceTimeZone`
- `defaultDateFormat`
- `filters`

Contributing
------------
This cookbook is meant to help customers use Chef to install Sumo Logic
collectors, so please feel to fork this repository, and make whatever changes
you need for your environment.


License and Authors
-------------------
Authors:
	Ben Newton (ben@sumologic.com)
  Peter Bell (bellpeterm+github@gmail.com)

actions :create
default_action :create

# Refer to SumoLogic documentation for additional information on attributes: https://service.sumologic.com/ui/help/Default.htm#Using_JSON_to_configure_Sources.htm

attribute :remoteHost                 , :kind_of => String , :required => true #Host name of remote machine.
attribute :remotePort                 , :kind_of => Fixnum , :default => 22 #Port of remote machine (SSH)
attribute :remoteUser                 , :kind_of => String #User account to connect with the remote machine.
attribute :remotePassword             , :kind_of => String #Password used to connect to remote machine. Required only when authMethod is set to "password".
attribute :keyPath                    , :kind_of => String #Path to SSH key used to connect to the remote machine. Required only when authMethod is set to "key".
attribute :keyPassword                , :kind_of => String #Password to SSH key to connect to the remote machine, required only with authMethod is set to "password".
attribute :remotePath                 , :kind_of => String , :required => true #Path of the file on the remote machine that will be collected.
attribute :authMethod                 , :kind_of => String , :default => "password" , :equal_to => [ "password" , "key" ] #Authentication method used to connect to the remote machine. Options are "password" to connect with a password, or "key" to connect with an SSH key.
attribute :logNames                   , :kind_of => Array , :required => true #List of Windows log types to collect. For example, "Security", "Application", etc.
attribute :domain                     , :kind_of => String , :required => true #Windows domain from which logs will be created.
attribute :username                   , :kind_of => String , :required => true #User name needed to connect to the remote machine.
attribute :password                   , :kind_of => String , :required => true #Password needed to connect to the remote machine.
attribute :hosts                      , :kind_of => Array , :required => true #List of hosts to collect from.
attribute :protocol                   , :kind_of => String , :equal_to => [ "TCP" , "UDP" ] #Protocol that syslog should use. Default is UDP; TCP is also supported.
attribute :port                       , :kind_of => Fixnum , :default => 514 #Port that syslog should use to collect to the machine.
attribute :commands                   , :kind_of => Array , :required => true #List of command-line arguments.
attribute :file                       , :kind_of => String #Path to script file to run
attribute :workingDir                 , :kind_of => String #Working directory for commands/script.
attribute :timeout                    , :kind_of => Fixnum #Script timeout (in milliseconds). By default, this is set to 0.
attribute :script                     , :kind_of => String #Script contents (if no file is provided).
attribute :cronExpression             , :kind_of => String , :required => true #Schedule for running the script. Must be a valid Quartz cron expression.
attribute :pathExpression             , :kind_of	=> String , :required => true # A valid path expression of the file to collect.
attribute :blacklist                  , :kind_of => Array , :default => Array.new # Array of strings, list of valid path expressions that will not be collected from.
attribute :name                       , :kind_of => String , :required => true , :name_attribute => true # Name of the Source.
attribute :description                , :kind_of => String # No 	Description of the Source.
attribute :category                   , :kind_of => String # Describes the category type of the Source.
attribute :hostName                   , :kind_of => String # The host name of the Source.
attribute :timeZone                   , :kind_of => String # Type the time zone you'd like the Source to use. For example, "UTC".
attribute :automaticDateParsing       , :kind_of => [ TrueClass, FalseClass ] , :default => true# Set true to enable automatic parsing of dates; type false to disable. Sumo's default setting is true; if disabled no timestamp information is parsed at all.
attribute :multilineProcessingEnabled , :kind_of => [ TrueClass, FalseClass ] , :default => false # Set true to enable; type false to disable. Sumo's default setting is true. Set to false avoid unnecessary processing if you are collecting single-message-per-line files (for example, Linux system.log). Set true if you're working with multi-line messages (for example, log4J or exception stack traces).
attribute :useAutolineMatching        , :kind_of => [ TrueClass, FalseClass ] , :default => false # Set true to enable; set false to disable. Sumo's default setting is true but API returns false if multilineprocessing enabled is false so this default is easier on the sumoapi cookbook library.
attribute :manualPrefixRegexp         , :kind_of => String  # Type a regular expression for the prefix of a message.
attribute :forceTimeZone              , :kind_of => [ TrueClass, FalseClass ] , :default => false	# Set true to force the Source to use a specific time zone. Sumo's default setting is false.
attribute :defaultDateFormat          , :kind_of => String # Type the default format for dates used in your logs. See Supported Time Stamp Conventions.
attribute :filters                    , :kind_of => Array , :default => Array.new # If you'd like to add a filter to the Source, type the name of the filter ("Exclude", "Include", "Mask", or "Hash"). See the Collector Management API Read Me for more information.
attribute :sourceType                 , :kind_of => String , :equal_to => [ "LocalFile" , "RemoteFile" , "LocalWindowsEventLog" , "RemoteWindowsEventLog" , "Syslog" , "Script" ] , :required => true

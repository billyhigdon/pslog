# pslog
PowerShell Logging Module

Feeble attempt to write a logging module for consistency

`set-pslog` allows you to define a logfile location, and a loglevel for controlling depth of logging.

example:

`set-pslog -logfile "c:\temp\test.log" -loglevel information`

the previous will set the log file location and will only out (to both console and file) errors, warnings and information.

you can check the value of the config using

`get-pslog`

To write a log use:

`write-pslog error "this is an error"`

or...

`write-pslog information "this is information"`

or...

`write-pslog debug "this is debug"
(will only display if proper log level is set


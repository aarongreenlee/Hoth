<!--- Place code here that should be executed on the "onRequestStart" event. --->
	
	<cfscript>
        // Place Hoth into Application Memory.
          	if (!structKeyExists(application, 'HothTracker'))
		{
			application.HothTracker =
				new Hoth.HothTracker( new config.HothConfig() );
		}
 
        // anything you need here...
 
        return true;
    </cfscript>
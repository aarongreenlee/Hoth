<!--- Place HTML here that should be displayed when an error is encountered while running in "production" mode. --->
    <cfscript>
        // Create an instance of Hoth if one does not exist in the
        // application scope. Hoth should exist in the Application Scope
        // but, if something went wrong there we are ensured tracking.
		arguments.Except = arguments.exception;
		arguments.EventName = arguments.eventName;
        local.HothTracker = (structKeyExists(application, 'HothTracker'))
            ? application.HothTracker
            : new Hoth.HothTracker( new config.HothConfig() );
 
        local.HothTracker.track(Except);
    </cfscript>

<h1>Error!</h1>
<p>
	Sorry, that caused an unexpected error.<br />
	Please try again later.
</p>
<cfscript>

	// Using Hoth with ColdFusion
	try {
		a = undefined;
	} catch (any e) {
		new Hoth.HothTracker().track(e);
	}

</cfscript>
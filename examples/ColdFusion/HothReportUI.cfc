// This CFC offers no protection--thus, anyone can access this.
// You can implement this by renaming the CFC with a UUID--that can secure
// this through obscurity. But, I prefer the approach shown in the ColdBox
// example. That is what I use. I have not tried this code :(

// You should replace the "new Hoth.config.HothConfig()" lines with the
// classname path to your HothConfig. Hoth will generate a report for the
// application's HothConfig you provide.

// -----------------------------------------------------------------------
// 					THIS IS AN EXAMPLE AND ONLY AN EXAMPLE
// -----------------------------------------------------------------------
// HOW YOU IMPLEMENT REPORTING IS REALLY YOUR BUSINESS SINCE NO ONE SHOULD
// ACCESS YOUR REPORT--OR KNOW HOW TO ACCESS YOUR REPORT--BUT YOU!!!!!!!!!
//
// This CFC should work right out of the box for the Example HOTH data.
// You will need to change the path to your config for sure.
//
// Feel free to add anything else you want (password/IP check?) to this file
// as it should become part of your code base.

component {

	// You will definitely want to change this path...
	variables.ApplicationsHothConfig = new Hoth.config.HothConfig();

	/** Loads the Web UI (HTML) **/
	remote function index () returnformat='plain' {
		local.HothReport = new Hoth.HothReporter(variables.ApplicationsHothConfig);
		return local.HothReport.getReportView();
	}

	/** Access Hoth report data as JSON.
		@exception 	If not provided a list of exceptions will be returned.
					If provided, the value should be an exception hash which
					modified the behavior to return information for only
					that exception. **/
	remote function report (string exception) returnformat='JSON' {
		local.report = (structKeyExists(arguments, 'exception')
		? arguments.exception
		: 'all');

		local.HothReport = new Hoth.HothReporter(variables.ApplicationsHothConfig);
		return local.HothReport.report(local.report);
	}

	/** Delete a report. **/
	remote function delete (string exception)returnformat='JSON'  {
		if (!structKeyExists(arguments, 'exception'))
		{
			// We can delete all exceptions at once!
			arguments.exception = 'all';
		}

		local.HothReport = new Hoth.HothReporter(variables.ApplicationsHothConfig);

		// Delete!
		return local.HothReport.delete(arguments.exception);
	}
}
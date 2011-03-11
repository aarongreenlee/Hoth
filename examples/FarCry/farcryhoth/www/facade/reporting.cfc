component output="false" {

	remote function index() output="false" returntype="string" returnformat="plain" {
		return application.hoth.report.getReportView(application.hoth.config);
	}

	remote function report(string exception = 'all') output="false" returntype="struct" returnformat="json" {
		return application.hoth.report.report(exception = arguments.exception);
	}

	remote function delete(string exception = 'all') output="false" returntype="array" returnformat="json" {
		return application.hoth.report.delete(exception = arguments.exception);
	}
	
}
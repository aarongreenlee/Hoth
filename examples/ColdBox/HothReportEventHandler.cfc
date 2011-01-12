/**
	Example Event Handler to report Hoth exceptions from within your
	existing ColdBox application. To use this, just set up the following route.

	addRoute(pattern		= 'hoth/:action?'
			,handler		= 'HothReportEventHandler');
*/

component {

	public void function preHandler(required Event)
	{
		var rc = Event.getCollection();
		var prc = Event.getCollection(private=true);

		// Only allow access to this report if we are
		// in debug mode.
		if (!getDebugMode())
		{
			setNextEvent('home');
		}

		// This line assumes you have your HothConfig within the config
		// directory of your ColdBox application.
		prc.HothReporter = new Hoth.HothReporter( new config.HothConfig() );
	}


	public void function index (required Event) {
		var rc = Event.getCollection();
		var prc = Event.getCollection(private=true);

		Event.setView(name='site/hoth',noLayout=true);
		Event.renderData(type='html',data=prc.HothReporter.getReportView());

		return;
	}
	public void function report (required Event) {
		var rc = Event.getCollection();
		var prc = Event.getCollection(private=true);

		local.report = (structKeyExists(rc, 'exception')
		? rc.exception
		: 'all');

		Event.renderData(type='json',data=prc.HothReporter.report(local.report));

		return;
	}
	public void function delete (required Event) {
		var rc = Event.getCollection();
		var prc = Event.getCollection(private=true);

		if (!structKeyExists(rc, 'exception'))
		{
			rc.exception = 'all';
		}

		local.result = prc.HothReporter.delete(rc.exception);

		Event.renderData(type='json',data=local.result);
		return;
	}
}
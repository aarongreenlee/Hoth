component
	implements='Hoth.iHothConfig'
	accessors=true {

	property name='applicationName' 		default='HothUnitTests';
	property name='timeToLock' 				default='2';
	property name='logPath' 				default='/Hoth/_test/logs';
	property name='ReportPassword' 			default='password';

	property name='EmailNewExceptions' 		default='true';
	property name='EmailNewExceptionsTo' 	default='aarongreenlee@gmail.com';
	property name='EmailNewExceptionsFrom' 	default='aarongreenlee@gmail.com';
	property name='EmailNewExceptionsFile' 	default='true';

	/** Construct a configuration object for Hoth. */
	public Hoth.iHothConfig function init () {
		local.md = getMetadata(this);
		local.n = arrayLen(local.md.properties);
		for (local.i=1; local.i <= local.n; local.i++) {
			local.fn = this['set' & local.md.properties[local.i].name];
			local.fn(local.md.properties[local.i]['default']);
		}

		return this;
	}

	public string function getLogPathExpanded () {
		return expandPath( getLogPath() );
	}

	/** Return a path for Hoth. */
	public string function getPath (name) {
		switch (arguments.name) {
			// Sub-Directories
			case 'incidents' :
			case 'exceptions' :
				return getLogPathExpanded() & '/' & lcase(arguments.name);
			break;

			// Files
			case 'exceptionIndex' :
			case 'exceptionReport' :
			case 'exceptionReportActivity' :
				return getLogPathExpanded() & '/' & lcase(arguments.name) & '.log';
			break;
		}
	}

}

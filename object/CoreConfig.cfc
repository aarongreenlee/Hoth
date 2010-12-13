/**
	Aaron Greenlee
	http://aarongreenlee.com/

	This work is licensed under a Creative Commons Attribution-Share-Alike 3.0
	Unported License.

	// Original Info -----------------------------------------------------------
	Author			: Aaron Greenlee
	Created      	: 10/01/2010

	Core configuration object for Hoth. This object provides all the
	functionality for a Hoth Config Object. Individual implementations should
	extend this object and provide their own values within the property
	declaration.

*/
component
{
	/** Construct a configuration object for Hoth. */
	public Hoth.object.iHothConfig function init ()
	{
		local.md = getMetadata(this);
		local.n = arrayLen(local.md.properties);
		for (local.i=1; local.i <= local.n; local.i++) {
			local.fn = this['set' & local.md.properties[local.i].name];
			local.fn(local.md.properties[local.i]['default']);
		}
		return this;
	}

	/** Expands a path **/
	public string function getLogPathExpanded ()
	{
		return expandPath( getLogPath() );
	}

	/** Return a path for Hoth. */
	public string function getPath (name)
	{
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
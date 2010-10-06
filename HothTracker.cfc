/** Track errors within an application. */
component
name='HothTracker'
{

	public Hoth.HothTracker function init (HothConfig) {
		// If a config object was not provided we
		// will use our default.
		variables.Config = (structKeyExists(arguments, 'HothConfig'))
			? arguments.HothConfig
			: new Hoth.object.HothConfig();

		VARIABLES._NAME = 'Hoth_' & variables.Config.getApplicationName();

		variables.paths.LogPath 	= variables.Config.getLogPathExpanded();
		variables.paths.Exceptions 	= variables.Config.getPath('exceptions');				// Track the unique exceptions.
		variables.paths.Incidents 	= variables.Config.getPath('incidents');				// Track the hits per exception.
		variables.paths.Report 		= variables.Config.getPath('exceptionReport');			// The actual report
		variables.paths.Activity 	= variables.Config.getPath('exceptionReportActivity');	// Track when we save things. Helps understand volume.
		//variables.paths.Index 	= variables.Config.getPath('exceptionIndex');			// Tracks the exception keys to prevent duplication

		verifyDirectoryStructure();

		return this;
	}

	/** Track an exception.
		@ExceptionStructure A Struct with at least the following keys: 'detail,type,tagContext,StackTrace,Message' */
	public boolean function track (ExceptionStructure) {
		try {
		local.e = {
			 detail 	= structKeyExists(arguments.ExceptionStructure,'detail') ? arguments.ExceptionStructure.detail : '_noDetail'
			,message 	= structKeyExists(arguments.ExceptionStructure,'message') ? arguments.ExceptionStructure.message : '_noMessage'
			,stack 		= structKeyExists(arguments.ExceptionStructure,'stacktrace') ? arguments.ExceptionStructure.stacktrace : '_no_stacktrace'
			,context 	= structKeyExists(arguments.ExceptionStructure,'tagcontext') ? arguments.ExceptionStructure.tagcontext : '_no_tagcontext'
			,url		= CGI.HTTP_HOST & CGI.path_info
		};

		// Generate JSON for hashing
		local.json = {};
		local.k = '';
		for(local.k in local.e)
			local.json[k] = serializeJSON(local.e[local.k]);

		// Hash a unique key for the content of each property within the exception
		local.index = {};
		local.index.stack = ( len(local.e.stack) > 0) ? hash(lcase(local.e.stack),'SHA') : '_no_stack';
		local.index.key = local.index.stack;

		local.saveDetails = false;

		// Index the exception, count occurances and save details.
		// Lock is unique to the exception.
		lock name=local.index.key timeout=variables.Config.getTimeToLock() type="exclusive" {
			local.filename = local.index.key & '.log';
			local.exceptionFile = variables.paths.Exceptions & '\' & local.filename;
			local.incidentsFile = variables.paths.Incidents & '\' & local.filename;

			local.exceptionIsKnown = fileExists(local.exceptionFile);

			if (!local.exceptionIsKnown)
				fileWrite(local.exceptionFile ,serializeJSON(local.e),'UTF-8');


			// Create an incident if the file does not exist
			if (!fileExists(local.incidentsFile)) {
				fileWrite(local.incidentsFile ,now() & '#chr(13)#','UTF-8');
			} else {
				local.file = fileOpen(local.incidentsFile,'append','utf-8');
				fileWriteLine(local.file, now());
				fileClose(local.file);
			}
		}

		// Outside the lock, send mail if requested
		if (!local.exceptionIsKnown && variables.Config.getEmailNewExceptions() ) {
			local.emailBody = 'Hoth tracked a new exception (' & local.index.key & '). If you would like to view the exception outside of Hoth just copy and paste into Firebug''s console like so:#chr(13)##chr(13)#x={the contents of the file}#chr(13)##chr(13)#Then press CRTL+Enter and view the console.';

			local.Mail = new Mail(	 subject='Hoth Exception' & local.index.key
									,to=variables.Config.getEmailNewExceptionsTo()
									,from=variables.Config.getEmailNewExceptionsFrom());

			// Attach the file
			if ( variables.Config.getEmailNewExceptionsFile() )
				local.Mail.addParam(file=local.exceptionFile);

			local.Mail.addPart(type='text',charset='utf-8',wraptext=72,body=local.emailBody);

			local.mail.Send();
		}
		} catch (any e) {
			return false;
		}
		return true;
	}

	// Private Methods Follow -------------------------------------------------------
	private void function verifyDirectoryStructure() {
		// Verify our index diectory exists

		/** Ensure our directory structure is as expected. */
		lock name=VARIABLES._NAME timeout=variables.Config.getTimeToLock() type="exclusive" {
			if (!directoryExists(variables.paths.Exceptions)) {
				directoryCreate(variables.paths.Exceptions);
				fileWrite(variables.paths.Exceptions & '\_readme.txt','Hoth: The files within this directory contain the complete details for each unique exception.');
			}
			if (!directoryExists(variables.paths.Incidents)) {
				directoryCreate(variables.paths.Incidents);
				fileWrite(variables.paths.Exceptions & '\_readme.txt','Hoth: The files within this directory contain the details about the volume of errors for each unique exception.');
			}
		}

		return;
	}
}
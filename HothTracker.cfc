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

		variables.exceptionKeys 	= ['detail','type','tagcontext','stacktrace','message'];			// Required exception keys
		variables.paths.LogPath 	= variables.Config.getLogPathExpanded();				// Get the root location for our logging.
		variables.paths.Exceptions 	= variables.Config.getPath('exceptions');				// Track the unique exceptions.
		variables.paths.Incidents 	= variables.Config.getPath('incidents');				// Track the hits per exception.
		variables.paths.Report 		= variables.Config.getPath('exceptionReport');			// The actual report
		variables.paths.Activity 	= variables.Config.getPath('exceptionReportActivity');	// Track when we save things. Helps understand volume.
		//variables.paths.Index 	= variables.Config.getPath('exceptionIndex');			// Tracks the exception keys to prevent duplication

		verifyDirectoryStructure();

		return this;
	}

	/** Track an exception.
		@ExceptionStructure A ColdFusion cfcatch or a supported object from a Framework or Application. */
	public boolean function track (any Exception) {
		local.ExceptionStructure = parseException(arguments.Exception);

		// If we did not parse what we are supposed to
		// track, we will abort.
		if (!local.ExceptionStructure.validException)
			return false;

		// ------------------------------------------------------------------------------
		try {
		// ------------------------------------------------------------------------------
			local.e = {
				 detail 	= structKeyExists(local.ExceptionStructure,'detail') ? local.ExceptionStructure.detail : '_noDetail'
				,message 	= structKeyExists(local.ExceptionStructure,'message') ? local.ExceptionStructure.message : '_noMessage'
				,stack 		= structKeyExists(local.ExceptionStructure,'stacktrace') ? local.ExceptionStructure.stacktrace : '_no_stacktrace'
				,context 	= structKeyExists(local.ExceptionStructure,'tagcontext') ? local.ExceptionStructure.tagcontext : '_no_tagcontext'
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

					local.INetAddress = createObject( 'java', 'java.net.InetAddress' );

					local.url = (len(CGI.QUERY_STRING) > 0)
						? CGI.http_host & CGI.path_info & '?' & Cgi.QUERY_STRING
						: CGI.http_host & CGI.path_info;

					local.emailBody = [
						 "Hoth tracked a new exception (" & local.index.key & ")."
						,"Message: " & local.e.message
						,"Machine Name: " & local.INetAddress.getLocalHost().getHostName()
						,"Address: " & local.url
						,"To view the exception info attached copy and paste into FireBug's console (x = exception) and press CRTL+Enter."
					];

					local.Mail = new Mail(	 subject='Hoth Exception (' & cgi.HTTP_HOST & ') ' & local.index.key
											,to=variables.Config.getEmailNewExceptionsTo()
											,from=variables.Config.getEmailNewExceptionsFrom());

					// Attach the file
					if ( variables.Config.getEmailNewExceptionsFile() )
						local.Mail.addParam(file=local.exceptionFile);

					local.Mail.addPart(
						 type='text'
						,charset='utf-8'
						,wraptext=72
						,body=arrayToList(local.emailBody, "#chr(13)##chr(13)#")
					);

					local.mail.Send();
			}
		// ------------------------------------------------------------------------------
		} catch (any e) {
			if (structKeyExists(url, 'debugHoth')) {
				writeDump('Hoth Failed!');
				writeDump(e);
				abort;
			}
			return false;
		}
		// ------------------------------------------------------------------------------
		return true;
	}

	// Private Methods Follow -------------------------------------------------------
	/** Parse an exception provided by a framework or supported application.
		Hoth is easy to support. Just provide a Struct with at least the following keys:
			'detail,type,tagContext,StackTrace,Message'
		Or an object with the same information that Hoth can extract. */
	private struct function parseException(any Exception) {
		local.result = { validException = false };

		// A ColdFuson Exception Object
		if (isInstanceOf(arguments.Exception, 'java.lang.Exception') || isStruct(arguments.Exception)) {
			// Validate all our keys exist and this is not a normal struct.
			for (local.k in variables.exceptionKeys) {
				if (!structKeyExists(arguments.Exception, local.k))
					return local.result;
			}
			arguments.validException = true;

			// Return a struct
			local.result.detail 		= arguments.Exception.detail;
			local.result.message 		= arguments.Exception.message;
			local.result.stacktrace 	= arguments.Exception.stacktrace;
			local.result.tagcontext 	= arguments.Exception.tagContext;
			local.result.validException = true;
			return local.result;
		}

		// Support applications and frameworks that wrap
		// exceptions in their own unique way.
		if (isObject(arguments.Exception)) {
			local.md = getMetaData(arguments.Exception);
			//detail,type,tagcontext,stacktrace,message
			switch(local.md.fullname) {
				case 'coldbox.system.beans.ExceptionBean' :
					local.result.detail 	= arguments.Exception.getDetail();
					local.result.message 	= arguments.Exception.getMessage();
					local.result.stacktrace = arguments.Exception.getStackTrace();
					local.result.tagcontext = arguments.Exception.getTagContext();
					local.result.validException = true;
				break;
				case 'MachII.util.Exception' :
					local.result = arguments.Exception.getCaughtException();
					local.result.validException = true;
				break;
			}
		}
		return local.result;
	}


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
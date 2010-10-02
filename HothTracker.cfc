/** Track errors within an application. */
component
name='HothTracker'
{

	variables.Config = new Hoth.HothConfig();
	VARIABLES._NAME = variables.Config.getVersion();

	public Hoth.HothTracker function init () {
		verifyDirectoryStructure();
		paramLog();
		persistLog();

		return this;
	}

	/** Track an exception.
		@ExceptionStructure A Struct with at least the following keys: 'detail,type,tagContext,StackTrace,Message' */
	public void function track (ExceptionStructure) {

		// Build our index
		local.e = {
			 detail 	= structKeyExists(arguments.ExceptionStructure,'detail') ? arguments.ExceptionStructure.detail : '_noDetail'
			,message 	= structKeyExists(arguments.ExceptionStructure,'message') ? arguments.ExceptionStructure.message : '_noMessage'
			,stack 		= structKeyExists(arguments.ExceptionStructure,'stacktrace') ? arguments.ExceptionStructure.stacktrace : '_no_stacktrace'
			,context 	= structKeyExists(arguments.ExceptionStructure,'tagcontext') ? arguments.ExceptionStructure.tagcontext : '_no_tagcontext'
			,url		= CGI.HTTP_HOST & CGI.path_info
		};

		local.time = now();

		// Generate JSON for hashing
		local.json = {};
		local.k = '';
		for(local.k in local.e)
			local.json[k] = serializeJSON(local.e[local.k]);

		// Hash a unique key for the content of each property within the exception
		local.index = {};
		//local.index.detail = ( len(local.e.detail) > 0) ? hash(local.e.detail,'SHA-256') : '_no_detail';
		//local.index.message = ( len(local.e.message) > 0) ? hash(local.e.message,'SHA-256') : '_no_message';
		//local.index.context = ( arrayLen(local.e.context) > 0) ? hash(local.json.context,'SHA-256') : '_no_context';
		local.index.stack = ( len(local.e.stack) > 0) ? hash(lcase(local.e.stack),'SHA') : '_no_stack';
		//local.index.url = ( len(local.e.url) > 0) ? hash(local.e.url,'SHA-256') : '_no_path';
		local.index.key = local.index.stack;

		local.saveDetails = false;

		// Index the exception, count occurances and save details for fist-time encounters.
		lock name=VARIABLES._NAME timeout=variables.Config.getTimeToLock() type="exclusive" {
			// Update our hit counter tracking log entries
			application.HothShortTermMemory.hits++;

			// Don't save if we have this error in the index
			local.saveDetails = !structKeyExists(application.HothShortTermMemory.index, local.index.key);
			// Unless we don't have the file for some reason
			local.saveDetails = (fileExists(variables.paths.Exceptions & '\' & local.index.key & '.log')) ? local.saveDetails : true;

			if (local.saveDetails) {
				// create a new index entry
				application.HothShortTermMemory.index[local.index.key] = { count = 1, timestamp = [local.time] };
			} else {
				// Update our index
				application.HothShortTermMemory.index[local.index.key].count++;
				arrayAppend(application.HothShortTermMemory.index[local.index.key].timestamp, local.time);
				application.HothShortTermMemory.index[local.index.key].lastIncident = now();
			}
		}

		// Save the details of the exception.
		if (local.saveDetails)
			fileWrite(variables.paths.Exceptions & '\' & local.index.key & '.log' ,serializeJSON(local.e),'UTF-8');

		return;
	}

	// Private Methods Follow -------------------------------------------------------

	private void function verifyDirectoryStructure() {
		// Verify our index diectory exists
		variables.paths = {};

		variables.paths.LogPath 	= variables.Config.getLogPathExpanded();
		variables.paths.Exceptions 	= variables.Config.getPath('exceptions');				// Track the unique exceptions.
		variables.paths.Incidents 	= variables.Config.getPath('incidents');				// Track the hits per exception.
		variables.paths.Report 		= variables.Config.getPath('exceptionReport');			// The actual report
		variables.paths.Activity 	= variables.Config.getPath('exceptionReportActivity');	// Track when we save things. Helps understand volume.
		//variables.paths.Index 		= variables.Config.getPath('exceptionIndex');			// Tracks the exception keys to prevent duplication

		/** Ensure our directory structure is as expected. */
		lock name=VARIABLES._NAME timeout=variables.Config.getTimeToLock() type="exclusive" {
			if (!directoryExists(variables.paths.Exceptions)) {
				directoryCreate(variables.paths.Exceptions);
				fileWrite(variables.paths.Exceptions & '\_readme.txt','#VARIABLES._NAME#: The files within this directory contain the complete details for each unique exception.');
			}
			if (!directoryExists(variables.paths.Incidents)) {
				directoryCreate(variables.paths.Incidents);
				fileWrite(variables.paths.Exceptions & '\_readme.txt','#VARIABLES._NAME#: The files within this directory contain the details about the volume of errors for each unique exception.');
			}
		}

		/** Ensure our activity log is valid. */
		lock name=VARIABLES._NAME timeout=variables.Config.getTimeToLock() type="exclusive" {
			local.reportCreated = false;
			if (!fileExists(variables.paths.Report)) {
				local.reportCreated = true;
				fileWrite(variables.paths.Report, '', 'utf-8');
			}

			local.createActivityLog = (fileExists(variables.paths.Activity)) ? false : true;

			if (local.reportCreated && !local.createActivityLog)
				local.activityContents = {trigger = 'Report Created', timestamp = now()};
			else if (!local.reportCreated && local.createActivityLog)
				local.activityContents = {trigger = 'Report Existed--Activity Log Created.', timestamp = now()};
			else
				local.activityContents = {trigger = 'Report and Activity Log Created', timestamp = now()};

			if (local.createActivityLog)
				fileWrite(variables.paths.Activity, serializeJSON(local.activityContents), 'utf-8');
			else if (local.reportCreated) {
				local.file = fileOpen(variables.paths.Activity,'append','utf-8');
				fileWriteLine(local.file, serializeJSON(local.activityContents));
				fileClose(local.file);
			}
		}
		return;
	}

	private void function persistLog() {
		lock name=VARIABLES._NAME timeout=variables.Config.getTimeToLock() type="exclusive" {
			timeDemandSave = dateDiff('n',application.HothShortTermMemory.lastSave,now()) >= variables.Config.getSaveAfterXMin();
			hitsDemandSave = application.HothShortTermMemory.hits >= variables.Config.getSaveAfterXHits();

			if (timeDemandSave || hitsDemandSave) {

				// Remove timestamps first
				for(local.k in application.HothShortTermMemory.index) {
					if (structKeyExists(application.HothShortTermMemory.index[local.k], 'timestamp')) {
						local.file = fileOpen(variables.paths.Incidents & '/' & local.k & '.log','append','utf-8');
						fileWriteLine(local.file,serializeJSON(application.HothShortTermMemory.index[local.k].timestamp));
						fileClose(local.file);
						arrayClear(application.HothShortTermMemory.index[local.k].timestamp);
					}
				}

				if (timeDemandSave && hitsDemandSave)
					local.saveTrigger = 'time and hits';
				else
					local.saveTrigger = (timeDemandSave) ? 'time' : 'hits';

				arrayAppend(application.HothShortTermMemory.saves, {trigger = local.saveTrigger, timestamp = now()});

				fileWrite(variables.paths.Report,serializeJSON(application.HothShortTermMemory.index),'UTF-8');

				local.file = fileOpen(variables.paths.Activity,'append','utf-8');
				fileWriteLine(local.file, serializeJSON({trigger = local.saveTrigger, timestamp = now()}));
				fileClose(local.file);

				// Reset triggers
				application.HothShortTermMemory.lastSave = now();
				application.HothShortTermMemory.hits = 0;
			}
		}
		return;
	}

	/** Create empty log files as needed. */
	private void function paramLog() {
		lock name=VARIABLES._NAME timeout=variables.Config.getTimeToLock() type="exclusive" {
			// Reserve our namespace within the application scope.
			if (!structKeyExists(application, 'HothShortTermMemory'))
				application['HothShortTermMemory'] = { hits = 0, lastSave = now(), saves=[], index = {} };

			if (structIsEmpty(application.HothShortTermMemory.index)) {
				local.reportJSON = fileRead(variables.paths.Report, 'utf-8');
				if (len(local.reportJSON) > 0) {
					if (isJSON(local.reportJSON)) {
						local.reportContents = deserializeJSON(local.reportJSON);
						if (structKeyExists(local.reportContents, 'index'))
							application.HothShortTermMemory.index = local.reportContents.index;
					}
				}
			}
		}
		return;
	}
}
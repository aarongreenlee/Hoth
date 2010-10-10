import coldbox.system.testing.*;

/** Unit test for Hoth.HothTracker */
component extends="mxunit.framework.TestCase"  {

	/** Constructor */
	public void function setUp() {
		MockBox = new MockBox();

		// Load our test config
		HothConfig = new Hoth._test.HothConfig();

		variables.paths =
		{
			 exceptions = HothConfig.getPath('exceptions')
			,incidents 	= HothConfig.getPath('incidents')
		};

		// SUT
		variables.HothTracker = MockBox
								.createMock(classname='Hoth.HothTracker',callLogging=true)
								.init(HothConfig);

		// Delete all previous logs
		local.files = directoryList(variables.paths.exceptions,false,'path','*','size desc');
		if (!arrayIsEmpty(local.files))
			for (local.f in local.files)
				fileDelete(local.f);

		// Delete all previous logs
		local.files = directoryList(variables.paths.incidents,false,'path','*','size desc');
		if (!arrayIsEmpty(local.files))
			for (local.f in local.files)
				fileDelete(local.f);

		return;
	}

	// ------------------------------------------------------------------------------
	/** Test default ColdFusion exception tracking. */
	public void function track() {
		try {
			coldfusion = undefinedVariable;
		} catch (any exception) {
			local.hashOfStack = hash(lcase(exception.stacktrace),'SHA');
			local.HothOk = variables.HothTracker.track(exception);

		}

		local.file = local.hashOfStack & '.log';
		// Verify an exception was saved.
		assert( fileExists(variables.paths.exceptions & '\' & local.file), 'Expected #local.hashOfStack#.log exception file.');
		assert( fileExists(variables.paths.incidents & '\' & local.file), 'Expected #local.hashOfStack#.log incident file.');

		return;
	}
	/** Test a ColdBox exception. */
	public void function trackForColdBox() {
		try {
			coldbox = undefinedVariable;
		} catch (any exception) {
			local.ExceptionBean = new coldbox.system.beans.ExceptionBean(errorStruct=exception);
			local.hashOfStack = hash(lcase(exception.stacktrace),'SHA');
			local.HothOk = variables.HothTracker.track(exception);
		}
		local.file = local.hashOfStack & '.log';
		// Verify an exception was saved.
		assert( fileExists(variables.paths.exceptions & '\' & local.file), 'Expected #local.hashOfStack#.log exception file.');
		assert( fileExists(variables.paths.incidents & '\' & local.file), 'Expected #local.hashOfStack#.log incident file.');

		return;
	}

	public void function trackDuplicates() {
		local.loops = 5;

		// Hit the same exception X times.
		for (local.i=1; local.i <= local.loops; local.i++) {
			try {
				apples = undefinedVariable2;
			} catch (any exception) {
				local.hashOfStack = hash(lcase(exception.stacktrace),'SHA');
				variables.HothTracker.track(exception);
			}
		}
		local.file = local.hashOfStack & '.log';
		// Verify an exception was saved.
		assert( fileExists(variables.paths.exceptions & '\' & local.file), 'Expected #local.hashOfStack#.log exception file.');

		// Verify our incident file was saved
		local.incidentFile = variables.paths.incidents & '\' & local.file;
		assert( fileExists(local.incidentFile), 'Expected #local.file# incident file.');

		// Verify our incident file has five incidents (one per line)
		local.incidents = FileOpen(local.incidentFile, 'read');
		local.lines = 0;
		while( !FileisEOF(local.incidents) ) {
			++local.lines;
			local.line = FileReadLine(local.incidents);
			assert( isDate(local.line) , 'Expected date; Received "#local.line#"');
		}
		FileClose(local.incidents);

		assert(local.lines == local.loops, 'Expected #local.loops# lines. #local.lines# found');

		return;
	}
}
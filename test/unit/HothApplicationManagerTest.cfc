/**
	Aaron Greenlee
	http://aarongreenlee.com/

	This work is licensed under a Creative Commons Attribution-Share-Alike 3.0
	Unported License.

	// Original Info -----------------------------------------------------------
	Author			: Aaron Greenlee
	Created      	: 12/13/2010 10:17:31 AM

	Unit Test for HothApplicationManager

	// Modifications :---------------------------------------------------------

*/

/** Unit test for Hoth.HothTracker */
component extends="mxunit.framework.TestCase"
{

	variables.testDB = '/Hoth/test/db/';
	variables.appFile = expandPath(variables.testDB & 'applications.hoth');

	/** Constructor */
	public void function setUp()
	{
		// Load our test config
		HothConfig = new Hoth.test.HothConfig();
		HothConfig.setGlobalDatabasePath(variables.testDB);

		// Change the global settings for the test
		HothConfig.GlobalHothSettings.globalDatabase = variables.testDB;

		// Create our SUT
		HothApplicationManager =
			new Hoth.object.HothApplicationManager(HothConfig);

		// Write our test application data
		local.applicationToSave =
		[{
			 'applicationName' = 'HothUnitTestFake'
			,'logPath' = '/Hoth/test/logs_not_real'
			,'created' = 0
		}];
		fileWrite(
			 variables.appFile
			,serializeJSON(local.applicationToSave)
			,'UTF-8'
		);

		return;
	}

	/** Ensure our test db directory exists. **/
	public void function beforeTests ()
	{
		if (!directoryExists(variables.testDB))
			directoryCreate(variables.testDB);

		return;
	}

	/** Delete our test db file. **/
	public void function afterTests ()
	{
		// Delete test db unless a test triggered the delete
		if (fileExists(variables.appFile))
		{
			fileDelete(variables.appFile);
		}
	}

	// -------------------------------------------------------------------------
	/** Ensure we can read our application database file. **/
	public void function loadApplicationsFromDisk()
	{
		makePublic(HothApplicationManager, 'loadApplicationsFromDisk');

		// Confirm we have our application created in beforeTests();
		local.appsFound = arrayLen(
			HothApplicationManager.loadApplicationsFromDisk(HothConfig)
		);

		assertEquals(
			 1
			,local.appsFound
			,'Invalid application db.'
		);

		return;
	}

	/** Ensure we delete an invalid application database file. **/
	public void function loadApplicationsFromDisk_Deletes_Invalid_JSON()
	{
		makePublic(HothApplicationManager, 'loadApplicationsFromDisk');

		// Save invalid data and expect the file to be deleted
		fileWrite(
			 variables.appFile
			,'I am not JSON'
			,'UTF-8'
		);

		// Now, we expect zero.
		local.appsFound = arrayLen(
			HothApplicationManager.loadApplicationsFromDisk(HothConfig)
		);

		assertEquals(
			 0
			,local.appsFound
			,'Should have deleted the file and returned zero.'
		);

		assert(
			 fileExists(variables.testDB & variables.appFile) == false
			,'Should have deleted the file and returned zero.'
		);

		return;
	}

	/** Ensure we can learn about our applications. **/
	public void function learnApplication()
	{

		local.newApplication =
		HothApplicationManager.learnApplication(HothConfig);

		assert(local.newApplication, 'We should have a new application.');

		// Performing the same test twice should now return false since we
		// already know about this application.

		local.newApplication =
		HothApplicationManager.learnApplication(HothConfig);

		assertFalse(local.newApplication, 'We should NOT have a new application.');

		return;
	}
}
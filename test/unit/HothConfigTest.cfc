/**
	Aaron Greenlee
	http://aarongreenlee.com/

	This work is licensed under a Creative Commons Attribution-Share-Alike 3.0
	Unported License.

	// Original Info -----------------------------------------------------------
	Author			: Aaron Greenlee
	Created      	: 12/13/2010 10:17:31 AM

	Unit Test for Hoth Config Object.

	// Modifications :---------------------------------------------------------

*/

/** Unit test for Hoth.HothTracker */
component extends="mxunit.framework.TestCase"
{

	/** Constructor */
	public void function setUp()
	{

		// Load our test config
		HothConfig = new Hoth.test.HothConfig();

		return;
	}

	// -------------------------------------------------------------------------
	public void function ConfirmGlobalVariables() {

		// All keys expected within global settings
		local.expectedValues =
		[
			'globalDatabase'
		];

		// Confirm the global settings themselves
		assert(
			structKeyExists(HothConfig, 'GlobalHothSettings')
			,'GlobalHothSettings did not exist.'
		);

		// Confirm each key
		for(index in local.expectedValues)
		{
			assert(
				structKeyExists(HothConfig['GlobalHothSettings'], index)
				,'#index# missing from GlobalHothSettings.'
			);
		}

		return;
	}
}
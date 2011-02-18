/**
	Aaron Greenlee
	http://aarongreenlee.com/

	This work is licensed under a Creative Commons Attribution-Share-Alike 3.0
	Unported License.

	// Original Info -----------------------------------------------------------
	Author			: Aaron Greenlee
	Created      	: 10/01/2010

	Unit Test Config for Hoth

	// Modifications :---------------------------------------------------------
	Modified		: 	12/13/2010 9:52:41 AM by Aaron Greenlee.
    				-	Now supporting ColdBox 3.0 RC1
	Modified		: 	02/18/2011 1:20:12 PM by Aaron Greenlee.
    				-	Now supporting the HothReportURL value.
*/
component
	implements='Hoth.object.iHothConfig'
	extends='Hoth.object.CoreConfig'
	accessors=true {

	property name='applicationName' default='HothUnitTests';
	property name='timeToLock' default='1';
	property name='logPath' default='/Hoth/test/logs';
	property name='EmailNewExceptions' default='true';
	property name='EmailNewExceptionsTo' default='aarongreenlee@gmail.com';
	property name='EmailNewExceptionsFrom' default='aarongreenlee@gmail.com';
	property name='EmailNewExceptionsFile' default='true';
	property name='HothReportURL' default='UNIT_TEST_WILL_POPULATE';

	public function init ()
	{
		super.init();
		return this;
	}
}
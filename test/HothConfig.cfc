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
*/
component
	implements='Hoth.object.iHothConfig'
	extends='Hoth.object.CoreConfig'
	accessors=true {

	/** What is the name of your application? */
	property name='applicationName'			default='HothUnitTests';

	/** How many seconds should we lock file operations?
		For most operations this is exclusive to a unique exception. */
	property name='timeToLock' 				default='1';

	/** Where would you like Hoth to save exception data?
		This folder should be empty. */
	property name='logPath' 				default='/Hoth/test/logs';

	// ------------------------------------------------------------------------------
	/** Would you like new exceptions to be emailed to you? */
	property name='EmailNewExceptions' 		default='true';

	/** What address(es) should receive these e-mails? */
	property name='EmailNewExceptionsTo' 	default='aarongreenlee@gmail.com';

	/** What address would you like these emails sent from? */
	property name='EmailNewExceptionsFrom' 	default='aarongreenlee@gmail.com';

	/** Would you like the raw JSON attached to the e-mail? */
	property name='EmailNewExceptionsFile' 	default='true';
	// ------------------------------------------------------------------------------
}
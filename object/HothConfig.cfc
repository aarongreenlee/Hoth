/** Default configuration for Hoth. */
component
	implements='Hoth.object.iHothConfig'
	extends='Hoth.object.CoreConfig'
	accessors=true {

	/** What is the name of your application? */
	property name='applicationName'			default='HothDefaultConfig';

	/** How many seconds should we lock file operations?
		For most operations this is exclusive to a unique exception. */
	property name='timeToLock' 				default='1';

	/** Where would you like Hoth to save exception data?
		This folder should be empty. */
	property name='logPath' 				default='/Hoth/logs';

	// ------------------------------------------------------------------------------
	/** Would you like new exceptions to be emailed to you? */
	property name='EmailNewExceptions' 		default='false';

	/** What address(es) should receive these e-mails? */
	property name='EmailNewExceptionsTo' 	default='you@yourdomain.com';

	/** What address would you like these emails sent from? */
	property name='EmailNewExceptionsFrom' 	default='hoth@yourdomain.com';

	/** Would you like the raw JSON attached to the e-mail? */
	property name='EmailNewExceptionsFile' 	default='false';
	// ------------------------------------------------------------------------------
}
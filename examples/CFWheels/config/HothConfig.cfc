/**
 * Copyright Aaron Greenlee
 *
 * <h4>Description</h4>
 * An example configuration object for your appication.
 * Customize this configuration object for your needs.
 *
 * Created
 * 2/9/2011 10:22:19 AM
 *
 * @author Aaron Greenlee
 * @version 1
 * @see N/A
 **/

component
	implements	= 'Hoth.object.iHothConfig'
	extends		= 'Hoth.object.CoreConfig'
	accessors	= true
	{

	/** What is the name of your application? */
	property
		name='applicationName'
		default='Amazing ColdFusion Club 3';

	/** How many seconds should we lock file operations?
		For most operations this is exclusive to a unique exception. */
	property
		name='timeToLock'
		default='1';

	/** Where would you like Hoth to save exception data?
		This folder should be empty. */
	property
		name='logPath'
		default='/Hoth/logs';

	// ------------------------------------------------------------------------------
	/** Would you like new exceptions to be emailed to you? */
	property
		name='EmailNewExceptions'
		default='true';

	/** What address(es) should receive these e-mails? */
	property
		name='EmailNewExceptionsTo'
		default='you@email.com;co-worker@email.com';

	/** What address would you like these emails sent from? */
	property
		name='EmailNewExceptionsFrom'
		default='you@email.com';

	/** Would you like the raw JSON attached to the e-mail? */
	property
		name='EmailNewExceptionsFile'
		default='true';
	// ------------------------------------------------------------------------------

	/**
	The mapping where you would like Hoth to write it's log files.
	Without this setting, Hoth will write log files to the same directory
	Hoth is located within. This is not recomended as your will have content
	mixed into your Hoth code.
	**/
	setGlobalDatabasePath(path='/logs/hoth/');
}
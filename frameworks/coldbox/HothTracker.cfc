/** Hoth can work with ColdBox. Cool! */
component
extends = 'Hoth.HothTracker'
{
	public Hoth.frameworks.coldbox.HothTracker function init () {
		super.init(argumentCollection=arguments);
		return this;
	}

	/** Returns true if Hoth itself did not error. */
	public boolean function track(ExceptionBean) {
		local.args = {
			 detail 	= arguments.ExceptionBean.getDetail()
			,message 	= arguments.ExceptionBean.getMessage()
			,stacktrace = arguments.ExceptionBean.getStackTrace()
			,tagcontext = arguments.ExceptionBean.getTagContext()
		};
		return super.track(local.args);
	}
}
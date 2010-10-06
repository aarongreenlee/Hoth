/** Hoth can work with ColdBox. Cool! */
component
extends = 'Hoth.HothTracker'
{
	public Hoth.HothForColdBox function init () {
		super.init();
		return this;
	}

	public void function track(ExceptionBean) {
		local.args = {
			 detail 	= arguments.ExceptionBean.getDetail()
			,message 	= arguments.ExceptionBean.getMessage()
			,stacktrace = arguments.ExceptionBean.getStackTrace()
			,tagcontext = arguments.ExceptionBean.getTagContext()
		};
		super.track(local.args);
		return;
	}
}
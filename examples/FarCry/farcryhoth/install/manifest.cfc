<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

	<cfset this.name = "Hoth" />
	<cfset this.description = "Hoth: ColdFusion Exception Tracking" />
	<cfset this.lRequiredPlugins = "" />
	<cfset addSupportedCore(majorVersion="5", minorVersion="2", patchVersion="0") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="0", patchVersion="0") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="1", patchVersion="0") />
		
</cfcomponent>
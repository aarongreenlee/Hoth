<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Hoth Reporting --->
<!--- @@author: Sean Coyne (sean@n42designs.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfoutput>#application.hoth.report.getReportView()#</cfoutput>

<cfsetting enablecfoutputonly="false" />
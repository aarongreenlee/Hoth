<cfset variables.HothReporter = new HothReporter() />
<cfif structKeyExists(url, 'detail')>
	<cfdump var="#variables.HothReporter.loadDetail(url.detail)#">
<cfelse>
	<cfscript>
		variables.report = variables.HothReporter.loadIndex();
		variables.e = variables.HothReporter.sortIndex(index=variables.Report);
	</cfscript>
	<table>
		<thead>
			<tr>
				<td>Count</td>
				<td>Index</td>
				<td>Last Incident</td>
				<td>View Details</td>
			</tr>
		</thead>
		<tbody>
			<cfoutput>
			<cfloop array="#variables.e#" index="_e">
			<tr>
				<cfif structKeyExists(_e, 'count')>
					<td>#_e['count']#</td>
				<cfelse>
					<td>N/A</td>
				</cfif>

				<cfif structKeyExists(_e, 'index')>
					<td>#_e.index#</td>
				<cfelse>
					<td>N/A</td>
				</cfif>

				<cfif structKeyExists(_e, 'lastincident')>
					<td>#_e.lastincident#</td>
				<cfelse>
					<td>N/A</td>
				</cfif>

				<cfif structKeyExists(_e, 'index')>
					<td><a href="?detail=#_e.index#">View Details</a></td>
				<cfelse>
					<td>N/A</td>
				</cfif>
			</tr>
			</cfloop>
			</cfoutput>
		</tbody>
	</table>
</cfif>
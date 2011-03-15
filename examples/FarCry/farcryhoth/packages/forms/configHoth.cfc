<cfcomponent output="false" key="hoth" displayname="Hoth: ColdFusion Exception Tracking" hint="Manages configuration for the Hoth exception tracking framework" extends="farcry.core.packages.forms.forms">
	
	<cfproperty ftSeq="110" ftFieldset="Hoth Configuration" ftLabel="Time to Lock" name="timeToLock" type="integer" ftType="integer" required="true" ftValidation="required" default="1" ftDefault="1" ftHint="How many seconds should we lock file operations?" />
	<cfproperty ftSeq="120" ftFieldset="Hoth Configuration" ftLabel="Log Path" name="logPath" type="nstring" ftType="string" required="true" ftValidation="required" default="/Hoth/logs" ftDefault="/Hoth/logs" ftHint="Where would you like Hoth to save exception data? This folder should be empty." />
	<cfproperty ftSeq="130" ftFieldset="Hoth Configuration" ftLabel="Email New Exceptions?" name="EmailNewExceptions" type="boolean" ftType="boolean" required="true" default="0" ftDefault="0" ftHint="Would you like new exceptions to be emailed to you?" />
	<cfproperty ftSeq="140" ftFieldset="Hoth Configuration" ftLabel="To Address(es)" name="EmailNewExceptionsTo" type="nstring" ftType="string" required="false" default="" ftDefault="" ftHint="What address(es) should receive these e-mails?" />
	<cfproperty ftSeq="150" ftFieldset="Hoth Configuration" ftLabel="From Address" name="EmailNewExceptionsFrom" type="nstring" ftType="string" required="false" default="" ftDefault="" ftHint="What address would you like these emails sent from?" />
	<cfproperty ftSeq="160" ftFieldset="Hoth Configuration" ftLabel="Include JSON in Email?" name="EmailNewExceptionsFile" type="boolean" ftType="boolean" required="true" default="0" ftDefault="0" ftHint="Would you like the raw JSON attached to the e-mail?" />
	
</cfcomponent>
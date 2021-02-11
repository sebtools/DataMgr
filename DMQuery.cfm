<cfsilent>
<!---
I run a query using DataMgr
Version 1.0
Updated: 2017-08-08
Created: 2010-01-12
--->

<cfif StructKeyExists(Caller,"DataMgr")>
	<cfparam name="attributes.DataMgr" default="#Caller.DataMgr#">
<cfelseif StructKeyExists(Application,"DataMgr")>
	<cfparam name="attributes.DataMgr" default="#Application.DataMgr#">
</cfif>
<cfparam name="attributes.path" default="com.sebtools.DataMgr">
<cfif NOT StructKeyExists(attributes,"DataMgr")>
	<cfinvoke returnvariable="attributes.DataMgr" component="#attributes.path#" method="init" argumentCollection="#attributes#">
	</cfinvoke>
</cfif>
<cfparam name="attributes.DataMgr">
<cfparam name="attributes.fieldlist" default=""><!--- Only used for logging. --->

<cfif StructKeyExists(Caller,"DataLogger")>
	<cfparam name="attributes.DataLogger" default="#Caller.DataLogger#">
<cfelse>
	<cftry>
		<cf_service name="DataLogger">
		<cfset Attributes.DataLogger = Variables.DataLogger>
	<cfcatch>
	</cfcatch>
	</cftry>
</cfif>


<!--- Get UDFs --->
<cfif NOT isDefined("getDMSQLArray")><cfinclude template="DMUdfs.cfm"></cfif>

<cfif
		StructKeyExists(Attributes,"sql")
	OR	(
				ThisTag.HasEndTag
			AND	ThisTag.ExecutionMode EQ "End"
			AND	Len(Trim(ThisTag.GeneratedContent))
		)
>
	<!--- Execute the given SQL if given any --->
	<cfif StructKeyExists(Attributes,"sql")>
		<cfset sqlarray = Attributes.sql>
		<cfset StructDelete(Attributes,"sql")>
	<cfelse>
		<cfset sqlarray = getDMSQLArray()>
	</cfif>
	<cfset sActions = getActionArgs(sqlarray)>
	<cfset StructAppend(sActions,Attributes,"no")>
	<!--- If we're logging something and we know the pkvalue, then get the before state for logging. --->
	<cfif doLog(sActions) AND StructKeyExists(sActions,"pkvalue") AND Len(sActions["pkvalue"])>
		<cfset Variables.pkfield = Attributes.DataMgr.getPrimaryKeyFieldNames(sActions.tablename)>
		<!--- If no fieldlist is provided, then use the SQL provided (this will help with the performance of the query and fieldlist is naturally safe from SQL injection). --->
		<cfif NOT Len(Trim(attributes.fieldlist))>
			<cfset attributes.fieldlist = getWordList(sqlarray)>
		</cfif>
		<cfif ListLen(Variables.pkfield) EQ 1>
			<cfset Variables.qBefore = Attributes.DataMgr.getRecord(
				tablename=sActions.tablename,
				data={
					"#Variables.pkfield#":"#sActions.pkvalue#"
				},
				fieldlist=attributes.fieldlist
			)>
		</cfif>
	</cfif>
	<cfset Variables.result = Attributes.DataMgr.runSQLArray(sqlarray,attributes)>
	<!---- Try to log action ---->
	<cfset StructAppend(Attributes,sActions,"no")>
	<cfif doLog(Attributes)>
		<!--- If we're logging something and we know the before state, then get the after state for logging. --->
		<cfif StructKeyExists(Variables,"qBefore")>
			<cfset Variables.qAfter = Attributes.DataMgr.getRecord(
				tablename=Attributes.tablename,
				data={
					"#Variables.pkfield#":"#Attributes.pkvalue#"
				},
				fieldlist=attributes.fieldlist
			)>
		</cfif>
		<cfinvoke
			component="#Attributes.DataLogger#"
			method="logAction"
			tablename="#Trim(Attributes.tablename)#"
			action="#Attributes.action#"
			sql="#sqlarray#"
			complete="true"
		>
			<cfif StructKeyExists(Attributes,"pkvalue")>
				<cfinvokeargument name="pkvalue" value="#Attributes.pkvalue#">
			<cfelseif StructKeyExists(Variables,"result") AND isSimpleValue(Variables.result)>
				<cfinvokeargument name="pkvalue" value="#Variables.result#">
			</cfif>
			<cfif StructKeyExists(Variables,"qAfter")>
				<cfinvokeargument name="before" value="#Variables.qBefore#">
				<cfinvokeargument name="after" value="#Variables.qAfter#">
			</cfif>
		</cfinvoke>
	</cfif>
	<cfif StructKeyExists(attributes,"name") AND StructKeyExists(Variables,"result")>
		<cfset Caller[attributes.name] = Variables.result>
	</cfif>
	<cfif StructKeyExists(Attributes,"sqlresult") AND isSimpleValue(Attributes.sqlresult) AND Len(Attributes.sqlresult)>
		<cfset Caller[Attributes.sqlresult] = sqlarray>
	</cfif>
<cfelseif NOT ThisTag.HasEndTag OR ( ThisTag.ExecutionMode EQ "End" AND NOT Len(Trim(ThisTag.GeneratedContent)) )>
	<!--- Otherwise we'll have to turn to methods --->
	<cfparam name="attributes.method">
	<cfinvoke
		returnvariable="Variables.result"
		component="#attributes.DataMgr#"
		method="#attributes.method#"
		argumentcollection="#attributes#"
	>
	<cfif StructKeyExists(attributes,"name") AND StructKeyExists(Variables,"result")>
		<cfset Caller[attributes.name] = Variables.result>
	</cfif>
</cfif>

</cfsilent>

<cfsilent>
<!---
I get a SQL array for use with DataMgr
Version 1.0
Updated: 2017-08-08
Created: 2010-01-12
--->

<!--- Get UDFs --->
<cfif NOT isDefined("getDMSQLArray")><cfinclude template="DMUdfs.cfm"></cfif>

<!--- Associate with CF_DMQuery if called from within it --->
<cfif ThisTag.ExecutionMode EQ "Start">
	<cfset isNestedTag = false>
	<cfset BaseTagList = getBaseTagList()>
	<cfif ListFindNoCase(BaseTagList,"CF_DMQuery")>
		<cfassociate basetag="cf_DMQuery" dataCollection="aSQLs">
		<cfset ParentData = getBaseTagData("cf_DMQuery")>
		<cfset isNestedTag = true>
	<cfelseif ListFindNoCase(BaseTagList,"CF_DMSQL") GT 0 AND ListFindNoCase(BaseTagList,"CF_DMSQL") LT ListLen(BaseTagList)>
		<cftry>
			<cfassociate basetag="CF_DMSQL" dataCollection="aSQLs">
			<!--- The second argument is instancenumber. The default is 1, which would just refer to the same CF_DMSQL. Have to use 2 to get the parent --->
			<cfset ParentData = getBaseTagData("CF_DMSQL",2)>
			<cfset isNestedTag = true>
		<cfcatch>
		</cfcatch>
		</cftry>
	</cfif>
</cfif>

<cfif isNestedTag>
	<cfset Variables.DataMgr = ParentData.attributes.DataMgr>
<cfelse>
	<cfif StructKeyExists(Attributes,"DataMgr")>
		<cfset Variables.DataMgr = Attributes.DataMgr>
	<cfelseif StructKeyExists(Caller,"DataMgr")>
		<cfset Variables.DataMgr = Caller.DataMgr>
	<cfelseif StructKeyExists(Application,"DataMgr")>
		<cfset Variables.DataMgr = Application.DataMgr>
	<cfelse>
		<!---<cfparam name="attributes.path" default="com.sebtools.DataMgr">
		<cfinvoke returnvariable="Variables.DataMgr" component="#attributes.path#" method="init" argumentCollection="#attributes#">
		</cfinvoke>--->
		<cfthrow message="Unable to determine DataMgr">
	</cfif>
</cfif>
<cfset Attributes.DataMgr = Variables.DataMgr>

<cfparam name="Attributes.name" default="">
<cfif Len(Trim(Attributes.name))>
	<cfparam name="Attributes.method" default="">
<cfelse>
	<cfparam name="Attributes.method" default="getRecordsSQL">
</cfif>
<cfparam name="Attributes.addtoscope" default="Arguments">
<cfset ArgsStruct = {}>
<cfif isSimpleValue(Attributes.addtoscope) AND StructKeyExists(Caller,Attributes.addtoscope)>
	<cfset ArgsStruct = Caller[Attributes.addtoscope]>
<cfelseif isStruct(Attributes.addtoscope)>
	<cfset ArgsStruct = Attributes.addtoscope>
<cfelse>
	<cfthrow message="addtoscope must either be the name of a scope or a structure.">
</cfif>

<cfif ThisTag.ExecutionMode EQ "End" OR NOT ThisTag.HasEndTag>
	<!--- Return the SQL array --->
	<cfif NOT (
				StructKeyExists(attributes,"sql")
			AND	(
						isArray(attributes.sql)
					OR	(
								isSimpleValue(attributes.sql)
							AND	Len(Trim(attributes.sql))
						)
				)
	)>
		<cfif Len(Trim(ThisTag.GeneratedContent))>
			<!--- Get SQL from generated content --->
			<cfset attributes.sql = getDMSQLArray()>
			<cfif StructKeyExists(attributes,"addtoclause")>
				<cfset Variables.DataMgr.addAdvSQL(ArgsStruct,attributes.addtoclause,attributes.sql)>
			</cfif>
		<cfelseif StructKeyExists(attributes,"method") AND isSimpleValue(Attributes.method) AND Len(Trim(Attributes.method))>
			<!--- Or use a method to get it --->
			<cfinvoke
				returnvariable="attributes.sql"
				component="#Variables.DataMgr#"
				method="#attributes.method#"
				argumentcollection="#attributes#"
			>
		<cfelse>
			<!--- If all else failed, just make an empty array --->
			<cfset attributes.sql = ArrayNew(1)>
		</cfif>
	<!--- If sql is passed in as an attribute and is requested to be added to a clause, add it here. --->
	<cfelseif StructKeyExists(attributes,"addtoclause")>
		<cfset Variables.DataMgr.addAdvSQL(ArgsStruct,attributes.addtoclause,attributes.sql)>
	</cfif>
	<!--- If a name attribute is passed in, set the given variable in the calling page --->
	<cfif StructKeyExists(attributes,"name")>
		<cfset Caller[attributes.name] = attributes.sql>
	</cfif>
</cfif>

</cfsilent><cfif isNestedTag AND ( ThisTag.ExecutionMode EQ "End" OR NOT ThisTag.HasEndTag )><cfoutput>[DataMgrSQL:#ArrayLen(ParentData.ThisTag.aSQLs)#]</cfoutput></cfif>

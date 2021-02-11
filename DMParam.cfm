<cfsilent>
<!---
I am a CFQUERYPARAM tag for CF_DMQuery and CF_DMSQL
Version 1.0
Updated: 2017-08-08
Updated: 2010-05-30
--->
<cfparam name="Attributes.value" type="string">
<cfif ThisTag.ExecutionMode EQ "Start">
	<cfif ListFindNoCase(getBaseTagList(),"CF_DMSQL")>
		<cfassociate basetag="cf_DMSQL" dataCollection="aParams">
		<cfset ParentData = getBaseTagData("cf_DMSQL")>
	<cfelseif ListFindNoCase(getBaseTagList(),"CF_DMQuery")>
		<cfassociate basetag="cf_DMQuery" dataCollection="aParams">
		<cfset ParentData = getBaseTagData("cf_DMQuery")>
	</cfif>
</cfif>
</cfsilent><cfif ThisTag.ExecutionMode EQ "End" OR NOT ThisTag.HasEndTag><cfoutput>[DataMgrParam:#ArrayLen(ParentData.ThisTag.aParams)#]</cfoutput></cfif>

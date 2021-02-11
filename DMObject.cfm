<cfsilent>
	<cfparam name="Attributes.name" type="string">
	<cfif ThisTag.ExecutionMode EQ "Start">
		<cfif ListFindNoCase(getBaseTagList(),"CF_DMSQL")>
			<cfset ParentData = getBaseTagData("cf_DMSQL")>
		<cfelseif ListFindNoCase(getBaseTagList(),"CF_DMQuery")>
			<cfset ParentData = getBaseTagData("cf_DMQuery")>
		</cfif>
	</cfif>
	<cfset Variables.DataMgr = ParentData.Attributes.DataMgr>

</cfsilent><cfif ThisTag.ExecutionMode EQ "End" OR NOT ThisTag.HasEndTag><cfoutput>#Variables.DataMgr.escape(Attributes.name)#</cfoutput></cfif>

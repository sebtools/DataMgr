<cfcomponent extends="DataMgr" displayname="Data Manager for SQL databases" hint="I manage data interactions with any SQL database.">

<cffunction name="saveRelationList" access="public" returntype="void" output="no" hint="I save a many-to-many relationship.">
	<cfargument name="tablename" type="string" required="yes" hint="The table holding the many-to-many relationships.">
	<cfargument name="keyfield" type="string" required="yes" hint="The field holding our key value for relationships.">
	<cfargument name="keyvalue" type="string" required="yes" hint="The value of out primary field.">
	<cfargument name="multifield" type="string" required="yes" hint="The field holding our many relationships for the given key.">
	<cfargument name="multilist" type="string" required="yes" hint="The list of related values for our key.">
	<cfargument name="reverse" type="boolean" default="false" hint="Should the reverse of the relationship by run as well (for self-joins)?s.">

	<cfset var bTable = checkTable(Arguments.tablename)><!--- Check whether table is loaded --->
	<cfset var ii = 0>
	<cfset var multival = 0>
	<cfset var sqldelete = ArrayNew(1)>
	<cfset var sqlinsert = ArrayNew(1)>
	<cfset var sData = {}>
	<cfset var aFilters = []>
	<cfset var sFieldKey = getField(arguments.tablename,arguments.keyfield)>
	<cfset var sFieldMulti = getField(arguments.tablename,arguments.multifield)>

	<!--- Make sure a value is passed in for the primary key value --->
	<cfif NOT Len(Trim(Arguments.keyvalue))>
		<cfset throwDMError("You must pass in a value for keyvalue of saveRelationList","NoKeyValueForSaveRelationList")>
	</cfif>

	<cfif Arguments.reverse>
		<cfinvoke method="saveRelationList">
			<cfinvokeargument name="tablename" value="#arguments.tablename#">
			<cfinvokeargument name="keyfield" value="#arguments.multifield#">
			<cfinvokeargument name="keyvalue" value="#arguments.keyvalue#">
			<cfinvokeargument name="multifield" value="#arguments.keyfield#">
			<cfinvokeargument name="multilist" value="#arguments.multilist#">
		</cfinvoke>
	</cfif>

	<cf_DMQuery DataMgr="#This#" sqlresult="sqldelete">
	DELETE
	FROM	<cf_DMOBject name="#Arguments.tablename#">
	WHERE	<cf_DMOBject name="#Arguments.keyfield#"> = <cf_DMParam value="#Arguments.keyvalue#" cfsqltype="#sFieldKey.CF_Datatype#">
		<cfif Len(Arguments.multilist)>
		AND	<cf_DMOBject name="#Arguments.multifield#"> NOT IN (<cf_DMParam value="#Arguments.multilist#" cfsqltype="#sFieldMulti.CF_Datatype#" list="yes">)
		</cfif>
	</cf_DMQuery>

	<cfif variables.doLogging AND NOT arguments.tablename EQ variables.logtable>
		<cfinvoke method="logAction">
			<cfinvokeargument name="tablename" value="#Arguments.tablename#">
			<cfinvokeargument name="action" value="delete">
			<cfinvokeargument name="data" value="#sData#">
			<cfinvokeargument name="sql" value="#sqldelete#">
		</cfinvoke>
	</cfif>

	<cfif Len(Arguments.multilist)>
		<cf_DMQuery DataMgr="#This#" sqlresult="sqlinsert">
		INSERT INTO <cf_DMObject name="#Arguments.tablename#"> (
				<cf_DMObject name="#Arguments.keyfield#">,
				<cf_DMObject name="#Arguments.multifield#">
		)
		SELECT
				<cf_DMObject name="#Arguments.keyfield#">,
				<cf_DMObject name="#Arguments.multifield#">
		FROM	(
					SELECT	<cf_DMParam value="#Arguments.keyvalue#" cfsqltype="#sFieldKey.CF_Datatype#"> AS <cf_DMObject name="#Arguments.keyfield#">
				) keys,
				(
				<cfloop index="ii" from="1" to="#ListLen(Arguments.multilist)#"><cfset multival = ListGetAt(Arguments.multilist,ii)>
					SELECT <cf_DMParam value="#multival#" cfsqltype="#sFieldMulti.CF_Datatype#"> AS <cf_DMObject name="#Arguments.multifield#">
					<cfif ii LT ListLen(Arguments.multilist)>UNION</cfif>
				</cfloop>
				) multis
		WHERE	NOT EXISTS (
					SELECT	1
					FROM	<cf_DMObject name="#Arguments.tablename#">
					WHERE	<cf_DMObject name="#Arguments.keyfield#"> = <cf_DMObject name="keys.#Arguments.keyfield#">
						AND	<cf_DMObject name="#Arguments.multifield#"> = <cf_DMObject name="multis.#Arguments.multifield#">
				)
		</cf_DMQuery>

		<!--- Log insert --->
		<cfif variables.doLogging AND NOT arguments.tablename EQ variables.logtable>
			<cfinvoke method="logAction">
				<cfinvokeargument name="tablename" value="#arguments.tablename#">
				<cfinvokeargument name="action" value="insert">
				<cfinvokeargument name="sql" value="#sqlinsert#">
			</cfinvoke>
		</cfif>
	</cfif>

	<cfset setCacheDate()>

</cffunction>

</cfcomponent>

<cfcomponent>

<cffunction name="getDataBase" access="public" returntype="string" output="false" hint="I return the database platform being used.">
	
	<cfscript>
	var sDBInfo = 0;
	var db = "";
	var type = "";
	</cfscript>
	
	<cfif Len(variables.datasource)>
		<cfdbinfo datasource="#variables.datasource#" name="sDBInfo" type="Version"  />
		<cfscript>
		db = sDBInfo.DATABASE_PRODUCTNAME;
		
		switch(db) {
			case "Microsoft SQL Server":
				type = "MSSQL";
			break;
	
			case "MySQL":
				type = "MYSQL";
			break;
	
			case "PostgreSQL":
				type = "PostGreSQL";
			break;
	
			case "Oracle":
				type = "Oracle";
			break;
			
			case "MS Jet":
				type = "Access";
			break;
			
			case "Apache Derby":
				type = "Derby";
			break;
			
			default:
				type = "unknown";
				type = db;
			break;
		}
		</cfscript>
	<cfelse>
		<cfset type="Sim">
	</cfif>
	
	<cfreturn type>
</cffunction>

</cfcomponent>
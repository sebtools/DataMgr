<cfsilent>
<!---
I supply UDFs for DMQuery/DMSQL/DMParam
Version 1.0
Updated: 2017-08-08
Updated: 2010-05-30
--->
<cfscript>
function convertSQLArray(aRawSQL) {
	var aResult = ArrayNew(1);
	var ii = 0;
	var jj = 0;
	var marker = "";
	var MarkerLoc = 0;

	//Convert SQL statements
	if ( StructKeyExists(ThisTag,"aSQLs") ) {
		for ( ii=1; ii LTE ArrayLen(aRawSQL); ii=ii+1 ) {
			//while ( Len(Trim(aRawSQL[ii])) ) {
			if ( isSimpleValue(aRawSQL[ii]) ) {
				if ( Len(Trim(aRawSQL[ii])) ) {
					for ( jj=1; jj LTE ArrayLen(ThisTag.aSQLs); jj=jj+1 ) {
						marker = "[DataMgrSQL:#jj#]";
						MarkerLoc = FindNoCase(marker,aRawSQL[ii]);
						//Replace marker with SQL Array
						if ( MarkerLoc ) {
							if ( MarkerLoc GT 1 ) {
								ArrayAppend(aResult,Left(aRawSQL[ii],MarkerLoc-1));
							}
							ArrayAppend(aResult,ThisTag.aSQLs[jj].sql);
							//Drop added text so we can continue loop
							if ( MarkerLoc GT 1 ) {
								aRawSQL[ii] = ReplaceNoCase(aRawSQL[ii],Left(aRawSQL[ii],MarkerLoc-1),"","ONE");
							}
							aRawSQL[ii] = ReplaceNoCase(aRawSQL[ii],marker,"","ONE");
						}
					}
					if ( Len(Trim(aRawSQL[ii])) ) {
						ArrayAppend(aResult,aRawSQL[ii]);
					}
				}
			} else {
				ArrayAppend(aResult,aRawSQL[ii]);
			}
		}
		//da(aResult);
	} else {
		aResult = aRawSQL;
	}
	return aResult;
}
function getDMSQLArray() {
	var aResult = ArrayNew(1);
	var ii = 0;
	var marker = "";

	ThisTag.GeneratedContent = " #ThisTag.GeneratedContent# ";

	//Loop over params and inject struct of attributes of each
	if ( StructKeyExists(ThisTag,"aParams") ) {
		for ( ii = 1; ii LTE ArrayLen(ThisTag.aParams); ii=ii+1 ) {
			marker = "[DataMgrParam:#ii#]";
			ArrayAppend(aResult,Left(ThisTag.GeneratedContent,FindNoCase(marker,ThisTag.GeneratedContent)-1));
			ArrayAppend(aResult,ThisTag.aParams[ii]);
			//Drop added text so we can continue loop
			ThisTag.GeneratedContent = ReplaceNoCase(ThisTag.GeneratedContent,Left(ThisTag.GeneratedContent,FindNoCase(marker,ThisTag.GeneratedContent)-1),"","ONE");
			ThisTag.GeneratedContent = ReplaceNoCase(ThisTag.GeneratedContent,marker,"","ONE");
		}
	}

	ThisTag.GeneratedContent = Trim(ThisTag.GeneratedContent);

	ArrayAppend(aResult,ThisTag.GeneratedContent);
	aResult = convertSQLArray(aResult);
	//Make sure to clear out generated content
	ThisTag.GeneratedContent = "";
	return aResult;
}
function getActionArgs(sqlarray) {
	var sResult = {};
	var aActionWords = ["INSERT INTO","UPDATE","DELETE"];
	var ActionWords = "Insert,Update,Delete";
	var str = sqlarray;
	var ii = 0;

	while ( isArray(str) ) {
		str = str[1];
	}
	str = Trim(str);

	str = ReReplaceNoCase(str,"\s"," ","ALL");

	for ( ii=1; ii LTE ArrayLen(aActionWords); ii++ ) {
		if (
			REFindNoCase(
				"^#aActionWords[ii]#\b",
				str
			)
		) {
			sResult["action"] = ListGetAt(ActionWords,ii);
			sResult["tablename"] = ListFirst(ReReplaceNoCase(str, "^#aActionWords[ii]#\b", ""), " ");
			sResult["tablename"] = Trim(ReReplaceNoCase(sResult["tablename"],"[\[\]]"," ","ALL"));
		}
	}

	return sResult;
}
function Listify(str) {
	var result = str;

	result = ReReplaceNoCase(str, "[^\w\d-_]", ",", "ALL");//convert everything that isn't a field name to a comma
	result = ReReplaceNoCase(result, ",{2,}", ",", "ALL");//condence duplicate commas
	result = ReReplaceNoCase(result, "^,", "");//Ditch comma from start of string
	result = ReReplaceNoCase(result, ",$", "");//Ditch comma from end of string

	return result;
}
function getWordList(sqlarray) {
	var result = "";
	var str = sqlarray;
	var ii = 0;

	while ( isArray(str) ) {
		str = str[1];
	}
	str = Trim(str);

	str = ReReplaceNoCase(str,"\s"," ","ALL");

	result = Listify(str);

	return result;
}
function doLog(atts) {
	if (
		StructKeyExists(atts,"DataLogger")
		AND
		StructKeyExists(atts,"action")
		AND
		StructKeyExists(atts,"tablename")
		AND
		NOT ( StructKeyExists(atts,"log") AND atts.log EQ false )
		AND
		(
			StructKeyExists(atts.DataLogger,"getLoggedTables")
			AND
			ListFindNoCase(atts.DataLogger.getLoggedTables(),atts.tablename)
		)
	) {
		return true;
	} else {
		return false;
	}
}
</cfscript>

</cfsilent>

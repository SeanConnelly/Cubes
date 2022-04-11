Class Cubes.API Extends %CSP.REST
{

/// Convert input to UNICODE
Parameter CONVERTINPUTSTREAM = 1;

/// Convert output to UTF-8
Parameter CHARSET = "utf-8";

Parameter Version = "1.0.0";

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/" Method="get" Call="listCubes" />
  <Route Url="/:cube" Method="post" Call="registerCube" />
  <Route Url="/:cube/object/:name" Method="post" Call="insertObject" />
  <Route Url="/:cube/object" Method="get" Call="findObjects" />
  <Route Url="/:cube/object/:oid" Method="get" Call="getObjectById" />  
  <Route Url="/:cube/object/:oid" Method="put" Call="updateObject" />
  <Route Url="/:cube/object/:oid" Method="delete" Call="deleteObjectById" />  
</Routes>
}

/// Return a list of all cubes registered on this server
ClassMethod listCubes() As %Status
{
    set %response.ContentType=..#CONTENTTYPEJSON
	quit ##class(Cubes.Cube).OutputCubeListToResponse()
}

/// Register a new cube on this server
ClassMethod registerCube(pCubeName As %String) As %Status
{
    set %response.ContentType=..#CONTENTTYPEJSON
	quit ##class(Cubes.Cube).RegisterCube(pCubeName)
}

ClassMethod findObjects(pCubeName As %String) As %Status
{
	set CID=##class(Cubes.Cube).GetId(pCubeName)
	if CID=0 quit ..ReportHttpStatusCode(404)
	set %response.ContentType=..#CONTENTTYPEJSON
	quit ##class(Cubes.Object).OutputObjectQueryToResponse(CID)
}

ClassMethod getObjectById(pCubeName As %String, pOID As %Integer) As %Status
{
	set CID=##class(Cubes.Cube).GetId(pCubeName)
	if CID=0 return ..ReportHttpStatusCode(404)
	
	set %response.ContentType="plain/text"
	//do %response.SetHeader("Content-Disposition","attachment;filename=""data.json""")
	
	set sc=##class(Cubes.Object).OutputObjectToResponse(CID,pOID)
	if $$$ISERR(sc) quit ..ReportHttpStatusCode(404)
	quit $$$OK
}

ClassMethod insertObject(pCubeName As %String, pObjectName As %String = "") As %Status
{
	set CID=##class(Cubes.Cube).GetId(pCubeName)
	if CID=0 return ..ReportHttpStatusCode(404)
	quit ##class(Cubes.Object).Upsert(CID,%request.Content,%request.ContentType,pObjectName)
}

ClassMethod updateObject(pCubeName As %String, pOID As %Integer) As %Status
{
	set CID=##class(Cubes.Cube).GetId(pCubeName)
	if CID=0 quit ..ReportHttpStatusCode(404)
	set sc=##class(Cubes.Object).Upsert(CID,%request.Content,%request.ContentType,"",pOID)
	if $$$ISERR(sc) quit ..ReportHttpStatusCode(404)
	quit $$$OK
}

ClassMethod deleteObjectById(pCubeName As %String, pOID As %Integer) As %Status
{
	set CID=##class(Cubes.Cube).GetId(pCubeName)
	if CID=0 quit ..ReportHttpStatusCode(404)	
	set sc=##class(Cubes.Object).Delete(CID,pOID)
	if $$$ISERR(sc) quit ..ReportHttpStatusCode(404)
	quit $$$OK
}

}

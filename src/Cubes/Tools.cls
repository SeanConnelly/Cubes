Class Cubes.Tools Extends %RegisteredObject
{

ClassMethod SeansLocalSourceCodeTest()
{
	//this is my local hack instance, these user names and passwords only exist for my R%D
	//use this as an example of how to sync code using this tool, obviously keep real
	//user names and passwords safe :) 
	set atelierUrl="localhost:52773/api/atelier"
	set cubeUrl="localhost:52773/cubes/codesys/object"
	set fileTypes="cls cso csr css dtd html inc int js json less md txt xml xsl yml"
	do ..SyncCubeFromLocalSourceCode(atelierUrl,"sean","1qaz",cubeUrl,"sean","1qaz",fileTypes)
}

/// Fetches the source code from an Atelier API and pushes it into a Cube
ClassMethod SyncCubeFromLocalSourceCode(pAtelierURL, pAtelierUserName, pAtelierPassword, pCubeURL, pCubeUserName, pCubePassword, pFileTypes) As %Status
{
	
	//Fetch full list of all doc names
	set atelierReq=##class(%Net.HttpRequest).%New()
	set atelierReq.Server=$p($p(pAtelierURL,"/",1),":",1)
	set atelierReq.Port=$p($p(pAtelierURL,"/",1),":",2)
	set atelierReq.Username=pAtelierUserName
	set atelierReq.Password=pAtelierPassword
	write !,"Fetching document list from /"_$p(pAtelierURL,"/",2,*),!
	do atelierReq.Get("/"_$p(pAtelierURL,"/",2,*)_"/v3/%25sys/docnames")
	set response={}.%FromJSON(atelierReq.HttpResponse.Data)
	
	//Handle Aterlier API errors
	if response.status.errors.%Size()>0 {
		set errors=response.status.errors
		write !,"Problem fetching document list from Atelier API",!
		zwrite errors
		write !
		return $$$ERROR($$$GeneralError,"Problem fetching document list from Atelier API")
	}
	
	//Get iterator and spin over doc names
	set errors=""
	set docs=response.result.content.%GetIterator()
	while docs.%GetNext(.key,.doc) {
		set docName=doc.name
		set type=$zcvt($p(docName,".",*),"L")
		if pFileTypes[type {
			set sc=..SyncCubeFromSourceCodeItem(docName,pAtelierURL, pAtelierUserName, pAtelierPassword, pCubeURL, pCubeUserName, pCubePassword)
			if $$$ISERR(sc) set errors=errors_$c(13,10)_docName_" "_$SYSTEM.Status.GetOneErrorText(sc)
		}
	}
	
	//dump all errors
	if errors'="" write !!,"Errors: ",!,errors,!!
	
	quit $$$OK
}

ClassMethod SyncCubeFromSourceCodeItem(pAterlierDocName, pAtelierURL, pAtelierUserName, pAtelierPassword, pCubeURL, pCubeUserName, pCubePassword) As %Status
{
	//encode doc name if contains %
	set docName=$replace(pAterlierDocName,"%","%25")
	
	//Fetch doc from Atelier API
	set atelierReq=##class(%Net.HttpRequest).%New()
	set atelierReq.Server=$p($p(pAtelierURL,"/",1),":",1)
	set atelierReq.Port=$p($p(pAtelierURL,"/",1),":",2)
	set atelierReq.Username=pAtelierUserName
	set atelierReq.Password=pAtelierPassword
	write !,"Syncing ",pAterlierDocName
	do atelierReq.Get("/"_$p(pAtelierURL,"/",2,*)_"/v1/%25sys/doc/"_docName)
	
	//check status code
	if atelierReq.HttpResponse.StatusCode'=200 {
		write !,"Failed: ",atelierReq.HttpResponse.StatusLine
		return $$$ERROR($$$GeneralError,"Error fetching document")	
	}
	
	//extract JSON
	set response={}.%FromJSON(atelierReq.HttpResponse.Data)
	
	//Handle Aterlier API errors
	if response.status.errors.%Size()>0 {
		set errors=response.status.errors
		write !,"Problem fetching document list from Atelier API",!
		zwrite errors
		write !
		return $$$ERROR($$$GeneralError,"Problem fetching document list from Atelier API")
	}
	
	//Extract document content, and decode from Base64 if encoded
	set enc=response.result.enc
	set content=response.result.content
	set contentLines=content.%GetIterator()

	//todo, get enc working
	//if enc=1 set content=##class(%SYSTEM.Encryption).Base64Decode(content)
	if enc=1 quit $$$OK
	
	//now push to the Cube
	set cubesReq=##class(%Net.HttpRequest).%New()
	set cubesReq.Server=$p($p(pCubeURL,"/",1),":",1)
	set cubesReq.Port=$p($p(pCubeURL,"/",1),":",2)
	set cubesReq.Username=pCubeUserName
	set cubesReq.Password=pCubePassword
	set cubesReq.ContentType=..GetContentTypeForExtensionName($piece(pAterlierDocName,".",*))
	while contentLines.%GetNext(.key,.line) {
		do cubesReq.EntityBody.WriteLine(line)
	}
	
	set safeDocName=$Replace(docName,"/","\")
	do cubesReq.Post("/"_$p(pCubeURL,"/",2,*)_"/"_safeDocName)
	
	//Handle Cube API errors
	if cubesReq.HttpResponse.StatusCode'=200 {
		write !,"Failed: ",cubesReq.HttpResponse.StatusLine
		return $$$ERROR($$$GeneralError,"Error fetching document")	
	}
	
	quit $$$OK
}

ClassMethod GetContentTypeForExtensionName(pExtensionName)
{
	//if pExtensionName="" return ""
	return "text/plain"
}

}

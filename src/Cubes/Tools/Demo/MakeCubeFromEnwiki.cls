Class Cubes.Tools.Demo.MakeCubeFromEnwiki Extends %RegisteredObject
{

Parameter MYLOCALENWIK9 = "D:\tfb\enwik9\enwik9.xml";

ClassMethod Go()
{
	//if '$d(^Cubes("enwik8")) set ^Cubes("enwik8")=$i(^Cubes)
	if '$d(^Cubes("enwik9")) set ^Cubes("enwik9")=$i(^Cubes)
	do ..PopulateCubeFromEnwik()
}

/// do ##class(Galumpher.Readers.MediaWiki).ReadEnwik(8)
ClassMethod PopulateCubeFromEnwik() As %Status
{
	set sc=$$$OK
	set reader=##class(%XML.Reader).%New()
	
	write !!,"Opening ",..#MYLOCALENWIK9
	set sc=reader.OpenFile(..#MYLOCALENWIK9)
	if $$$ISERR(sc) write !!,$System.Status.GetErrorText(sc),!! return sc
		
	//iterate over pages
	do reader.Correlate("page","Cubes.Tools.Demo.MediaWiki.PageType")
	#dim page as Cubes.Tools.Demo.MediaWiki.PageType
	while reader.Next(.page,.sc) {
		if $$$ISERR(sc) write !!,$System.Status.GetErrorText(sc),!! return sc
		
		set text=page.revision.GetAt(1).text.content
		
		//now push to the Cube
		set cubesReq=##class(%Net.HttpRequest).%New()
		set cubesReq.Server="localhost"
		set cubesReq.Port=52773
		set cubesReq.Username="sean"
		set cubesReq.Password="1qaz"
		set cubesReq.ContentType="text/plain"
		do cubesReq.EntityBody.Write(page.revision.GetAt(1).text.content)
		set url="/cubes/enwik9/object/"_$replace(page.title,"/","-")
		w !,url
		do cubesReq.Post(url)
		
		//handle Cube API errors
		if cubesReq.HttpResponse.StatusCode'=200 {
			write !,"Failed: ",cubesReq.HttpResponse.StatusLine
			return $$$ERROR($$$GeneralError,"Error fetching document")	
		}
		
	}
	return sc
}

}

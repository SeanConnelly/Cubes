Class Cubes.Tools.Demo.MakeCubeFromFHIR Extends %RegisteredObject
{

ClassMethod Go()
{
	if '$d(^Cubes("fhir")) set ^Cubes("fhir")=$i(^Cubes)
	set folder="D:\tfb\fhir-samples\FHIR"
	do ..PopulateCubeFromFiles(folder)
}

ClassMethod PopulateCubeFromFiles(pFolder As %String)
{
 	set folder=##class(%File).NormalizeDirectory(pFolder)
 	set result=##class(%ResultSet).%New("%File:FileSet")
 	do result.Execute(folder,"*.json")
 	while result.Next() {
	 	
	 	set fileName=result.GetDataByName("Name")
		
		set file=##class(%FileCharacterStream).%New()
		set sc=file.LinkToFile(fileName)
		set fileText=file.Read(1000000)

		//do a lazy split of JSON into sections of text by resource and tidy up
		//IRL would need a solution server side to format different types
		set fileText=$replace($tr(fileText,$c(13,10),""),"""resource""",$c(10)_"""resource""")
		set fileText=$replace(fileText,$c(9)," ")
		while fileText["  " { set fileText=$replace(fileText,"  "," ") }

		//and lets make the test data a bit prettier, just for these tests
		set fileName=$p($p(fileName,"\",*),".")
		set first=$p(fileName,"_",1)
		set last=$p(fileName,"_",2)
		set fileText=$replace(fileText,first,$tr(first,"1234567890",""))
		set fileText=$replace(fileText,last,$tr(last,"1234567890",""))		
		set fileName=$replace(fileName,first,$tr(first,"1234567890",""))
		set fileName=$replace(fileName,last,$tr(last,"1234567890",""))
		
		//now push to the Cube
		set cubesReq=##class(%Net.HttpRequest).%New()
		set cubesReq.Server="localhost"
		set cubesReq.Port=52773
		set cubesReq.Username="sean"
		set cubesReq.Password="1qaz"
		set cubesReq.ContentType="text/plain"
		do cubesReq.EntityBody.Write(fileText)
		set url="/cubes/fhir/object/"_$p($p(fileName,"\",*),".")
		do cubesReq.Post(url)
		
		//handle Cube API errors
		if cubesReq.HttpResponse.StatusCode'=200 {
			write !,"Failed: ",cubesReq.HttpResponse.StatusLine
			return $$$ERROR($$$GeneralError,"Error fetching document")	
		}
		
 	}
 	
 	quit $$$OK
}

}

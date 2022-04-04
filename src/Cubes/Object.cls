Class Cubes.Object Extends %RegisteredObject
{

ClassMethod Upsert(pCubeId As %Integer, pContent As %CSP.CharacterStream, pContentType As %String, pObjectName As %String = "", ByRef pOID As %Integer = "") As %Status
{
	if pOID'="" {
		if $d(^CubesD(pCubeId)) quit $$$ERROR($$$GeneralError,"404 Object does not exist")
		if pContentType="" set pContentType=$lg(^CubesD(pCubeId,pOID,0),2)
	}
	if pOID="" set pOID=$i(^CubesD(pCubeId))
	set pObjectName=$replace(pObjectName,"%2F","/")
	set ^CubesD(pCubeId,pOID,0)=$lb(pContentType,pObjectName)
	while pContent.AtEnd=0 {
		set ^CubesD(pCubeId,pOID,$i(^CubesD(pCubeId,pOID)))=pContent.ReadLine()
	}
	set ^CubesD(pCubeId)=$get(^CubesD(pCubeId))+1
	do ..BuildIndices(pCubeId,pOID)
	quit $$$OK
}

ClassMethod Delete(pCubeId As %Integer, pOID As %Integer) As %Status
{
	if '$d(^CubesD(pCubeId)) quit $$$ERROR($$$GeneralError,"404 Object does not exist")
	do ..DeleteIndices(pCubeId,pOID)
	kill ^CubesD(pCubeId,pOID)
	quit $$$OK
}

ClassMethod OutputObjectToResponse(pCubeId As %Integer, pOID As %Integer) As %Status
{
	if '$d(^CubesD(pCubeId,pOID,0)) quit $$$ERROR($$$GeneralError,"404 Object does not exist")
	set %response.ContentType=^CubesD(pCubeId,pOID,0)
	set ln=$o(^CubesD(pCubeId,pOID,0))
	set newLine=""
	while ln'="" {
		write newLine,^CubesD(pCubeId,pOID,ln)
		set newLine=$c(13,10)
		set ln=$o(^CubesD(pCubeId,pOID,ln))
	}
	quit $$$OK
}

ClassMethod OutputObjectQueryToResponse(pCubeId As %Integer)
{
	set query=$get(%request.Data("$query",1))
	//for now queries only work with alpha numericri
	//stngs,es so do a dumb strip leaving minus and 
	//wildcard, the index work the same way, so we
	//will still get hits=$tr(query,"^%$##()"," ")
	
	//build a list of includes and excludes
	for i=1:1:$l(query," ") {
		set word=$p(query," ",i)
		if word="" continue
		if $e(word)="-" {
			set word=$e(word,2,*)
			if $d(^CubesI(pCubeId,word)) {
				set exclude(word)=""	
			}			
		} elseif $e(word,*)="*" {
			set w1=$e(word,1,*-1)
			set w2=$o(^CubesI(pCubeId,w1))
			set w3=$o(^CubesI(pCubeId,w1_"ZZZ"))
			while (w2'="")!(w2'=w3) {
				set freq=^CubesI(pCubeId,w2)
				set include(freq,w2)="" 
			}
		} else {
			if $d(^CubesI(pCubeId,word)) {
				set freq=^CubesI(pCubeId,word)
				set include(freq,word)=""	
			}	
		}
	}
	
	//build the smallest possible list of oids first (using least frequent word(s)
	if $d(include) {
		set freq=$o(include(""))
		set word=$o(include(freq,""))
		while word'="" {
			set oid=$o(^CubesI(pCubeId,word,""))
			while oid'="" {
				set oids(oid)=$g(oids(oid))_"~"_word
				set oid=$o(^CubesI(pCubeId,word,oid))
			}
			set word=$o(include(freq,word))
		}
	}
	
	//now cross check that each of these oids is either in the other includes or should be excluded
	set oid=$order(oids(""))
	while oid'="" {
		set reject=0
		set f2=$o(include(freq))
		while f2'="",reject=0 {
			set word=$o(include(freq,word))
			while word'="",reject=0 {
				//this word is not in this object, so reject the object id
				if '$d(^CubesI(pCubeId,word,oid)) set reject=1
				set word=$o(include(freq,word))
			}
			set f2=$o(include(f2))
		}
		set word=$o(exclude(""))
		while word'="",'reject {
			//this word is in this object, so exclude it by rejecting the object id
			if $d(^CubesI(pCubeId,word,oid)) set reject=1
			set word=$o(exclude(word))	
		}
		if reject kill oids(oid)
		set oid=$order(oids(oid))
	}
	
	//we are now left with an array of oids that contain all the include words and not the exclude words
	set results=[]
	set oid=$o(oids(""))
	while oid'="" {		
		for i=2:1:$l(oids(oid),"~") {
			set word=$p(oids(oid),"~",i)
			set ln=$order(^CubesI(pCubeId,word,oid,""))
			while ln'="" {
				set text=$get(^CubesD(pCubeId,oid,ln),"")
				set type=$lg(^CubesD(pCubeId,oid,0),1)
				set name=$lg(^CubesD(pCubeId,oid,0),2)
				set result=[(pCubeId),(word),(oid),(name),(ln),(text)]
				if text'="" do results.%Push(result)
				set ln=$order(^CubesI(pCubeId,word,oid,ln))
			}
		}
		set oid=$o(oids(oid))
	}
	do results.%ToJSON()
	quit $$$OK
}

ClassMethod BuildIndices(pCubeId As %Integer, pOID As %Integer)
{
	set ln=$o(^CubesD(pCubeId,pOID,0))
	while ln'="" {
		set word=""
		set data=^CubesD(pCubeId,pOID,ln)
		for i=1:1:$l(data) {
			set char=$e(data,i)
			if (char?1AN)||(char=".") {
				set word=word_char		
			} else {
				if word'="" {
					//if the word count grows to 5000 then consider it noise (todo: move this to config)
					if $d(^CubesI(pCubeId,word)),(^CubesI(pCubeId,word)>4999) {
						if $d(^CubesI(pCubeId,word))=11 {
							kill ^CubesI(pCubeId,word)
							set ^CubesI(pCubeId,word)=5000
						}
					} else {
						set ^CubesI(pCubeId,word,pOID,ln)=""
						set ^CubesI(pCubeId,word)=$get(^CubesI(pCubeId,word))+1				
					}
				}
				set word=""
			}
		}
		if word'="" {
			//if the word count grows to 5000 then consider it noise (todo: move this to config)
			if $d(^CubesI(pCubeId,word)),(^CubesI(pCubeId,word)>4999) {
				if $d(^CubesI(pCubeId,word))=11 {
					kill ^CubesI(pCubeId,word)
					set ^CubesI(pCubeId,word)=5000
				}
			} else {
				set ^CubesI(pCubeId,word,pOID,ln)=""
				set ^CubesI(pCubeId,word)=$get(^CubesI(pCubeId,word))+1				
			}
		}		
		set ln=$o(^CubesD(pCubeId,pOID,ln))
	}
}

ClassMethod DeleteIndices(pCubeId As %Integer, pOID As %Integer)
{
	set ln=$o(^CubesD(pCubeId,pOID,0))
	while ln'="" {
		set word=""
		set data=^CubesD(pCubeId,pOID,ln)
		for i=1:1:$l(data) {
			set char=$e(data,i)
			if (char?1AN)||(char=".") {
				set word=word_char		
			} else {
				if word'="",$d(^CubesI(pCubeId,word,pOID)) {
					kill ^CubesI(pCubeId,word,pOID)
				}
				set word=""
			}
		}
		if word'="",$d(^CubesI(pCubeId,word,pOID)) kill ^CubesI(pCubeId,word,pOID)	
		set ln=$o(^CubesD(pCubeId,pOID,ln))
	}
}

}

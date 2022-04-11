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
	
	//make a cube option? or an upser value?
	set pContent.LineTerminator=$c(10)
	
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
	set query=$tr(query,"[,\/#!$%\^&\;:{}=\_`~()","                       ")
	//set query=$zcvt(query,"L")
	
	//split the search query string up into an array of includes and excludes
	for i=1:1:$l(query," ") {
		set word=$p(query," ",i)
		if word="" continue
		if $e(word)="-" {
			set word=$e(word,2,*)
			if $d(^CubesI(pCubeId,word)) {
				set exclude(word)=""	
			}			
		} elseif $e(word,*)="*" {
			set wildcards($p(word,"*"))=""
		} else {
			if $d(^CubesI(pCubeId,word)) {
				set freq=^CubesI(pCubeId,word)
				set include(freq,word)=""
				set words(word)=""	
			} else {
				set include(0,word)=""
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
				set oids(oid)=$get(oids(oid))_" "_word
				set oid=$o(^CubesI(pCubeId,word,oid))
			}
			set word=$o(include(freq,word))
		}
	}
	
	//now cross check that each of these oids is either in the other includes or should be excluded
	set oid=$order(oids(""))
	while oid'="" {
		
		//keep includes else reject
		set reject=0
		set f2=$o(include(freq))
		while f2'="",reject=0 {
			set word=$o(include(f2,word))
			while word'="",reject=0 {
				//this word is not in this object, so reject the object id
				if '$d(^CubesI(pCubeId,word,oid)) set reject=1
				set word=$o(include(f2,word))
			}
			set f2=$o(include(f2))
		}
		
		//reject excludes
		set word=$o(exclude(""))
		while word'="",'reject {
			//this word is in this object, so exclude it by rejecting the object id
			if $d(^CubesI(pCubeId,word,oid)) set reject=1
			set word=$o(exclude(word))	
		}
		
		//remove rejects from oid list
		if reject kill oids(oid)
		
		set oid=$order(oids(oid))
	}
			
	//we are now left with an array of oids that contain all the include words and not the exclude words
	set oid=$o(oids(""))
	while oid'="" {
		set word=$order(words(""))
		while word'="" {
			set ln=$order(^CubesI(pCubeId,word,oid,""))
			while ln'="" {
				set tmp(oid,ln)={"oid":(oid),"tag":($lg(^CubesD(pCubeId,oid,0),2)),"line":(ln),"text":($get(^CubesD(pCubeId,oid,ln),""))}
				set ln=$order(^CubesI(pCubeId,word,oid,ln))
			}			
			set word=$order(words(word))
		}
		set oid=$o(oids(oid))
	}
	
	//do one final pass for any wildcards
	set wildcard=$o(wildcards(""))
	kill ^sean
	while wildcard'="" {
		set ^sean($i(^sean))=wildcard
		set oid=$o(oids(""))
		while oid'="" {
			set keep=0
			set ln=$o(^CubesD(pCubeId,oid,0)) 
			while ln'="" {
				if ^CubesD(pCubeId,oid,ln)[wildcard set keep=1
				set ln=$o(^CubesD(pCubeId,oid,ln)) 				
			}
			if keep=0 kill oids(oid)				
			set oid=$o(oids(oid))
		}
		set wildcard=$o(wildcards(wildcard))
	}
	
	//now spin the lines of results out
	set max=5000,count=0
	set results=[]
	set oid=$o(tmp(""))
	while oid'="",count<max {
		set ln=$o(tmp(oid,""))
		while ln'="" {
			do results.%Push(tmp(oid,ln))
			set count=count+1
			set ln=$o(tmp(oid,ln))
		}
		set oid=$o(tmp(oid))
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
			if (char?1AN)||(char=".")||(char="-") {
				set word=word_char		
			} else {
				if word'="" do ..IndexWord(pCubeId,word,pOID,ln)
				set word=""
			}
		}
		if word'="" do ..IndexWord(pCubeId,word,pOID,ln)		
		set ln=$o(^CubesD(pCubeId,pOID,ln))
	}
}

ClassMethod IndexWord(pCubeId, word, pOID, ln)
{
	if word="" quit
	//set word=$zcvt(word,"L")
	if $d(^CubesI(pCubeId,word)),(^CubesI(pCubeId,word)=1000000) {
		if $d(^CubesI(pCubeId,word))=11 {
			kill ^CubesI(pCubeId,word)
			set ^CubesI(pCubeId,word)=1000001
		}	
	} else {
		set ^CubesI(pCubeId,word,pOID,ln)=""
		set ^CubesI(pCubeId,word)=$get(^CubesI(pCubeId,word))+1				
	}
	if word["." for i=1:1:$l(word,".") do ..IndexWord(pCubeId,$p(word,".",i),pOID,ln)
	if word["-" for i=1:1:$l(word,"-") if $p(word,"-",i)?1.A do ..IndexWord(pCubeId,$p(word,"-",i),pOID,ln)
}

ClassMethod DeleteIndices(pCubeId As %Integer, pOID As %Integer)
{
	//TODO: Rewrite after index R&D is out of flux...
	set ln=$o(^CubesD(pCubeId,pOID,0))
	while ln'="" {
		set word=""
		set data=^CubesD(pCubeId,pOID,ln)
		for i=1:1:$l(data) {
			set char=$e(data,i)
			if (char?1AN)||(char=".")||(char="-") {
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

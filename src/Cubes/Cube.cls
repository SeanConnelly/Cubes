Class Cubes.Cube Extends %RegisteredObject
{

Property CID As %Integer;

Property CubeName As %String;

ClassMethod RegisterCube(pCubeName)
{
	set ^Cubes(pCubeName)=$i(^Cubes)
	quit $$$OK
}

ClassMethod OutputCubeListToResponse()
{
	#dim list As %DynamicArray
	set list=[]
	set cubeName=$o(^Cubes(""))
	while cubeName'="" {
		do list.%Push(cubeName)		
		set cubeName=$o(^Cubes(cubeName))
	} 
	do list.%ToJSON()
	quit $$$OK
}

/// Returns ID or Zero does not exist
ClassMethod GetId(pCubeName)
{
	quit $get(^Cubes(pCubeName),0)
}

}

/// Created from: https://www.mediawiki.org/xml/export-0.3.xsd
Class Cubes.Tools.Demo.MediaWiki.NamespaceType Extends (%SerialObject, %XML.Adaptor) [ ProcedureBlock ]
{

Parameter ELEMENTQUALIFIED = 1;

// Parameter NAMESPACE = "http://www.mediawiki.org/xml/export-0.3/";

Parameter XMLNAME = "NamespaceType";

Parameter XMLSEQUENCE = 1;

Property content As %String(MAXLEN = "", XMLNAME = "content", XMLPROJECTION = "CONTENT");

Property key As %Integer(XMLNAME = "key", XMLPROJECTION = "ATTRIBUTE");

Storage Default
{
<Data name="NamespaceTypeState">
<Value name="1">
<Value>content</Value>
</Value>
<Value name="2">
<Value>key</Value>
</Value>
</Data>
<State>NamespaceTypeState</State>
<StreamLocation>^Galumpher.ReB131.NamespaceTypeS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

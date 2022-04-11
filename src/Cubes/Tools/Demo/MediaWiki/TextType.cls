/// Created from: https://www.mediawiki.org/xml/export-0.3.xsd
Class Cubes.Tools.Demo.MediaWiki.TextType Extends (%SerialObject, %XML.Adaptor) [ ProcedureBlock ]
{

Parameter ELEMENTQUALIFIED = 1;

// Parameter NAMESPACE = "http://www.mediawiki.org/xml/export-0.3/";

Parameter XMLNAME = "TextType";

Parameter XMLSEQUENCE = 1;

Property content As %String(MAXLEN = "", XMLNAME = "content", XMLPROJECTION = "CONTENT");

Property space As %String(MAXLEN = "", XMLNAME = "space", XMLPROJECTION = "XMLATTRIBUTE") [ SqlFieldName = _space ];

Storage Default
{
<Data name="TextTypeState">
<Value name="1">
<Value>content</Value>
</Value>
<Value name="2">
<Value>space</Value>
</Value>
</Data>
<State>TextTypeState</State>
<StreamLocation>^Galumpher.ReadersB131.TextTypeS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

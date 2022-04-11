/// Created from: https://www.mediawiki.org/xml/export-0.3.xsd
Class Cubes.Tools.Demo.MediaWiki.ContributorType Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

Parameter ELEMENTQUALIFIED = 1;

// Parameter NAMESPACE = "http://www.mediawiki.org/xml/export-0.3/";

Parameter XMLNAME = "ContributorType";

Parameter XMLSEQUENCE = 1;

Property username As %String(MAXLEN = "", XMLNAME = "username");

Property id As %xsd.positiveInteger(XMLNAME = "id");

Property ip As %String(MAXLEN = "", XMLNAME = "ip");

}

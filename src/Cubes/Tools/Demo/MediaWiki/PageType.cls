/// Created from: https://www.mediawiki.org/xml/export-0.3.xsd
Class Cubes.Tools.Demo.MediaWiki.PageType Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

Parameter ELEMENTQUALIFIED = 1;

// Parameter NAMESPACE = "http://www.mediawiki.org/xml/export-0.3/";

Parameter XMLNAME = "PageType";

Parameter XMLSEQUENCE = 0;

Property title As %String(MAXLEN = "", XMLNAME = "title") [ Required ];

Property id As %xsd.positiveInteger(XMLNAME = "id");

Property restrictions As %String(MAXLEN = "", XMLNAME = "restrictions");

Property revision As list Of Cubes.Tools.Demo.MediaWiki.RevisionType(XMLNAME = "revision", XMLPROJECTION = "ELEMENT");

Property upload As list Of Cubes.Tools.Demo.MediaWiki.UploadType(XMLNAME = "upload", XMLPROJECTION = "ELEMENT");

}

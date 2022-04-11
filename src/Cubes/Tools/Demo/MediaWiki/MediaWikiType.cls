/// Created from: https://www.mediawiki.org/xml/export-0.3.xsd
Class Cubes.Tools.Demo.MediaWiki.MediaWikiType Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

Parameter ELEMENTQUALIFIED = 1;

// Parameter NAMESPACE = "http://www.mediawiki.org/xml/export-0.3/";

Parameter XMLNAME = "MediaWikiType";

Parameter XMLSEQUENCE = 1;

Property siteinfo As Cubes.Tools.Demo.MediaWiki.SiteInfoType(XMLNAME = "siteinfo");

Property page As list Of Cubes.Tools.Demo.MediaWiki.PageType(XMLNAME = "page", XMLPROJECTION = "ELEMENT");

Property version As %String(MAXLEN = "", XMLNAME = "version", XMLPROJECTION = "ATTRIBUTE") [ Required ];

Property lang As %String(MAXLEN = "", XMLNAME = "lang", XMLPROJECTION = "XMLATTRIBUTE") [ Required ];

}

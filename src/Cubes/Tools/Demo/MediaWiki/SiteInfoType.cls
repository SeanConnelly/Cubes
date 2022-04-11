/// Created from: https://www.mediawiki.org/xml/export-0.3.xsd
Class Cubes.Tools.Demo.MediaWiki.SiteInfoType Extends (%RegisteredObject, %XML.Adaptor) [ CompileAfter = Cubes.Tools.Demo.MediaWiki.CaseType, ProcedureBlock ]
{

Parameter ELEMENTQUALIFIED = 1;

// Parameter NAMESPACE = "http://www.mediawiki.org/xml/export-0.3/";

Parameter XMLNAME = "SiteInfoType";

Parameter XMLSEQUENCE = 1;

Property sitename As %String(MAXLEN = "", XMLNAME = "sitename");

Property base As %xsd.anyURI(XMLNAME = "base");

Property generator As %String(MAXLEN = "", XMLNAME = "generator");

Property case As Cubes.Tools.Demo.MediaWiki.CaseType(XMLNAME = "case") [ SqlFieldName = _case ];

Property namespaces As list Of Cubes.Tools.Demo.MediaWiki.NamespaceType(XMLITEMNAME = "namespace", XMLNAME = "namespaces", XMLPROJECTION = "COLLECTION");

}

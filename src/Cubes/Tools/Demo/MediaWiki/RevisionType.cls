/// Created from: https://www.mediawiki.org/xml/export-0.3.xsd
Class Cubes.Tools.Demo.MediaWiki.RevisionType Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

Parameter ELEMENTQUALIFIED = 1;

// Parameter NAMESPACE = "http://www.mediawiki.org/xml/export-0.3/";

Parameter XMLNAME = "RevisionType";

Parameter XMLSEQUENCE = 1;

Property id As %xsd.positiveInteger(XMLNAME = "id");

Property timestamp As %TimeStamp(XMLNAME = "timestamp") [ Required ];

Property contributor As Cubes.Tools.Demo.MediaWiki.ContributorType(XMLNAME = "contributor") [ Required ];

Property minor As %String(MAXLEN = "", XMLNAME = "minor");

Property comment As %String(MAXLEN = "", XMLNAME = "comment");

Property text As Cubes.Tools.Demo.MediaWiki.TextType(XMLNAME = "text") [ Required ];

}

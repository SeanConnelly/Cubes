/// Created from: https://www.mediawiki.org/xml/export-0.3.xsd
Class Cubes.Tools.Demo.MediaWiki.UploadType Extends (%RegisteredObject, %XML.Adaptor) [ ProcedureBlock ]
{

Parameter ELEMENTQUALIFIED = 1;

// Parameter NAMESPACE = "http://www.mediawiki.org/xml/export-0.3/";

Parameter XMLNAME = "UploadType";

Parameter XMLSEQUENCE = 1;

Property timestamp As %TimeStamp(XMLNAME = "timestamp") [ Required ];

Property contributor As Cubes.Tools.Demo.MediaWiki.ContributorType(XMLNAME = "contributor") [ Required ];

Property comment As %String(MAXLEN = "", XMLNAME = "comment");

Property filename As %String(MAXLEN = "", XMLNAME = "filename") [ Required ];

Property src As %xsd.anyURI(XMLNAME = "src") [ Required ];

Property size As %xsd.positiveInteger(XMLNAME = "size") [ Required ];

}

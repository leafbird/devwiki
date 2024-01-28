## xml

### xml validation in C#
from http://stackoverflow.com/questions/572853/xml-validation-using-xsd-schema 이 방법은 좀 별로인듯.
https://docs.microsoft.com/ko-kr/dotnet/csharp/programming-guide/concepts/linq/how-to-validate-using-xsd-linq-to-xml 이게 더 심플함.

```
XmlDocument x = new XmlDocument();
x.LoadXml(XmlSource);

XmlReaderSettings settings = new XmlReaderSettings();
settings.CloseInput = true;     
settings.ValidationEventHandler += Handler;

settings.ValidationType = ValidationType.Schema;
settings.Schemas.Add(null, ExtendedTreeViewSchema);
settings.ValidationFlags =
     XmlSchemaValidationFlags.ReportValidationWarnings |
XmlSchemaValidationFlags.ProcessIdentityConstraints |
XmlSchemaValidationFlags.ProcessInlineSchema |
XmlSchemaValidationFlags.ProcessSchemaLocation ;

StringReader r = new StringReader(XmlSource);

using (XmlReader validatingReader = XmlReader.Create(r, settings)) {
        while (validatingReader.Read()) { /* just loop through document */ }
}
-------------------------------------------------------------------------------------
private static void Handler(object sender, ValidationEventArgs e)
{
        if (e.Severity == XmlSeverityType.Error || e.Severity == XmlSeverityType.Warning)
          System.Diagnostics.Trace.WriteLine(
            String.Format("Line: {0}, Position: {1} \"{2}\"",
                e.Exception.LineNumber, e.Exception.LinePosition, e.Exception.Message));

}
```

### Apply XSLT to XML transformation on C#

source: https://gist.github.com/ivanignatiev/aa5f8686e325901b4dbf
```
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.XPath;
using System.Xml.Xsl;

namespace ApplyXSLTToXML
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 2)
            {
                Console.WriteLine("Error:");
                Console.WriteLine("Not enough parameters to run this application");
                return;
            }

            string XMLFilePath = args[0];
            string XSLTFilePath = args[1];

            // ApplyXSLTToXML.exe Input.xml Transformation.xslt 

            try
            {
                // Load documents 

                var xmlDocument = new XPathDocument(XMLFilePath);
                var xslt = new XslCompiledTransform();

                xslt.Load(XSLTFilePath);

                // Apply transformation and output results to console
                var consoleWriter = new StreamWriter(Console.OpenStandardOutput());
                consoleWriter.AutoFlush = true;
                xslt.Transform(xmlDocument, null, consoleWriter);
                
            }
            catch (Exception e)
            {

                Console.WriteLine("Error:");
                Console.WriteLine(e.Message);

            }
        }
    }
}
```

## element 순서가 상관 없도록 스키마 정의하기

출처 : http://forums.asp.net/t/1494693.aspx?Defining+the+element+node+in+non+sequence+order+in+XSD

```
<?xml version="1.0" encoding="utf-8"?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="persons">
    <xs:complexType>
      <xs:sequence>
        <xs:element maxOccurs="unbounded" name="person">
          <xs:complexType>
            <xs:sequence>
              <xs:choice maxOccurs="unbounded">
                <xs:element name="familyName" type="xs:string" />
                <xs:element name="firstName" type="xs:string" />
              </xs:choice>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>
```
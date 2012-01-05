<?xml version="1.0"?>
<!--
  A stylesheet to consume a CNXML 0.6 document and return the same, 
  with @id added for each element where it is required but not 
  present in the input document.

  To add @id to more CNXML elements, add further 'req:element' 
  elements to 'req:required-ids', with the unqualified name in @name 
  and the value of @display (if any) in 'display'.

  If a string-param 'id-prefix' is passed in, it's string value will 
  be prefixed to any auto-generated ID values.  The idea is to permit 
  us to track the part of the authoring interface in which the @id 
  was added.
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cnxml="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md4="http://cnx.rice.edu/mdml/0.4"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:q="http://cnx.rice.edu/qml/1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:cc="http://web.resource.org/cc/"
  xmlns:cnx="http://cnx.rice.edu/contexts#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:req="#required-ids"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
>

  <xsl:param name="id-prefix" select="''"/>
  <req:required-ids>
    <req:element name="document" display=""/>
    <req:element name="para" display=""/>
    <req:element name="equation" display=""/>
    <req:element name="list" display="block"/>
    <req:element name="list" display="none"/>
    <req:element name="list" display=""/>
    <req:element name="exercise" display=""/>
    <req:element name="definition" display=""/>
    <req:element name="rule" display=""/>
    <req:element name="table" display=""/>
    <req:element name="div" display=""/>
    <req:element name="section" display=""/>
    <req:element name="figure" display=""/>
    <req:element name="subfigure" display=""/>
    <req:element name="example" display=""/>
    <req:element name="note" display="block"/>
    <req:element name="note" display="none"/>
    <req:element name="note" display=""/>
    <req:element name="footnote" display=""/>
    <req:element name="problem" display=""/>
    <req:element name="solution" display=""/>
    <req:element name="quote" display="block"/>
    <req:element name="quote" display="none"/>
    <req:element name="quote" display=""/>
    <req:element name="code" display="block"/>
    <req:element name="preformat" display="block"/>
    <req:element name="preformat" display="none"/>
    <req:element name="preformat" display=""/>
    <req:element name="media" display="block"/>
    <req:element name="media" display="inline"/>
    <req:element name="media" display="none"/>
    <req:element name="media" display=""/>
    <req:element name="meaning" display=""/>
    <req:element name="proof" display=""/>
    <req:element name="statement" display=""/>
    <req:element name="commentary" display=""/>
    <req:element name="preformat" display="block"/>
  </req:required-ids>

  <xsl:variable name="required-ids" select="document('')/xsl:stylesheet/req:required-ids"/>

  <xsl:template match="node()|@*">
    <xsl:variable name="element-name">
      <xsl:if test="self::cnxml:*">
        <xsl:value-of select="local-name(self::*)"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="display" select="normalize-space(@display)"/>
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="self::* and $required-ids/req:element[@name=$element-name][@display=$display] and not(ancestor::md4:abstract or ancestor::md:abstract)">
          <xsl:attribute name="id">
            <xsl:value-of select="concat($id-prefix, generate-id())"/>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

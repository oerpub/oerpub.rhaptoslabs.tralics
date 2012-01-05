<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns="http://cnx.rice.edu/cnxml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:office="http://openoffice.org/2000/office"
  xmlns:style="http://openoffice.org/2000/style" 
  xmlns:text="http://openoffice.org/2000/text" 
  xmlns:table="http://openoffice.org/2000/table" 
  xmlns:draw="http://openoffice.org/2000/drawing" 
  xmlns:fo="http://www.w3.org/1999/XSL/Format" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:number="http://openoffice.org/2000/datastyle" 
  xmlns:svg="http://www.w3.org/2000/svg" 
  xmlns:chart="http://openoffice.org/2000/chart" 
  xmlns:dr3d="http://openoffice.org/2000/dr3d" 
  xmlns:math="http://www.w3.org/1998/Math/MathML" 
  xmlns:form="http://openoffice.org/2000/form" 
  xmlns:script="http://openoffice.org/2000/script" 
  office:class="text" office:version="1.0"
  exclude-result-prefixes="office style text table draw fo xlink number svg chart dr3d math form script"
  >

  <xsl:param name="stylesPath"/>
  <xsl:variable name="office-styles" select="document($stylesPath)/office:document-styles"/>

<!-- single entry tables are used for presentation purposes only, we hope. -->

  <xsl:template name="handle.one.entry.table">
    <xsl:param name="one.entry" />
    <xsl:if test='count($one.entry/text:h)=1'>
      <xsl:comment>found a single entry table with a single header.</xsl:comment>
      <text:section>
        <xsl:attribute name='id'>
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:apply-templates select='$one.entry/*'/>
      </text:section>
    </xsl:if>
    <xsl:if test='count($one.entry/text:h)=0'>
      <xsl:comment>found a single entry table without any header.</xsl:comment>
      <xsl:apply-templates select='$one.entry/*'/>
    </xsl:if>
    <xsl:if test='count($one.entry/text:h)>1'>
      <xsl:comment>found a single entry table with many headers.</xsl:comment>
      <text:section>
        <xsl:attribute name='id'>
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:apply-templates select='$one.entry/*'/>
      </text:section>
    </xsl:if>
  </xsl:template>

  <xsl:template match="table:table[count(./table:table-row/table:table-cell)=1]">
    <xsl:call-template name="handle.one.entry.table">
      <xsl:with-param name="one.entry" select="./table:table-row/table:table-cell[position()=1]" />
    </xsl:call-template>
  </xsl:template>

<!-- single entry ordered lists are used for presentation purposes only, we hope. -->

  <xsl:template match="text:ordered-list[count(child::*)=1 and ./text:list-item/text:ordered-list]">
      <xsl:apply-templates select="./text:list-item/*" />
  </xsl:template>

<!-- header children in draw:text-box need to be converted to paragraphs. -->

  <xsl:template match="draw:text-box/text:h">
    <text:p>
      <xsl:apply-templates/>
    </text:p>
  </xsl:template>

<!-- convert Heading 1/2/3 paragraphs into headers. -->

  <xsl:template match="text:p[@text:style-name='Heading 1']">
    <text:h text:style-name="Heading 1" text:level="1">
      <xsl:apply-templates/>
    </text:h>
  </xsl:template>

  <xsl:template match="text:p[@text:style-name='Heading 2']">
    <text:h text:style-name="Heading 2" text:level="2">
      <xsl:apply-templates/>
    </text:h>
  </xsl:template>

  <xsl:template match="text:p[@text:style-name='Heading 3']">
    <text:h text:style-name="Heading 3" text:level="3">
      <xsl:apply-templates/>
    </text:h>
  </xsl:template>

<!--  remove header if it only contains an image. -->

  <xsl:template match="text:h[count(child::*)=1 and (
                              draw:object or draw:object-ole or draw:image)]">
      <xsl:apply-templates/>
  </xsl:template>

<!-- Eliminate Headings After the Last Glossary -->

  <xsl:template match="text:h[preceding-sibling::text:p[@text:style-name='CNXML Glossary Section']]">
  </xsl:template>

<!-- convert header to paragraph if it contains an image and other stuff. -->

  <xsl:template match="text:h[draw:object or draw:object-ole or draw:image]">
    <text:p>
      <xsl:attribute name='id'>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </text:p>
  </xsl:template>

<!-- remove ordered list with only a header but leave the header's children. -->

  <xsl:template match="text:ordered-list[count(child::*)=1 and child::text:list-header]">
      <xsl:apply-templates select="./text:list-header/*"/>
  </xsl:template>

<!-- productions make sure the unmodified input is written to output -->

  <xsl:template match="office:automatic-styles">
    <xsl:copy-of select="$office-styles/office:styles"/>
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="@*|comment()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="*[not(self::text:p
              [count(text()| child::*[not(self::text:s)]) &lt; 1])
            and not(self::office:automatic-styles)]
  ">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

<!-- remove empty para, headers, and spans. -->

  <xsl:template match="text:h[count(node())=0]" />

  <xsl:template match="text:span[count(node())=0]" />

  <xsl:template match="text:p/text:line-break" />

  <xsl:template match="text:p[count(node())=0]">
    <xsl:if test="@text:style-name='CNXML Code (Block)' and preceding-sibling::*[1]/@text:style-name='CNXML Code (Block)'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>


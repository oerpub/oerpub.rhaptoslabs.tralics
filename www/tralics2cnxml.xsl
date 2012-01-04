<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:bib="http://bibtexml.sf.net/"
  >
<!--xsl:stylesheet version="1.0"
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
  xmlns:m="http://www.w3.org/1998/Math/MathML"
-->

  <xsl:output omit-xml-declaration="no" indent="yes" method="xml" />

  <xsl:key name="div_by_id" match="div0|div1|div2|div3" use="@id" />
  <xsl:key name="citation_by_id" match="citation" use="@id" />

  <xsl:template match="/">
    <document xmlns="http://cnx.rice.edu/cnxml" xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/" xmlns:q="http://cnx.rice.edu/qml/1.0" module-id="m12345" cnxml-version="0.7">
      <xsl:attribute name="id">
        <xsl:value-of select ="generate-id()" />
      </xsl:attribute>
      <title>
        <xsl:text>Untitled Document</xsl:text>
      </title>

      <content>
        <xsl:apply-templates />
      </content>

      <xsl:if test="//biblio">
        <xsl:apply-templates select="//biblio" mode="biblio"/>
      </xsl:if>

    </document>
  </xsl:template>

  <xsl:template match="*">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:template>
<!--
  <xsl:template match="@*">
    <xsl:apply-templates/>
  </xsl:template>
-->
  <xsl:template match="text()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="processing-instruction()">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- tags to blissfully ignore their attributes and children. -->

  <xsl:template match="error|headings|picture|anchor|theindex">
  </xsl:template>

  <!-- tags to blissfully ignore their attributes. -->

  <xsl:template match="hi|fbox|minipage">
    <xsl:apply-templates/><xsl:text>
</xsl:text>
  </xsl:template>

  <!-- hi[@rend='bold'] => <emphasis>? or maybe <name> if first child of <p>?  -->
  <xsl:template match="hi[@rend='bold' and
                           not(string-length(normalize-space(text()))=0 and count(child::*)=0)]">
    <emphasis effect='bold'>
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="hi[@rend='it' and
                           not(string-length(normalize-space(text()))=0 and count(child::*)=0)]">
    <emphasis effect='italics'>
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="hi[@rend='slanted' and
                           not(string-length(normalize-space(text()))=0 and count(child::*)=0)]">
    <emphasis effect='italics'>
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="hi[@rend='underline' and
                           not(string-length(normalize-space(text()))=0 and count(child::*)=0)]">
    <emphasis effect='underline'>
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="hi[@rend='sc' and
                           not(string-length(normalize-space(text()))=0 and count(child::*)=0)]">
    <emphasis effect='smallcaps'>
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="hi[@rend='sup']">
    <sup><xsl:apply-templates/></sup>
  </xsl:template>

  <!-- <section> -->

  <xsl:template match="div0|div1|div2|div3">
   <section>
     <xsl:variable name='idbase'>
       <!-- reuse the id if possible since it could be ref-ed elsewhere as a link -->
       <xsl:choose>
         <xsl:when test="@id">
           <xsl:value-of select="@id" />
         </xsl:when>
         <xsl:otherwise>
           <xsl:value-of select="generate-id()"/>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:variable>

     <xsl:attribute name="id" >
       <xsl:value-of select="$idbase" />
     </xsl:attribute>

     <xsl:apply-templates/>

     <xsl:if test="count(child::*[not(self::head) and not(self::biblio)])=0">
       <!-- make sure <section> is not empty and thus invalid. -->
       <para>
         <xsl:attribute name="id" >
           <xsl:value-of select="concat($idbase,'_para')" />
         </xsl:attribute>
       </para>
     </xsl:if>

   </section>
  </xsl:template>

  <xsl:template match="head">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>

  <!-- <para> -->

  <xsl:template match="p">
    <para>
      <xsl:attribute name="id" >
        <xsl:value-of select="generate-id()" />
      </xsl:attribute>
      <xsl:apply-templates/>
    </para>
  </xsl:template>

  <xsl:template match="p[ancestor::p]">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="head/p">
    <!-- <name> and <caption> do not contain <para>s. -->
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="p[count(child::*)=0]
                        [string-length(normalize-space(text())) = 0]">
    <xsl:comment>empty paragraphs get left behind.</xsl:comment>
  </xsl:template>

  <!-- <quote> -->

  <xsl:template match="p[@rend='quoted']
                        [count(text())>0]">
    <para>
      <xsl:variable name='idbase'>
        <!-- reuse the id if possible since it could be ref-ed elsewhere as a link -->
        <xsl:choose>
          <xsl:when test="@id">
            <xsl:value-of select="@id" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:attribute name="id" >
        <xsl:value-of select="$idbase" />
      </xsl:attribute>
      <quote display="block">
        <xsl:attribute name="id" >
          <xsl:value-of select="concat($idbase,'_quote')" />
        </xsl:attribute>
        <xsl:apply-templates/>
      </quote>
    </para>
  </xsl:template>

  <!-- <code> now, <pre> later? -->

  <xsl:template match="hi[@rend='tt'
                          and count(child::*)=0
                          and not(ancestor::figure)
                          and not(ancestor::cnxverbatim)
                          and not(parent::p[count(child::hi)=1
                                            and count(child::*)=1 and
                                            not(normalize-space(text()))
                                           ])
                         ]">
    <code display="inline">
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <xsl:template match="cnxverbatim[child::p/hi[@rend='tt']]">
    <code display="block">
      <xsl:attribute name="id" >
        <xsl:value-of select="generate-id()" />
      </xsl:attribute>
      <xsl:apply-templates select="p/hi[@rend='tt']"/>
    </code>
  </xsl:template>

  <xsl:template match="p[child::hi[@rend='tt']
                         and count(child::hi)=1
                         and count(child::*)=1
                         and not(normalize-space(text()))
                        ]">
    <!-- p that only contains a <h rend='tt'> = . make it a code block -->
    <code display="block">
      <xsl:attribute name="id" >
        <xsl:value-of select="generate-id()" />
      </xsl:attribute>
      <xsl:apply-templates select="hi"/>
    </code>
  </xsl:template>

  <!-- <figure> -->

  <xsl:template match="figure">
    <xsl:variable name='idbase'>
      <!-- reuse the id if possible since it could be ref-ed elsewhere as a link -->
      <xsl:choose>
        <xsl:when test="@id">
          <xsl:value-of select="@id" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <!-- tralics stripped the file type from @file; thus, we have no idea what type of image file this is. -->
      <xsl:when test="@file">
        <xsl:variable name='file'>
          <xsl:value-of select="@file"/>
        </xsl:variable> 
        <figure>
          <xsl:attribute name="id">
            <xsl:value-of select="$idbase"/>
          </xsl:attribute>
          <media alt="">
            <xsl:attribute name="id" >
              <xsl:value-of select="concat($idbase,'_media')" />
            </xsl:attribute>
            <image mime-type='image/png' src='{$file}.png'>
              <xsl:attribute name="id" >
                <xsl:value-of select="concat($idbase,'_onlineimage')" />
              </xsl:attribute>
              <!-- @width - populate this attribute from the actual image dimensions. -->
            </image>
            <image mime-type='application/postscript' for='pdf' src='{$file}.eps'>
              <xsl:attribute name="id" >
                <xsl:value-of select="concat($idbase,'_printimage')" />
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="@scale">
                  <xsl:variable name="scale_factor" select="round(number(@scale)*100)" />
                  <xsl:attribute name="print-width"><xsl:value-of select="@scale" /></xsl:attribute>
                  <xsl:comment>NOTE: attribute width changes image size in printed PDF (if specified in .tex file)</xsl:comment>
                </xsl:when>
                <xsl:when test="@width">
                  <xsl:attribute name="print-width"><xsl:value-of select="@width" /></xsl:attribute>
                  <xsl:comment>NOTE: attribute width changes image size in printed PDF (if specified in .tex file)</xsl:comment>
                </xsl:when>
              </xsl:choose>
            </image>
          </media>
          <xsl:apply-templates/>
        </figure>
      </xsl:when>
      <xsl:when test="count(descendant::figure)>1">
        <!-- subfigures!!! -->
        <figure>
          <xsl:attribute name="id">
            <xsl:value-of select="$idbase"/>
          </xsl:attribute>
          <!-- hack: no idea from the input xml what the orientation.
              chosed 'vertical' over 'horizontal' (which appears to be the default).
              erred on the side of making the document longer versus wider. -->
          <xsl:attribute name="orient">
            <xsl:text>vertical</xsl:text>
          </xsl:attribute>
          <!-- process subfigures here. caption must be last!!! -->
          <xsl:apply-templates select="descendant::figure"/>
          <xsl:apply-templates select="head"/>
        </figure>
      </xsl:when>
      <xsl:when test="count(descendant::subfigure)>1">
        <!-- subfigures!!! -->
        <figure>
          <xsl:attribute name="id">
            <xsl:value-of select="$idbase"/>
          </xsl:attribute>
          <!-- hack: no idea from the input xml what the orientation.
              chosed 'vertical' over 'horizontal' (which appears to be the default).
              erred on the side of making the document longer versus wider. -->
          <xsl:attribute name="orient">
            <xsl:text>vertical</xsl:text>
          </xsl:attribute>
          <!-- process subfigures here. caption must be last!!! -->
          <xsl:apply-templates select="descendant::subfigure"/>
          <xsl:apply-templates select="head"/>
        </figure>
      </xsl:when>
      <xsl:when test="count(p//hi[@rend='tt'])>1">
        <code display="block" class="listing">
          <xsl:attribute name="id">
            <xsl:value-of select="$idbase"/>
          </xsl:attribute>
          <xsl:apply-templates select="p//hi[@rend='tt']"/>
          <xsl:apply-templates select="head"/>
        </code>
      </xsl:when>
      <xsl:when test="count(p/table/row/cell/figure)=1">
        <xsl:variable name='nested_figure' select="p/table/row/cell/figure" />
        <figure>
          <xsl:attribute name="id">
            <xsl:value-of select="$idbase"/>
          </xsl:attribute>
          <xsl:variable name='file'>
            <xsl:value-of select="$nested_figure/@file"/>
          </xsl:variable>
          <media alt="">
            <xsl:attribute name="id" >
              <xsl:value-of select="concat($idbase,'_media')" />
            </xsl:attribute>
            <image mime-type='image/png' src='{$file}.png'>
              <xsl:attribute name="id" >
                <xsl:value-of select="concat($idbase,'_onlineimage')" />
              </xsl:attribute>
            </image>
            <image mime-type='application/postscript' for='pdf' src='{$file}.eps'>
              <xsl:attribute name="id" >
                <xsl:value-of select="concat($idbase,'_printimage')" />
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="$nested_figure/@scale">
                  <xsl:variable name="scale_factor" select="round(number($nested_figure/@scale)*100)" />
                  <xsl:attribute name="print-width"><xsl:value-of select="$nested_figure/@scale" /></xsl:attribute>
                  <xsl:comment>NOTE: attribute width changes image size in printed PDF (if specified in .tex file)</xsl:comment>
                </xsl:when>
                <xsl:when test="$nested_figure/@width">
                  <xsl:attribute name="print-width"><xsl:value-of select="$nested_figure/@width" /></xsl:attribute>
                  <xsl:comment>NOTE: attribute width changes image size in printed PDF (if specified in .tex file)</xsl:comment>
                </xsl:when>
              </xsl:choose>
            </image>
          </media>
          <xsl:apply-templates select="head"/>
        </figure>
      </xsl:when>
      <xsl:otherwise>
        <code display="block">
          <xsl:attribute name="id">
            <xsl:value-of select="$idbase"/>
          </xsl:attribute>
          NOTE: unable to translate the contents of this figure.
          <xsl:apply-templates select="head"/>
        </code>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="subfigure[ancestor::figure]">
    <xsl:variable name='idbase'>
      <!-- reuse the id if possible since it could be ref-ed elsewhere as a link -->
      <xsl:choose>
        <xsl:when test="@id">
          <xsl:value-of select="@id" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name='file'>
      <xsl:value-of select="@file"/>
    </xsl:variable>

    <subfigure>
      <xsl:attribute name="id">
        <xsl:value-of select="$idbase"/>
      </xsl:attribute>
      <media alt="">
        <xsl:attribute name="id" >
          <xsl:value-of select="concat($idbase,'_media')" />
        </xsl:attribute>
        <image mime-type='image/png' src='{$file}.png'>
          <xsl:attribute name="id" >
            <xsl:value-of select="concat($idbase,'_onlinemedia')" />
          </xsl:attribute>
        </image>
        <image mime-type='application/postscript' for='pdf' src='{$file}.eps'>
          <xsl:attribute name="id" >
            <xsl:value-of select="concat($idbase,'_printmedia')" />
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@scale">
              <xsl:attribute name="print-width"><xsl:value-of select="@scale" /></xsl:attribute>
              <xsl:comment>NOTE: attribute width changes image size in printed PDF (if specified in .tex file)</xsl:comment>
            </xsl:when>
            <xsl:when test="@width">
              <xsl:attribute name="print-width"><xsl:value-of select="@width" /></xsl:attribute>
              <xsl:comment>NOTE: attribute width changes image size in printed PDF (if specified in .tex file)</xsl:comment>
            </xsl:when>
          </xsl:choose>
        </image>
      </media>
      <xsl:apply-templates/>
    </subfigure>
  </xsl:template>

  <xsl:template match="figure[ancestor::figure]">
    <xsl:variable name='idbase'>
      <!-- reuse the id if possible since it could be ref-ed elsewhere as a link -->
      <xsl:choose>
        <xsl:when test="@id">
          <xsl:value-of select="@id" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name='file'>
      <xsl:value-of select="@file"/>
    </xsl:variable>

    <subfigure>
      <xsl:attribute name="id">
        <xsl:value-of select="$idbase"/>
      </xsl:attribute>
      <media alt="">
        <xsl:attribute name="id" >
          <xsl:value-of select="concat($idbase,'_media')" />
        </xsl:attribute>
        <image mime-type='image/png' src='{$file}.png'>
          <xsl:attribute name="id" >
            <xsl:value-of select="concat($idbase,'_onlineimage')" />
          </xsl:attribute>
        </image>
        <image mime-type='application/postscript' for='pdf' src='{$file}.eps'>
          <xsl:attribute name="id" >
            <xsl:value-of select="concat($idbase,'_printimage')" />
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@scale">
              <xsl:attribute name="print-width"><xsl:value-of select="@scale" /></xsl:attribute>
              <xsl:comment>NOTE: attribute width changes image size in printed PDF (if specified in .tex file)</xsl:comment>
            </xsl:when>
            <xsl:when test="@width">
              <xsl:attribute name="print-width"><xsl:value-of select="@width" /></xsl:attribute>
              <xsl:comment>NOTE: attribute width changes image size in printed PDF (if specified in .tex file)</xsl:comment>
            </xsl:when>
          </xsl:choose>
        </image>
      </media>
      <xsl:apply-templates/>
    </subfigure>
  </xsl:template>

  <xsl:template match="figure/head">
    <xsl:if test="string-length(normalize-space(.)) > 0 or count(child::*) > 0">
      <caption>
        <xsl:apply-templates/>
      </caption>
    </xsl:if>
  </xsl:template>

  <xsl:template match="subfigure/head">
    <xsl:if test="string-length(normalize-space(.)) > 0 or count(child::*) > 0">
      <caption>
        <xsl:apply-templates/>
      </caption>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ref">
    <link>
      <xsl:attribute name="target-id">
        <xsl:value-of select="@target"/>
      </xsl:attribute>

      <!-- hat tip to chuck. -->
      <xsl:variable name="div" select="key('div_by_id',@target)" />
      <!-- div has 0 or 1 elements -->
      <xsl:if test="string-length(normalize-space($div/head))">
        <xsl:text>"</xsl:text><xsl:value-of select="$div/head" /><xsl:text>"</xsl:text>
      </xsl:if>
    </link>
  </xsl:template>

  <xsl:template match="cit|Cit[count(child::ref)=1]">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="Cit[count(child::ref)>1]">
    (<xsl:apply-templates/>)
  </xsl:template>

  <xsl:template match="xref">
    <link>
      <xsl:attribute name="url">
        <xsl:value-of select="@url"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </link>
  </xsl:template>

  <xsl:template match="xref" mode="biblio">
    <xsl:value-of select="@url"/>
  </xsl:template>

  <!-- <list> -->

  <xsl:template match="list">
    <list display="block">
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>

      <xsl:choose>
        <xsl:when test="@type='simple'">
          <xsl:attribute name="list-type">
            <xsl:text>bulleted</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@type='ordered'">
          <xsl:attribute name="list-type">
            <xsl:text>enumerated</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@type='description'">
          <xsl:attribute name="list-type">
            <xsl:text>labeled-item</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="list-type">
            <xsl:text>bulleted</xsl:text>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select='child::*[not(self::label)]'/>

    </list>
  </xsl:template>

  <xsl:template match="item">
    <item>
      <xsl:variable name='idbase'>
        <!-- reuse the id if possible since it could be ref-ed elsewhere as a link -->
        <xsl:choose>
          <xsl:when test="@id">
            <xsl:value-of select="@id" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:attribute name="id" >
        <xsl:value-of select="$idbase" />
      </xsl:attribute>

      <xsl:if test='preceding-sibling::*[1][self::label]'>
        <label>
          <xsl:apply-templates select='preceding-sibling::label[1]'/>
        </label>
      </xsl:if>

      <xsl:apply-templates/>
    </item>
  </xsl:template>

  <xsl:template match="list/item/p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="item[not(parent::list)]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- <table> -->

  <xsl:template match="table">
    <xsl:variable name='idbase'>
      <!-- reuse the id if possible since it could be ref-ed elsewhere as a link -->
      <xsl:choose>
        <xsl:when test="@id">
          <xsl:value-of select="@id" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <table summary="">
      <xsl:attribute name="id" >
        <xsl:value-of select="$idbase" />
      </xsl:attribute>
      <xsl:variable name="cols">
        <xsl:call-template name="count.columns" />
      </xsl:variable>

      <tgroup>
        <xsl:attribute name='cols'>
          <!-- asumming every row has the same number of columns -->
          <xsl:value-of select="$cols" />
        </xsl:attribute>

        <xsl:if test="count(row/cell[@cols])>0">
          <xsl:call-template name="colspec.maker">
            <xsl:with-param name="numcols" select="$cols"/>
          </xsl:call-template>
        </xsl:if>

        <tbody>
          <xsl:if test="child::*[not(self::head)]">
            <xsl:apply-templates select="child::*[not(self::head)]"/>
          </xsl:if>
        </tbody>
      </tgroup>

      <xsl:if test="head">
        <xsl:apply-templates select="head"/>
      </xsl:if>

    </table>
  </xsl:template>

  <xsl:template match="row">
    <row>
      <!-- <xsl:apply-templates/> -->
      <xsl:call-template name="output.cells" />
    </row>
  </xsl:template>

  <xsl:template match="cell">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="table/head">
    <caption>
      <xsl:apply-templates/>
    </caption>
  </xsl:template>

  <xsl:template name="output.cells">
    <xsl:param name="iteration" select="1" />
    <xsl:param name="curcol" select="1" />
    <xsl:choose>
      <xsl:when test="not(cell[$iteration])">
        <!-- this is where the recursion ends. -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="cell" select="cell[$iteration]"/>

        <xsl:variable name="lastcol">
          <xsl:choose>
            <xsl:when test="$cell[@cols]"><xsl:value-of select="$curcol + $cell/@cols - 1" /></xsl:when>
            <xsl:otherwise>               <xsl:value-of select="$curcol" />                  </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <entry>
          <xsl:if test="$curcol != $lastcol">
            <!-- <entry namest="c1" nameend="c3"> -->
            <xsl:attribute name="namest">
              <xsl:text>c</xsl:text><xsl:value-of select="$curcol" />
            </xsl:attribute>
            <xsl:attribute name="nameend">
              <xsl:text>c</xsl:text><xsl:value-of select="$lastcol" />
            </xsl:attribute>
          </xsl:if>

          <xsl:apply-templates select="$cell"/>
        </entry>

        <xsl:call-template name="output.cells">
          <xsl:with-param name="iteration" select="$iteration + 1" />
          <xsl:with-param name="curcol"    select="$lastcol + 1" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="count.columns">
    <xsl:param name="iteration" select="1" />
    <xsl:param name="numcols" select="0" />
    <xsl:param name="location" select="." />
    <xsl:choose>
      <xsl:when test="not($location/row[1]/cell[$iteration])">
        <!-- this is where the recursion ends. no more cells to count. -->
        <!-- the following statement returns a value all the back to the first caller.  -->
        <xsl:value-of select="$numcols" />
      </xsl:when>
      <xsl:otherwise>
        <!-- $location/row[1]/cell[$iteration] exists. -->
        <xsl:variable name="cell" select="$location/row[1]/cell[$iteration]"/>
        <xsl:choose>
          <xsl:when test="$cell[@cols]">
            <xsl:call-template name="count.columns">
              <xsl:with-param name="numcols"   select="$numcols + $cell/@cols" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
              <xsl:with-param name="location"  select="$location" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="count.columns">
              <xsl:with-param name="numcols"   select="$numcols + 1" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
              <xsl:with-param name="location"  select="$location" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="colspec.maker">
    <xsl:param name="iteration" select="1" />
    <xsl:param name="numcols" select="0" />
    <xsl:choose>
      <xsl:when test="$iteration &gt; $numcols" />
      <xsl:otherwise>
        <xsl:element name="colspec">
          <xsl:attribute name="colnum">
            <xsl:value-of select="$iteration" />
          </xsl:attribute>
          <xsl:attribute name="colname">
            <xsl:text>c</xsl:text>
            <xsl:value-of select="$iteration" />
          </xsl:attribute>
        </xsl:element>
        <xsl:call-template name="colspec.maker">
          <xsl:with-param name="iteration" select="$iteration + 1" />
          <xsl:with-param name="numcols" select="$numcols" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="table[descendant::table]">
    <!-- tables are being used for presentation?  -->
    <xsl:comment>Table that contain tables are not converted.</xsl:comment>
  </xsl:template>

  <!-- Bibliography -->

  <!-- from \begin{thebibliography} which we purposedly do not support -->
  <xsl:template match="Bibliography">
  </xsl:template>

  <!-- use mode="biblio" as the gate keeper for the <biblio> node,
       which we only enter at the end of the document and not where tralics placed it. -->
  <xsl:template match="biblio">
  </xsl:template>

  <xsl:template match="biblio" mode="biblio">
    <bib:file>
      <xsl:apply-templates mode="biblio"/>
    </bib:file>
  </xsl:template>

  <xsl:template match="citation[@type='article']" mode="biblio">
  <!-- Required fields: author, title, journal, year
       Optional fields: volume, number, pages, month, note, key -->
    <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:article>
        <xsl:comment>required fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode='biblio'/>
        </bib:title>
        <bib:journal>
          <xsl:apply-templates select='bjournal' mode="biblio"/>
        </bib:journal>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:volume>
          <xsl:apply-templates select='bvolume' mode="biblio"/>
        </bib:volume>
        <bib:number>
          <xsl:apply-templates select='bnumber' mode="biblio"/>
        </bib:number>
        <bib:pages>
          <xsl:apply-templates select='bpages' mode="biblio"/>
        </bib:pages>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:article>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='book']" mode="biblio">
  <!-- Required fields: author or editor, title, publisher, year
       Optional fields: volume, series, address, edition, month, note, key -->
    <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:book>
        <xsl:comment>required fields</xsl:comment>
        <xsl:choose>
          <xsl:when test='bauteurs'>
            <bib:author>
              <xsl:apply-templates select='bauteurs' mode="biblio"/>
            </bib:author>
          </xsl:when>
          <xsl:otherwise>
            <bib:editor>
              <xsl:apply-templates select='bediteur' mode="biblio"/>
            </bib:editor>
          </xsl:otherwise>
        </xsl:choose>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:publisher>
          <xsl:apply-templates select='bpublisher' mode="biblio"/>
        </bib:publisher>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:volume>
          <xsl:apply-templates select='bvolume' mode="biblio"/>
        </bib:volume>
        <bib:series>
          <xsl:apply-templates select='bseries' mode="biblio"/>
        </bib:series>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:edition>
          <xsl:apply-templates select='bedition' mode="biblio"/>
        </bib:edition>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:book>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='booklet']" mode="biblio">
  <!-- Required fields: title
       Optional fields: author, howpublished, address, month, year, note, key -->
    <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:booklet>
        <xsl:comment>optional field</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <xsl:comment>required fields</xsl:comment>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <xsl:comment>optional fields</xsl:comment>
        <bib:howpublished>
          <xsl:apply-templates select='bhowpublished' mode="biblio"/>
        </bib:howpublished>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:booklet>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='conference']" mode="biblio">
  <!-- Required fields: author, title, booktitle, year
       Optional fields: editor, volume or number, series, pages,
                        address, month, organization, publisher, note.  -->
    <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:conference>
        <xsl:comment>required fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:booktitle>
          <xsl:apply-templates select='bbooktitle' mode="biblio"/>
        </bib:booktitle>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:editor>
          <xsl:apply-templates select='bediteur' mode="biblio"/>
        </bib:editor>
        <xsl:choose>
          <xsl:when test='bvolume'>
            <bib:volume>
              <xsl:apply-templates select='bvolume' mode="biblio"/>
            </bib:volume>
          </xsl:when>
          <xsl:otherwise>
            <bib:number>
              <xsl:apply-templates select='bnumber' mode="biblio"/>
            </bib:number>
          </xsl:otherwise>
        </xsl:choose>
        <bib:series>
          <xsl:apply-templates select='bseries' mode="biblio"/>
        </bib:series>
        <bib:pages>
          <xsl:apply-templates select='bpages' mode="biblio"/>
        </bib:pages>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:organization>
          <xsl:apply-templates select='borganization' mode="biblio"/>
        </bib:organization>
        <bib:publisher>
          <xsl:apply-templates select='bpublisher' mode="biblio"/>
        </bib:publisher>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:conference>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='inbook']" mode="biblio">
  <!-- Required fields: author or editor, title, chapter and/or pages, publisher, year
       Optional fields: volume, series, address, edition, month, note, key -->
    <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:inbook>
        <xsl:comment>required fields</xsl:comment>
        <xsl:choose>
          <xsl:when test='bauteurs'>
            <bib:author>
              <xsl:apply-templates select='bauteurs' mode="biblio"/>
            </bib:author>
          </xsl:when>
          <xsl:otherwise>
            <bib:editor>
              <xsl:apply-templates select='bediteur' mode="biblio"/>
            </bib:editor>
          </xsl:otherwise>
        </xsl:choose>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:chapter>
          <xsl:apply-templates select='bchapter' mode="biblio"/>
        </bib:chapter>
        <bib:pages>
          <xsl:apply-templates select='bpages' mode="biblio"/>
        </bib:pages>
        <bib:publisher>
          <xsl:apply-templates select='bpublisher' mode="biblio"/>
        </bib:publisher>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:volume>
          <xsl:apply-templates select='bvolume' mode="biblio"/>
        </bib:volume>
        <bib:series>
          <xsl:apply-templates select='bseries' mode="biblio"/>
        </bib:series>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:edition>
          <xsl:apply-templates select='bedition' mode="biblio"/>
        </bib:edition>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:inbook>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='incollection']" mode="biblio">
  <!-- Required fields: author, title, booktitle, publisher, year.
       Optional fields: editor, volume or number, series, type,
                        chapter, pages, address, edition, month, note. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:incollection>
       <xsl:comment>required fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:booktitle>
          <xsl:apply-templates select='bbooktitle' mode="biblio"/>
        </bib:booktitle>
        <bib:publisher>
          <xsl:apply-templates select='bpublisher' mode="biblio"/>
        </bib:publisher>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:editor>
          <xsl:apply-templates select='bediteur' mode="biblio"/>
        </bib:editor>
        <xsl:choose>
          <xsl:when test='bvolume'>
            <bib:volume>
              <xsl:apply-templates select='bvolume' mode="biblio"/>
            </bib:volume>
          </xsl:when>
          <xsl:otherwise>
            <bib:number>
              <xsl:apply-templates select='bnumber' mode="biblio"/>
            </bib:number>
          </xsl:otherwise>
        </xsl:choose>
        <bib:series>
          <xsl:apply-templates select='bseries' mode="biblio"/>
        </bib:series>
        <bib:type>
          <xsl:apply-templates select='btype' mode="biblio"/>
        </bib:type>
        <bib:chapter>
          <xsl:apply-templates select='bchapter' mode="biblio"/>
        </bib:chapter>
        <bib:pages>
          <xsl:apply-templates select='bpages' mode="biblio"/>
        </bib:pages>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:edition>
          <xsl:apply-templates select='bedition' mode="biblio"/>
        </bib:edition>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:incollection>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='inproceedings']" mode="biblio">
  <!--  Required fields: author, title, booktitle, year.
        Optional fields: editor, volume or number, series, pages,
                         address, month, organization, publisher, note. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:inproceedings>
       <xsl:comment>required fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:booktitle>
          <xsl:apply-templates select='bbooktitle' mode="biblio"/>
        </bib:booktitle>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:editor>
          <xsl:apply-templates select='bediteur' mode="biblio"/>
        </bib:editor>
        <xsl:choose>
          <xsl:when test='bvolume'>
            <bib:volume>
              <xsl:apply-templates select='bvolume' mode="biblio"/>
            </bib:volume>
          </xsl:when>
          <xsl:otherwise>
            <bib:number>
              <xsl:apply-templates select='bnumber' mode="biblio"/>
            </bib:number>
          </xsl:otherwise>
        </xsl:choose>
        <bib:series>
          <xsl:apply-templates select='bseries' mode="biblio"/>
        </bib:series>
        <bib:pages>
          <xsl:apply-templates select='bpages' mode="biblio"/>
        </bib:pages>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:organization>
          <xsl:apply-templates select='borganization' mode="biblio"/>
        </bib:organization>
        <bib:publisher>
          <xsl:apply-templates select='bpublisher' mode="biblio"/>
        </bib:publisher>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:inproceedings>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='manual']" mode="biblio">
  <!-- Required field: title.
       Optional fields: author, organization, address,
                       edition, month, year, note. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:manual>
        <xsl:comment>optional field</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
       <xsl:comment>required fields</xsl:comment>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <xsl:comment>optional fields</xsl:comment>
        <bib:organization>
          <xsl:apply-templates select='borganization' mode="biblio"/>
        </bib:organization>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:edition>
          <xsl:apply-templates select='bedition' mode="biblio"/>
        </bib:edition>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:manual>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='mastersthesis']" mode="biblio">
  <!-- Required fields: author, title, school, year.
       Optional fields: type, address, month, note. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:mastersthesis>
        <xsl:comment>required fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:school>
          <xsl:apply-templates select='bschool' mode="biblio"/>
        </bib:school>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:type>
          <xsl:apply-templates select='btype' mode="biblio"/>
        </bib:type>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:mastersthesis>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='misc']" mode="biblio">
  <!-- Required fields: none.
       Optional fields: author, title, howpublished, month, year, note. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:misc>
        <xsl:comment>required fields</xsl:comment>
        <xsl:comment>optional fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:howpublished>
          <xsl:apply-templates select='bhowpublished' mode="biblio"/>
        </bib:howpublished>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:misc>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='phdthesis']" mode="biblio">
  <!-- Required fields: author, title, school, year.
       Optional fields: type, address, month, note. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:phdthesis>
        <xsl:comment>required fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:school>
          <xsl:apply-templates select='bschool' mode="biblio"/>
        </bib:school>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:type>
          <xsl:apply-templates select='btype' mode="biblio"/>
        </bib:type>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:phdthesis>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='proceedings']" mode="biblio">
  <!-- Required fields: title, year.
       Optional fields: editor, volume or number, series,
                        address, month, organization, publisher, note. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:proceedings>
        <xsl:comment>optional field</xsl:comment>
        <bib:editor>
          <xsl:apply-templates select='bediteur' mode="biblio"/>
        </bib:editor>
        <xsl:comment>required fields</xsl:comment>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <xsl:choose>
          <xsl:when test='bvolume'>
            <bib:volume>
              <xsl:apply-templates select='bvolume' mode="biblio"/>
            </bib:volume>
          </xsl:when>
          <xsl:otherwise>
            <bib:number>
              <xsl:apply-templates select='bnumber' mode="biblio"/>
            </bib:number>
          </xsl:otherwise>
        </xsl:choose>
        <bib:series>
          <xsl:apply-templates select='bseries' mode="biblio"/>
        </bib:series>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:organization>
          <xsl:apply-templates select='borganization' mode="biblio"/>
        </bib:organization>
        <bib:publisher>
          <xsl:apply-templates select='bpublisher' mode="biblio"/>
        </bib:publisher>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:proceedings>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='techreport']" mode="biblio">
  <!-- Required fields: author, title, institution, year.
       Optional fields: type, number, address, month, note. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:techreport>
        <xsl:comment>required fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:institution>
          <xsl:apply-templates select='binstitution' mode="biblio"/>
        </bib:institution>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
        <xsl:comment>optional fields</xsl:comment>
        <bib:type>
          <xsl:apply-templates select='btype' mode="biblio"/>
        </bib:type>
        <bib:number>
          <xsl:apply-templates select='bnumber' mode="biblio"/>
        </bib:number>
        <bib:address>
          <xsl:apply-templates select='baddress' mode="biblio"/>
        </bib:address>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
      </bib:techreport>
    </bib:entry>
  </xsl:template>

  <xsl:template match="citation[@type='unpublished']" mode="biblio">
  <!-- Required fields: author, title, note.
       Optional fields: month, year. -->
     <bib:entry>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <bib:unpublished>
        <xsl:comment>required fields</xsl:comment>
        <bib:author>
          <xsl:apply-templates select='bauteurs' mode="biblio"/>
        </bib:author>
        <bib:title>
          <xsl:apply-templates select='btitle' mode="biblio"/>
        </bib:title>
        <bib:note>
          <xsl:apply-templates select='bnote' mode="biblio"/>
        </bib:note>
        <xsl:comment>optional fields</xsl:comment>
        <bib:month>
          <xsl:apply-templates select='bmonth' mode="biblio"/>
        </bib:month>
        <bib:year>
          <xsl:apply-templates select='byear' mode="biblio"/>
        </bib:year>
      </bib:unpublished>
    </bib:entry>
  </xsl:template>

<!-- <bauteurs><bpers prenom='J.-M.' nom='Adrien' prenomcomplet='Jean-Marie'/></bauteurs> -->

  <xsl:template name="create.people.list" mode="biblio">
    <xsl:param name="iteration" select="1" />
    <xsl:if test='bpers[$iteration]'>
      <xsl:variable name="person" select="bpers[$iteration]"/>
      <xsl:if test='$iteration &gt; 1'>
        <xsl:text> and </xsl:text>
      </xsl:if>
      <xsl:value-of select="$person/@nom" /><xsl:text>, </xsl:text><xsl:value-of select="$person/@prenomcomplet" />
      <xsl:call-template name="create.people.list">
        <xsl:with-param name="iteration" select="$iteration + 1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="bauteurs" mode="biblio">
      <!-- one or more <bpers> children -->
      <xsl:call-template name="create.people.list" mode="biblio"/>
  </xsl:template>

  <xsl:template match="bediteur">
      <!-- one or more <bpers> children -->
      <xsl:call-template name="create.people.list" mode="biblio"/>
  </xsl:template>

  <!-- thwart those who use URLs in their bib entries -->
  <xsl:template match="bpublisher|baddress|bnote" mode="biblio">
    <xsl:apply-templates mode="biblio"/>
  </xsl:template>

  <!-- footnotes  -->

  <xsl:template match="note[@place='foot']">
    <footnote>
      <xsl:attribute name="id" >
       <xsl:choose>
         <xsl:when test="@id">
           <xsl:value-of select="@id" />
         </xsl:when>
         <xsl:otherwise>
           <xsl:value-of select="generate-id()" />
         </xsl:otherwise>
       </xsl:choose>
     </xsl:attribute>

      <xsl:apply-templates/>
    </footnote>
  </xsl:template>

  <!-- random stuff -->

  <xsl:template match="leaders/rule[@depth='-2.5pt'][@height='3.0pt']"> <!-- match='hfill' instead? -->
    <xsl:text>&#65293;</xsl:text> <!-- U+FF0D FULLWIDTH HYPHEN-MINUS -->
  </xsl:template>

  <xsl:template match="std">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Here the math doth commence ... -->

  <xsl:template match="formula">
    <xsl:choose>
      <xsl:when test="@type='display'">
        <!-- math in a equation -->
        <equation>
          <xsl:attribute name="id" >
            <xsl:choose>
              <xsl:when test="@id">
                <xsl:value-of select="@id" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="generate-id()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates/>
        </equation>
      </xsl:when>
      <xsl:otherwise>
        <!-- inlined math -->
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- m04minterms-template.tex : <p noindent='true'>   <formula type='inline'><math> -->
  <!--- WTF: removed p[count(*)=1] since it matched everything for some reason
  <xsl:template match="p[count(*)=1]
                        [formula[m:math]
                                [string-length(normalize-space(preceding-sibling::text())) = 0]
                                [string-length(normalize-space(following-sibling::text())) = 0]
                        ]"> -->
  <xsl:template
    match="p[count(*)=1]
            [formula[@type != 'inline']
                    [string-length(normalize-space(preceding-sibling::text())) = 0]
                    [string-length(normalize-space(following-sibling::text())) = 0]/*[local-name() = 'math' and namespace-uri() = 'http://www.w3.org/1998/Math/MathML']
            ]">
    <!-- <xsl:comment>an equation candidate</xsl:comment> -->
    <equation>
      <xsl:attribute name="id" >
        <xsl:choose>
          <xsl:when test="@id">
            <xsl:value-of select="@id" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <xsl:apply-templates select="formula"/>
    </equation>
  </xsl:template>

  <xsl:template match="biblio/citation/*/formula">
    <xsl:comment>Math is not currently allowed within BibTeXML.</xsl:comment>
  </xsl:template>

  <!-- MathML -->

  <xsl:template match="m:math">
    <m:math overflow="scroll"> <!-- BNW: HACK!!!!!! -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </m:math>
  </xsl:template>

  <xsl:template match="m:*">
    <xsl:variable name="myName" select="concat('m:', local-name())"/>
    <xsl:element name="{concat('m:', local-name())}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="m:*/@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="m:*/text()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="m:mref">
    <!-- tralics made this up so we ignore.  no way to <cite> in MathML. -->
  </xsl:template>

  <!-- but not in the bib -->
  <xsl:template match="formula" mode="biblio">
    <xsl:comment>no math allowed in bib entries</xsl:comment>
  </xsl:template>

  <!-- there is no 'script' effect -->
  <xsl:template match="formula[@type='inline' and
                               string-length(normalize-space(text()))=0 and
                               count(child::*)=1 and
                               m:math[string-length(normalize-space(text()))=0 and
                                      count(child::*)=1 and
                                      (m:mi|m:mn)[@mathvariant='script']
                                      ]
                              ]">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>

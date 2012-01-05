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
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  office:class="text" office:version="1.0"
  exclude-result-prefixes="office style text table draw fo xlink number svg chart dr3d math form script"
  >

  <xsl:output omit-xml-declaration="no" indent="yes" method="xml" />

  <!-- augmented input xml with /office:document-content/office:styles in oo2oo.xsl  -->
  <xsl:variable name="bold"/>
  <xsl:key name="list-automatic-styles"
       match="/office:document-content/office:automatic-styles/text:list-style"
       use="@style:name"/>

  <xsl:key name="list-styles"
       match="/office:document-content/office:styles/text:list-style"
       use="@style:name"/>

  <xsl:key name="bookmark" match="/descendant::text:bookmark" use="@text:name"/>

  <xsl:key name="bookmark-start" match="/descendant::text:bookmark-start" use="@text:name"/>

  <xsl:template match="/">

    <document xmlns="http://cnx.rice.edu/cnxml" xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/" xmlns:q="http://cnx.rice.edu/qml/1.0" module-id="m12345" cnxml-version="0.7">
      <xsl:attribute name="id">
        <xsl:value-of select ="generate-id()" />
      </xsl:attribute> 

      <title>
        <xsl:choose>
          <xsl:when test="//office:document-content/office:body//text:p[@text:style-name='Title']">
            <xsl:value-of select="//office:document-content/office:body//text:p[@text:style-name='Title']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Untitled Document</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </title>

      <content>
        <xsl:choose>
          <xsl:when test='not(normalize-space(.))'>
            <!-- text free document.  only do something if there are images. -->
            <xsl:choose>
              <xsl:when test="descendant::draw:image">
                <xsl:apply-templates />
              </xsl:when> 
              <xsl:otherwise >
                <xsl:comment>empty document?</xsl:comment>
                <para>
                  <xsl:attribute name='id'>empty-para</xsl:attribute>
                </para>
               </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="text:p[@text:style-name='CNXML Glossary Section']">
            <!-- we have a document with a glossary. process all nodes prior to the first glossary node. -->
            <xsl:apply-templates select="." mode="GlossarySec"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates />
          </xsl:otherwise>
        </xsl:choose>
      </content>
        <xsl:if test="//text:p/@text:style-name='CNXML Glossary Section'">
          <glossary>
            <xsl:if test="//text:p[@text:style-name='CNXML Glossary Section']/text:bookmark or //text:p[@text:style-name='CNXML Glossary Section']/text:bookmark-start">
              <xsl:attribute name="id">
                <xsl:value-of select="generate-id(//text:p[@text:style-name='CNXML Glossary Section'])"/>
              </xsl:attribute>
            </xsl:if>
            <!-- only to process the sibling nodes that follow he glossary that are definitions. -->
            <xsl:apply-templates select="//text:p[@text:style-name='CNXML Glossary Section'][1]/following-sibling::*[@text:style-name='CNXML Definition (Term)' or @text:style-name='CNXML Definition (Meaning)']"/>
          </glossary>
        </xsl:if>
    </document>
  </xsl:template>

  <xsl:template match="*" mode="GlossarySec">
    <xsl:for-each select="preceding-sibling::*[not(self::name)]">
      <xsl:apply-templates select="." />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="text:section">
    <section>
      <xsl:attribute name="id" >
        <xsl:value-of select="generate-id()" />
      </xsl:attribute> 

      <xsl:if test="child::text:h[position()=1]">
        <title>
          <xsl:value-of select="child::text:h"/>
        </title>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="count(child::*[not(self::text:h[position()=1])])>0">
          <xsl:apply-templates />
        </xsl:when>
        <xsl:otherwise>
          <para>
            <xsl:attribute name="id" >
              <xsl:value-of select="concat('para-', generate-id())" />
            </xsl:attribute>
            <xsl:comment><xsl:value-of select="count(child::*[not(self::text:h[position()=1])])"/> Empty sections are illegal in CNXML 0.5.  This empty paragraph is a place holder that was added as a byproduct of the word importer.</xsl:comment>
          </para>
        </xsl:otherwise>
      </xsl:choose>
    </section>
  </xsl:template>

  <xsl:template match="text:section[not(normalize-space(.)) and not(descendant::draw:image)]">
    <!-- ignore white space sections that do not have images -->
  </xsl:template>

  <xsl:template match="section[name[m:math]]">
    <para>
        <xsl:attribute name="id" >
        <xsl:value-of select="generate-id()" />
        </xsl:attribute>

        <xsl:if test="*[not(self::name)]">
          <xsl:apply-templates />
        </xsl:if>
    </para>
  </xsl:template>

  <xsl:template match="section">
      <section>
        <xsl:attribute name="id" >
          <xsl:value-of select="generate-id()" />
        </xsl:attribute>
        <xsl:if test="name">
          <title>
            <xsl:value-of select="name"/>
          </title>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="count(child::*[not(self::name)])>0">
            <xsl:choose>
              <xsl:when test="text:p[@text:style-name='CNXML Glossary Section'][1]">
                <xsl:apply-templates select="text:p[@text:style-name='CNXML Glossary Section'][1]" mode="GlossarySec"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="*[not(self::name)]"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <para>
              <xsl:attribute name="id" >
                <xsl:value-of select="concat('para-',generate-id())" />
              </xsl:attribute>
              <xsl:comment>Empty sections are illegal in CNXML 0.5.  This empty paragraph is a place holder that was added as a byproduct of the word importer.</xsl:comment>
            </para>
          </xsl:otherwise>
        </xsl:choose>
      </section>
  </xsl:template>


  <!-- Para, Quote(block) -->
  <xsl:template match="text:p">
    <xsl:variable name="Para-Style">
      <xsl:value-of select="@text:style-name"/>
    </xsl:variable>
    <xsl:if test="count(node())=0">
        <xsl:if test="preceding-sibling::*[1]/text:span/@text:style-name='CNXML Code (Block)' and following-sibling::*[1]/text:span/@text:style-name='CNXML Code (Block)'">
          <para>
            <xsl:attribute name="id" >
              <xsl:value-of select="generate-id(.)" />
            </xsl:attribute>
            <xsl:text>
            </xsl:text>
          </para>
        </xsl:if>
    </xsl:if>
    <xsl:if test="count(text()|child::*[not(self::text:s)])">
      <xsl:choose>
        <xsl:when test="@text:level='1'">
          <para>
            <xsl:attribute name="id" >
              <xsl:value-of select="generate-id()" />
            </xsl:attribute>
            <title>
              <xsl:value-of select="."/>
            </title>
          </para>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Example'">
          <xsl:choose>
            <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
              <xsl:apply-templates />
            </xsl:when>
            <xsl:when test="preceding-sibling::*[1]/@text:style-name='CNXML Example' and not(descendant::draw:image)">
            </xsl:when>
            <xsl:otherwise>
              <example>
                <xsl:apply-templates select="." mode="exHelper" />
              </example>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Equation'">
          <equation>
            <xsl:attribute name="id" >
              <xsl:value-of select="generate-id()" />
            </xsl:attribute>
            <xsl:apply-templates/>
          </equation>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Definition (Term)'">
          <xsl:if test="following-sibling::text:p[position()=1]/@text:style-name='CNXML Definition (Meaning)'">
          <!-- definition must have both a term and meaning child. -->
            <definition>
              <xsl:attribute name="id" >
                <xsl:value-of select="generate-id()" />
              </xsl:attribute>
              <term>
                <xsl:apply-templates/>
              </term>
              <meaning>
                <xsl:if test="following-sibling::*[1]/text:bookmark or following-sibling::*[1]/text:bookmark-start">
                  <xsl:attribute name="id">
                    <xsl:value-of select="generate-id(following-sibling::*[1])"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="following-sibling::*[1]" mode="meaningHelper" />
              </meaning>
            </definition>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Definition (Meaning)'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Theorem (Statement)'">
          <xsl:if test="not(following-sibling::*[1]/@text:style-name='CNXML Theorem (Statement)')" >
            <xsl:variable name="ruleid" select="."/>
            <rule type="theorem">
              <xsl:attribute name="id" >
                <xsl:value-of select="concat('rule',generate-id(.))" />
              </xsl:attribute>
              <statement>
                <xsl:apply-templates select="." mode="statementHelper"/>
              </statement>
              <xsl:if test="following-sibling::text:p[position()=1]/@text:style-name='CNXML Theorem (Proof)'">
              <proof>
                <xsl:apply-templates select="following-sibling::*[1]" mode="proofHelper"/>
              </proof>
              </xsl:if>
            </rule>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Theorem (Proof)'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Exercise (Problem)'">
          <exercise>
            <xsl:attribute name="id" >
              <xsl:value-of select="generate-id()" />
            </xsl:attribute>
            <problem>
                <para>
                <xsl:attribute name="id">
                  <xsl:value-of select="generate-id(node())"/>
                </xsl:attribute>
                <xsl:apply-templates/>
                </para>
            </problem>
            <xsl:if test="following-sibling::text:p[position()=1]/@text:style-name='CNXML Exercise (Solution)'">
              <solution>
                <xsl:apply-templates select="following-sibling::*[1]" mode="solHelper"/>
              </solution>
            </xsl:if>
          </exercise>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Quote' or $Para-Style='CNXML Quote (Block)'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
              </xsl:when>
              <xsl:when test="not(descendant::draw:image) and (preceding-sibling::*[1]/@text:style-name='CNXML Quote (Block)' or preceding-sibling::*[1]/@text:style-name='CNXML Quote')">
              </xsl:when>
              <xsl:otherwise>
              <para>
                <xsl:attribute name="id" >
                  <xsl:value-of select="generate-id()" />
                </xsl:attribute>
                <xsl:apply-templates select="." mode="quoteBlockHelper"/>
              </para>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Code (Block)'">
          <xsl:if test="preceding-sibling::*[1]/@text:style-name='CNXML Code (Block)'">
          </xsl:if>
          <xsl:if test="not(preceding-sibling::*[1]/@text:style-name='CNXML Code (Block)')">
            <code display="block">
              <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
              </xsl:attribute>
              <xsl:apply-templates select="." mode="codeHelper"/>
            </code>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Exercise (Solution)'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Figure Title'">
        </xsl:when>
        <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Para-Style]/@style:parent-style-name='CNXML Figure Title'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Figure Caption'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML Glossary Section'">
        </xsl:when>
        <xsl:when test="count(child::*)=1 and text:span/@text:style-name='CNXML Note'">
          <note type="Note">
            <xsl:attribute name='id'>
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:value-of select="text:span"/>
          </note>
        </xsl:when>
        <xsl:when test="count(child::*)=2 and text:bookmark-start and text:bookmark-end and not(normalize-space())">
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="parent::text:footnote-body or parent::text:endnote-body or parent::text:list-item or parent::table:table-cell or (count(child::*)=1 and not(child::text()) and child::draw:image)">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
              <para>
                <xsl:attribute name="id">
                  <xsl:value-of select="generate-id()"/>
                </xsl:attribute>
                <xsl:apply-templates />
              </para>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="quoteBlockHelper">
    <xsl:choose>
      <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
        <xsl:apply-templates />
      </xsl:when>
      <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
      </xsl:when>
      <xsl:otherwise>
        <quote display="block">
          <xsl:attribute name="id">
            <xsl:value-of select="concat(generate-id(),'_quote')"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </quote>
        <xsl:if test="following-sibling::*[1]/@text:style-name='CNXML Quote (Block)' or following-sibling::*[1]/@text:style-name='CNXML Quote'">
          <xsl:apply-templates select="following-sibling::*[1]" mode="quoteBlockHelper" />
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="*" mode="meaningHelper">
      <xsl:apply-templates/>
      <xsl:text>
      </xsl:text>
    <xsl:if test="following-sibling::text:p[1]/@text:style-name='CNXML Definition (Meaning)'">
      <xsl:apply-templates select="following-sibling::text:p[1]" mode="meaningHelper"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="*" mode="proofHelper">
    <para>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </para>
    <xsl:if test="following-sibling::text:p[1]/@text:style-name='CNXML Theorem (Proof)'">
      <xsl:apply-templates select="following-sibling::text:p[1]" mode="proofHelper"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="statementHelper">
    <xsl:variable name="idh" select="following-sibling::*[1]"/>
    <xsl:if test="preceding-sibling::text:p[1]/@text:style-name='CNXML Theorem (Statement)'">
      <xsl:apply-templates select="preceding-sibling::text:p[1]" mode="statementHelper"/>
    </xsl:if>
    <para>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </para>
  </xsl:template>


  <xsl:template match="*" mode="solHelper">
    <para>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </para>
    <xsl:if test="following-sibling::text:p[1]/@text:style-name='CNXML Exercise (Solution)'">
      <xsl:apply-templates select="following-sibling::text:p[1]" mode="solHelper"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="codeHelper">
    <xsl:value-of select="."/><xsl:text>
    </xsl:text>
    <xsl:if test="following-sibling::*[1]/@text:style-name='CNXML Code (Block)'">
      <xsl:apply-templates select="following-sibling::*[1]" mode="codeHelper"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="*" mode="exHelper">
    <xsl:if test="not(descendant::draw:image) and normalize-space()">
    <para>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id(.)" />
      </xsl:attribute>
      <xsl:apply-templates/>
    </para>
    </xsl:if>
    <xsl:if test="following-sibling::*[1]/@text:style-name='CNXML Example'">
      <xsl:apply-templates select="following-sibling::*[1]" mode="exHelper" />
    </xsl:if>
  </xsl:template>


  <!-- Para/Para -->
  <xsl:template match="text:p//text:p[not(parent::table:table-cell or parent::text:footnote-body or parent::text:endnote-body)]">
    <xsl:choose>
      <xsl:when test="parent::draw:text-box">
        <xsl:apply-templates/>  <!--avoid nested para's generated by text-box-->
      </xsl:when>
      <xsl:otherwise>
        <para>
        <xsl:attribute name="id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:apply-templates/>
        </para>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- List and list items -->
  <xsl:template match="text:ordered-list[normalize-space(.)]">
    <xsl:variable name="list-level">
      <xsl:value-of select="count(ancestor::text:ordered-list)+1" />
    </xsl:variable>

    <xsl:variable name="list-style-name">
      <xsl:choose>
        <xsl:when test="@text:style-name">
          <xsl:value-of select="@text:style-name" />
        </xsl:when>
        <!-- lists in a nested list inherit the root list style -->
        <xsl:when test="ancestor::text:ordered-list[@text:style-name]">
          <xsl:value-of select="ancestor::text:ordered-list[@text:style-name][1]/@text:style-name" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="list-type">
      <xsl:choose>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]">enumerated</xsl:when>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-bullet[@text:level=$list-level]">bulleted</xsl:when>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]">enumerated</xsl:when>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-bullet[@text:level=$list-level]">bulleted</xsl:when>
        <xsl:otherwise>bulleted</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name='number-style'>
      <xsl:choose>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='1'">arabic</xsl:when>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='A'">upper-alpha</xsl:when>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='a'">lower-alpha</xsl:when>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='I'">upper-roman</xsl:when>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='i'">lower-roman</xsl:when>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='1'">arabic</xsl:when>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='A'">upper-alpha</xsl:when>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='a'">lower-alpha</xsl:when>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='I'">upper-roman</xsl:when>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-format='i'">lower-roman</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name='before'>
      <xsl:choose>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-prefix">
          <xsl:value-of select="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-prefix" />
        </xsl:when>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-prefix">
          <xsl:value-of select="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-prefix" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name='after'>
      <xsl:choose>
        <xsl:when test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-suffix">
          <xsl:if test="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-suffix != '.'">
            <xsl:value-of select="key('list-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-suffix" />
          </xsl:if>
        </xsl:when>
        <xsl:when test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-suffix">
          <xsl:if test="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-suffix != '.'">
            <xsl:value-of select="key('list-automatic-styles', $list-style-name)/text:list-level-style-number[@text:level=$list-level]/@style:num-suffix" />
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="@text:continue-numbering='true' and preceding-sibling::*[1][self::text:ordered-list]">
        <!-- do nothing. already processed this node. -->
      </xsl:when>

      <xsl:otherwise>
        <list list-type="{$list-type}" id="{generate-id()}">
          <xsl:if test="string-length($number-style)>0">
            <xsl:attribute name="number-style">
              <xsl:value-of select="$number-style" />
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="string-length($before)>0">
            <xsl:attribute name="mark-prefix">
              <xsl:value-of select="$before" />
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="string-length($after)>0">
            <xsl:attribute name="mark-suffix">
              <xsl:value-of select="$after" />
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates />
          <xsl:call-template name="check.for.continued.numbering">
            <xsl:with-param name="current.list" select="." />
          </xsl:call-template>
        </list>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:list-header">
    <title>
      <xsl:apply-templates />
    </title>
  </xsl:template>

  <xsl:template match="text:ordered-list[not(normalize-space(.))]">
    <!-- ignore white space lists -->
  </xsl:template>

  <xsl:template name="check.for.continued.numbering">
    <xsl:param name="current.list" />
    <xsl:choose>
      <xsl:when test="$current.list/following-sibling::*[1][self::text:ordered-list[@text:continue-numbering='true']]">
        <xsl:apply-templates select="$current.list/following-sibling::*[1]/text:list-item" />
        <xsl:call-template name="check.for.continued.numbering">
          <xsl:with-param name="current.list" select="$current.list/following-sibling::*[1]" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:unordered-list[normalize-space(.)]">
    <xsl:choose>
      <xsl:when test="@text:style-name='Var List'">
        <list>
          <xsl:attribute name = "id" >
            <xsl:value-of select = "generate-id()" />
          </xsl:attribute>
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:when test="@text:style-name='UnOrdered List'">
        <list list-type="bulleted">
          <xsl:attribute name = "id" >
            <xsl:value-of select = "generate-id()" />
          </xsl:attribute>
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:otherwise>
        <list list-type="bulleted">
          <xsl:attribute name = "id" >
            <xsl:value-of select = "generate-id()" />
          </xsl:attribute>
          <xsl:apply-templates/>
        </list>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text:list-item">
    <xsl:choose>
      <xsl:when test="parent::text:unordered-list/@text:style-name='Var List'">
        <item>
          <xsl:for-each select="text:p[@text:style-name='VarList Term']">
            <xsl:if test="descendant::text:bookmark-start">
              <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </item>
      </xsl:when>
      <xsl:otherwise>
        <item>
          <xsl:if test="descendant::text:bookmark-start">
            <xsl:attribute name="id">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
          </xsl:if> 
          <xsl:apply-templates/>
        </item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:p[@text:style-name='List Contents']">
    <item>
      <xsl:if test="descendant::text:bookmark-start">
        <xsl:attribute name="id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:if> 
      <xsl:apply-templates/>
    </item>
  </xsl:template>


  <!-- Notes -->
  <xsl:template match="office:annotation/text:p">
    <note type='Note'>
      <xsl:attribute name='id'>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </note>
  </xsl:template>

  <xsl:template match="text:footnote">
    <footnote>
      <xsl:attribute name="id" >
        <xsl:value-of select="generate-id()" />
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="count(descendant::text:footnote-body/child::*)=0">
          <xsl:value-of select="descendant::text:footnote-body/*"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="descendant::text:footnote-body"/>
        </xsl:otherwise>
      </xsl:choose>
    </footnote>
  </xsl:template>


  <xsl:template match="text:endnote">
    <footnote> <!--endnote should function exactly the same as footnote -->
      <xsl:attribute name="id" >
        <xsl:value-of select="generate-id()" />
      </xsl:attribute>
      <xsl:if test="descendant::text:endnote-body//text:bookmark or descendant::text:endnote-body//text:bookmark-start">
        <xsl:attribute name="id">
          <xsl:value-of select="generate-id(descendant::text:endnote-body)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(descendant::text:endnote-body/child::*)=0">
          <xsl:value-of select="descendant::text:endnote-body/*"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="descendant::text:endnote-body"/>
        </xsl:otherwise>
      </xsl:choose>
    </footnote>
  </xsl:template>

  <!-- OOo XML has an explicit footnote number which we need to ignore -->
  <xsl:template match="text:footnote-citation" />


  <!-- Figure -->
  <xsl:template match="draw:image|draw:object-ole">
    <xsl:param name='type'>
      <xsl:value-of select="substring-after(@xlink:href,'.')"/>
    </xsl:param> 
    <!-- add extension (from $type) if it doesn't already exist. see also 'helpers.parseContent'.
    see also below "Image in a table" -->
    <xsl:variable name='beforeext'>
      <xsl:value-of select="substring-before(@draw:name, concat('.',$type))"/>
    </xsl:variable>
    <xsl:variable name='name'>
      <xsl:if test="not(string-length($beforeext))">
        <xsl:value-of select="@draw:name" />
      </xsl:if>
      <xsl:if test="boolean(string-length($beforeext))">
        <xsl:value-of select="$beforeext" />
      </xsl:if>
    </xsl:variable>

    <xsl:variable name='height'>
      <xsl:choose>
        <xsl:when test="@svg:height">
          <xsl:value-of select="round(number(substring-before(@svg:height, 'inch'))*100)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name='width'>
      <xsl:choose>
        <xsl:when test="@svg:width">
          <xsl:value-of select="round(number(substring-before(@svg:width, 'inch'))*100)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="self::draw:object-ole and parent::text:p">
        ***SORRY, THIS MEDIA TYPE IS NOT SUPPORTED.***
      </xsl:when>
      <xsl:when test="(self::draw:object-ole)">
        <xsl:comment>Sorry, this media type is not supported.</xsl:comment>
      </xsl:when>
      <xsl:when test="($type='svm')">
        <xsl:comment>Sorry, this media type is not supported.</xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(parent::text:span)">
          <figure>
            <xsl:variable name='idbase'>
              <xsl:value-of select="generate-id()"/>
            </xsl:variable>
            <xsl:attribute name="id">
              <xsl:value-of select="$idbase"/>
            </xsl:attribute>
            <xsl:if test="../preceding-sibling::text:p[position()=1]">
              <xsl:variable name="Style">
                <xsl:value-of select="../preceding-sibling::text:p[position()=1]/@text:style-name"/>
              </xsl:variable>
              <xsl:if test="$Style='CNXML Figure Title' or
                            //office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Figure Title'">
                <title>
                  <xsl:if test="../preceding-sibling::text:p[1]/text:bookmark or
                                ../preceding-sibling::text:p[1]/text:bookmark-start">
                    <xsl:attribute name="id">
                      <xsl:value-of select="generate-id(../preceding-sibling::text:p[1])"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="../preceding-sibling::text:p[1]"/>
                </title>
              </xsl:if>
            </xsl:if>
            <media alt="">
              <xsl:attribute name="id">
                <xsl:value-of select="concat($idbase,'_media')" />
              </xsl:attribute>
              <image mime-type='image/{$type}' src='{$name}.{$type}'>
                <xsl:attribute name="id" >
                  <xsl:value-of select="concat($idbase,'__onlineimage')" />
                </xsl:attribute>
                <xsl:if test="$height > 0">
                  <xsl:attribute name="height"><xsl:value-of select="$height"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$width > 0">
                  <xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
                </xsl:if>
              </image>
            </media>
            <xsl:if test="../following-sibling::text:p[1]/@text:style-name='CNXML Figure Caption'">
                <caption>
                  <xsl:choose>
                    <xsl:when test="count(../following-sibling::text:p[1]/child::*)=0">
                      <xsl:value-of select="../following-sibling::text:p[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="../following-sibling::text:p[1]/*"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </caption>
            </xsl:if>
          </figure>
        </xsl:if>
        <xsl:if test="parent::text:span">
          <!-- BNW: was inline media and is now figure??? -->
          <figure>
            <xsl:variable name='idbase'>
              <xsl:value-of select="generate-id()"/>
            </xsl:variable>
            <xsl:attribute name="id">
              <xsl:value-of select="$idbase"/>
            </xsl:attribute>
            <xsl:if test="../../preceding-sibling::text:p[position()=1]/@text:style-name='CNXML Figure Title'">
                <title>
                  <xsl:value-of select="../../preceding-sibling::text:p[position()=1]"/>
                </title>
            </xsl:if>
            <media alt="">
              <xsl:attribute name="id" >
                <xsl:value-of select="concat($idbase,'_media')" />
              </xsl:attribute>
              <image mime-type='image/{$type}' src='{$name}.{$type}'>
                <xsl:attribute name="id" >
                  <xsl:value-of select="concat($idbase,'__onlineimage')" />
                </xsl:attribute>
                <xsl:if test="$height > 0">
                  <xsl:attribute name="height"><xsl:value-of select="$height"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="$width > 0">
                  <xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
                </xsl:if>
              </image>
            </media>
            <xsl:if test="../../following-sibling::text:p[position()=1]/@text:style-name='CNXML Figure Caption'">
                <caption>
                  <xsl:value-of select="../../following-sibling::text:p[position()=1]"/>
                </caption>
            </xsl:if>
          </figure>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>

  <!-- Image in a table -->
  <!-- FIXME: Should this be a subfigure instead of a table? -->
  <xsl:template match="table:table//draw:image">
    <xsl:param name='type'>
      <xsl:value-of select="substring-after(@xlink:href,'.')"/>
    </xsl:param> 
    <!-- add extension (from $type) if it doesn't already exist. see also 'helpers.parseContent'.
    see also above "Figure" -->
    <xsl:variable name='beforeext'>
      <xsl:value-of select="substring-before(@draw:name, concat('.',$type))"/>
    </xsl:variable>
    <xsl:variable name='name'>
      <xsl:if test="not(string-length($beforeext))">
        <xsl:value-of select="@draw:name" />
      </xsl:if>
      <xsl:if test="boolean(string-length($beforeext))">
        <xsl:value-of select="$beforeext" />
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="(self::draw:object-ole or $type='svm')">
        <xsl:comment>Sorry, this media type is not supported.</xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <media alt="">
          <xsl:attribute name="id">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <image mime-type='image/{$type}' src='{@draw:name}.{$type}'/>
        </media>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Emphasis, Quote, Code, Foreign, Term-->
  <xsl:template match="text:span">
    <xsl:param name="Style">
      <xsl:value-of select="@text:style-name"/>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/style:properties/@fo:font-style='italic' and count(child::*)=1 and child::*[1]=draw:image">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/style:properties/@fo:font-style='italic'">
        <emphasis effect='italics'><xsl:apply-templates/></emphasis>
      </xsl:when>
      <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/style:properties/@fo:font-weight='bold'">
        <emphasis effect='bold'><xsl:apply-templates/></emphasis>
      </xsl:when>
      <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/style:properties/@style:text-underline">
        <emphasis effect='underline'><xsl:apply-templates/></emphasis>
      </xsl:when>
      <xsl:when test="starts-with(//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/style:properties/@style:text-position, 'sub ')">
        <sub><xsl:apply-templates/></sub>
      </xsl:when>
      <xsl:when test="starts-with(//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/style:properties/@style:text-position, 'super ')">
        <sup><xsl:apply-templates/></sup>
      </xsl:when>
      <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style and @style:parent-style-name]">
        <xsl:choose>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Term'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- term with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- term with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <term>
                  <xsl:apply-templates />
                </term>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Quote (Inline)'">
            <quote display="inline">
              <xsl:apply-templates/>
            </quote>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Emphasis'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- emphasis with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- emphasis with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <emphasis>
                  <xsl:apply-templates />
                </emphasis>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Code (Inline)' or //office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Code'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- code with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- code with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <code display="inline">
                  <xsl:apply-templates />
                </code>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Foreign'">
            <foreign>
              <xsl:apply-templates/>
            </foreign>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Cite'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!--  with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- cite with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <cite>
                  <xsl:apply-templates />
                </cite>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML Note'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- note with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- note with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <note type='Note'>
                  <xsl:attribute name='id'>
                    <xsl:value-of select="generate-id()"/>
                  </xsl:attribute>
                  <xsl:apply-templates />
                </note>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose><!--try an if statement -->
          <xsl:when test="$Style='Emphasis'">
            <emphasis>
              <xsl:apply-templates/>
            </emphasis>
          </xsl:when>
          <xsl:when test="$Style='CNXML Emphasis'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- emphasis with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- emphasis with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <emphasis>
                  <xsl:apply-templates />
                </emphasis>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='q'">
            <quote display="inline">
              <xsl:apply-templates />
            </quote>
          </xsl:when>
          <xsl:when test="$Style='Code'">
            <code display="inline">
              <xsl:apply-templates/>
            </code>
          </xsl:when>
          <xsl:when test="$Style='CNXML Code (Inline)' or $Style='CNXML Code'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- code with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- code with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <code display="inline">
                  <xsl:apply-templates />
                </code>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='CNXML Term'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- term with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- term with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <term>
                  <xsl:apply-templates />
                </term>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='CNXML Cite'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- cite with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- cite with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <cite>
                  <xsl:apply-templates />
                </cite>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='CNXML Quote (Inline)'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- quote with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- quote with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <quote display="inline">
                  <xsl:apply-templates />
                </quote>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='CNXML Foreign'">
            <foreign>
              <xsl:apply-templates/>
            </foreign>
          </xsl:when>
          <xsl:when test="$Style='CNXML Note'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- note with no text but image(s) -->
                <xsl:apply-templates />
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- note with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <note type='Note'>
                  <xsl:attribute name='id'>
                    <xsl:value-of select="generate-id()"/>
                  </xsl:attribute>
                  <xsl:apply-templates />
                </note>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  

  <xsl:template match="table:table">
    <table summary="">
      <xsl:attribute name='id'>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:if test="following-sibling::text:p[@text:style-name='Table']">
        <title>
          <xsl:value-of select="following-sibling::text:p[@text:style-name='Table']"/>
        </title>
      </xsl:if>
      <xsl:call-template name="generictable"/>
    </table>
  </xsl:template>

  <xsl:template match="table:table[count(./table:table-row/table:table-cell)=1]">
    <para>
      <xsl:attribute name='id'>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
    <!-- We have found a one entry table. -->
      <xsl:apply-templates select="./table:table-row/table:table-cell/*" />
    </para>
  </xsl:template>

  <xsl:template name="generictable">
    <tgroup>
      <!-- Determine the number of columns the table has -->
      <xsl:attribute name='cols'>
        <xsl:call-template name="count.columns" />
      </xsl:attribute>
      <!-- Put in colspecs so that entries can span correctly -->
      <xsl:call-template name="colspec.maker">
        <xsl:with-param name="numcols">
          <xsl:call-template name="count.columns" />
        </xsl:with-param>
      </xsl:call-template>
      <tbody>
        <xsl:apply-templates/>
      </tbody>
    </tgroup>
  </xsl:template>

  <xsl:template name="count.columns">
    <xsl:param name="iteration" select="1" />
    <xsl:param name="numcols" select="0" />
    <xsl:param name="location" select="." />
    <xsl:choose>
      <xsl:when test="not($location/table:table-column[$iteration])">
        <xsl:value-of select="$numcols" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$location/table:table-column[$iteration]/@table:number-columns-repeated">
            <xsl:call-template name="count.columns">
              <xsl:with-param name="numcols" select="$numcols + $location/table:table-column[$iteration]/@table:number-columns-repeated" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
              <xsl:with-param name="location" select="$location" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="count.columns">
              <xsl:with-param name="numcols" select="$numcols + 1" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
              <xsl:with-param name="location" select="$location" />
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

  <xsl:template match="table:table-column|table:table-header-rows|table:table-cell/table:sub-table|table:table-cell//table:table">
      <!-- Skip me but do my children. -->
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="table:table-row">
    <row>
      <xsl:apply-templates/>
    </row>
  </xsl:template>

  <xsl:template match="table:table-cell">
    <xsl:param name="entry.colnum">
      <xsl:call-template name="entry.colnum.determiner" />
    </xsl:param>
    <xsl:variable name="entry.or.entrytbl">
      <xsl:choose>
        <xsl:when test="table:sub-table">
          <xsl:text>entrytbl.sub-table</xsl:text>
        </xsl:when>
        <xsl:when test="descendant::table:table">
          <xsl:text>entrytbl.table</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>entry.normal</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{substring-before($entry.or.entrytbl,'.')}">
      <xsl:if test="@table:number-columns-spanned &gt; 1">
        <xsl:attribute name="namest">
          <xsl:text>c</xsl:text>
          <xsl:value-of select="$entry.colnum" />
        </xsl:attribute>
        <xsl:attribute name="nameend">
          <xsl:text>c</xsl:text>
          <xsl:value-of select="$entry.colnum + @table:number-columns-spanned - 1" />
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$entry.or.entrytbl='entrytbl.sub-table'">
          <xsl:attribute name="cols">
            <xsl:call-template name="count.columns">
              <xsl:with-param name="location" select="table:sub-table"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:call-template name="colspec.maker">
            <xsl:with-param name="numcols">
              <xsl:call-template name="count.columns">
                <xsl:with-param name="location" select="table:sub-table"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
          <tbody>
            <xsl:apply-templates />
          </tbody>
        </xsl:when>
        <xsl:when test="$entry.or.entrytbl='entrytbl.table'">
          <xsl:attribute name="cols">
            <xsl:call-template name="count.columns">
              <xsl:with-param name="location" select="descendant::table:table[1]"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:call-template name="colspec.maker">
            <xsl:with-param name="numcols">
              <xsl:call-template name="count.columns">
                <xsl:with-param name="location" select="descendant::table:table[1]"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
          <tbody>
            <xsl:apply-templates />
          </tbody>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="entry.colnum.determiner">
    <xsl:param name="iteration" select="1" />
    <xsl:param name="entry.colnum" select="1" />
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::table:table-cell[$iteration])">
        <xsl:value-of select="$entry.colnum" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="preceding-sibling::table:table-cell[$iteration]/@table:number-columns-spanned">
            <xsl:call-template name="entry.colnum.determiner">
              <xsl:with-param name="entry.colnum" select="$entry.colnum + preceding-sibling::table:table-cell[$iteration]/@table:number-columns-spanned" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="entry.colnum.determiner">
              <xsl:with-param name="entry.colnum" select="$entry.colnum + 1" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="math:math">
    <m:math>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates />
    </m:math>
  </xsl:template>

  <xsl:template match="math:*">
    <xsl:element name="m:{local-name()}">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template match="math:*/@*">
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template
    match="text:p[count(*)=1 and
                  not(ancestor::table:table-cell) and
                  draw:object[math:math and
                              string-length(normalize-space(preceding-sibling::text())) = 0 and
                              string-length(normalize-space(following-sibling::text())) = 0
                             ]
                 ]
                 ">
    <equation>
      <xsl:attribute name="id" >
        <xsl:value-of select="generate-id()" />
      </xsl:attribute>      
      <xsl:apply-templates />
    </equation>
  </xsl:template>

<!-- Link -->

  <xsl:template match="text:a">
    <xsl:choose>
      <xsl:when test="text:span/@text:style-name='CNXML Cite'">
        <cite>
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
          <xsl:value-of select="child::*"/>
        </cite>
      </xsl:when>
      <xsl:when test="text:span/@text:style-name='CNXML Term'">
        <term>
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
           <xsl:value-of select="child::*"/>
        </term>
      </xsl:when>
      <xsl:when test="text:span/@text:style-name='CNXML Foreign'">
        <foreign>
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
           <xsl:value-of select="child::*"/>
        </foreign>
      </xsl:when>
      <xsl:when test="text:span/@text:style-name='CNXML Quote (Inline)'">
        <quote display="inline">
          <xsl:attribute name="id">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
           <xsl:value-of select="child::*"/>
        </quote>
      </xsl:when>
      <xsl:when test="starts-with(@xlink:href,'#')">
        <xsl:variable name="markName" select="normalize-space(translate(@xlink:href,'#',' '))"/>
        <link>
          <xsl:attribute name="target-id">
              <xsl:choose>
                <xsl:when test="ancestor::office:body//text:bookmark-start/@text:name=$markName">
                  <xsl:choose>
                    <xsl:when test="key('bookmark-start',$markName)/parent::name">
                      <xsl:value-of select="generate-id(key('bookmark-start',$markName)/ancestor::section[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark-start',$markName)/ancestor::text:list-item">
                      <xsl:value-of select="generate-id(key('bookmark-start',$markName)/ancestor::text:list-item[1])"/>
                    </xsl:when>
                    <xsl:when test="count(key('bookmark-start',$markName)/../child::*)=2 and not(normalize-space(key('bookmark-start',$markName)/..))">
                      <xsl:value-of select="generate-id(key('bookmark-start',$markName)/../following-sibling::*[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark-start',$markName)/ancestor::text:footnote-body">
                      <xsl:value-of select="generate-id(key('bookmarkstart',$markName)/ancestor::text:footnote-body[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark-start',$markName)/ancestor::table:table">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::table:table[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="generate-id(key('bookmark-start',$markName)/parent::*)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="ancestor::office:body//text:bookmark/@text:name=$markName">
                  <xsl:choose>
                    <xsl:when test="key('bookmark',$markName)/parent::name">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::section[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark',$markName)/ancestor::text:list-item">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::text:list-item[1])"/>
                    </xsl:when>
                    <xsl:when test="count(key('bookmark',$markName)/../child::*)=2 and not(normalize-space(key('bookmark',$markName)/..))">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/../following-sibling::*[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark',$markName)/ancestor::text:footnote-body">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::text:footnote-body[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark',$markName)/ancestor::table:table">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::table:table[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/parent::*)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates />
        </link>
      </xsl:when>
      <xsl:when test="contains(@xlink:href,'cnx.org/content/') or contains(@xlink:href,'cnx.rice.edu/content/')">
        <xsl:variable name="cnxURL" select="substring-after(@xlink:href,'content/')"/>
        <xsl:variable name="cnxnDoc" select="substring-before($cnxURL,'/')" />
        <xsl:variable name="cnxnVer">
          <xsl:choose>
            <xsl:when test="contains(substring-after($cnxURL,concat($cnxnDoc,'/')),'/')">
              <xsl:value-of select="substring-before(substring-after($cnxURL,concat($cnxnDoc,'/')),'/')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-after($cnxURL,concat($cnxnDoc,'/'))" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cnxnTar">
          <xsl:if test="normalize-space($cnxnVer)">
            <xsl:value-of select="normalize-space(translate(substring-after($cnxURL,$cnxnVer),'/#','  '))"/>
          </xsl:if>
        </xsl:variable>
        <link>
          <xsl:attribute name='document'>
            <xsl:value-of select="$cnxnDoc" />
          </xsl:attribute>
          <xsl:if test="normalize-space($cnxnVer) and not($cnxnVer='latest')">
            <xsl:attribute name='version'>
              <xsl:value-of select="$cnxnVer" />
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="normalize-space($cnxnTar)">
            <xsl:attribute name='target-id'>
              <xsl:value-of select="$cnxnTar" />            
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </link>
      </xsl:when>
      <xsl:otherwise>
        <link>
          <xsl:attribute name='url'>
                <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </link>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:template>

  <xsl:template match="text:tab-stop">
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- S -->
  <xsl:template match="text:s"/>

  <!-- Squash Everything Else -->

  <xsl:template select="*"/>

  <xsl:template match="text:deletion" />

  <xsl:template match="form:property-value" />

  <xsl:template match="text:index-title-template" />

  <xsl:template match="text:bibliography-entry-template" />

  <xsl:template match="number:date-style" />

</xsl:stylesheet>


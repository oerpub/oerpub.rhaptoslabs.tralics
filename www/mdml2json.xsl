<?xml version="1.0" encoding="UTF-8"?>
<!--
	Converts cnxml to JSON using a simple js-like structure for metadata, 
	and a more verbose structure for the content
	(to preserver element ordering and multiple text nodes) 
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:c="http://cnx.rice.edu/cnxml"
	>
	<xsl:import href="xml2json.xsl"/>

<xsl:param name="json.omitprefix">1</xsl:param>

<xsl:template match="c:metadata">
	<xsl:apply-templates mode="json" select=".">
		<xsl:with-param name="skipKey" select="true()"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="c:metadata//*">
        <xsl:apply-templates mode="json" select="."/>
</xsl:template>



<!-- Ignore everything else -->
<xsl:template match="*">
  <xsl:apply-templates select="*"/>
</xsl:template>

</xsl:stylesheet>

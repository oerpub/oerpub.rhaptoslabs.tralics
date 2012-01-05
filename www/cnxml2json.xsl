<?xml version="1.0" encoding="UTF-8"?>
<!--
	Converts cnxml to JSON using a simple js-like structure for metadata, 
	and a more verbose structure for the content
	(to preserver element ordering and multiple text nodes) 
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	>
	<xsl:import href="xml2json.xsl"/>
<xsl:param name="json.omitprefix">1</xsl:param>
<xsl:param name="json.printroot" select="false()"/>


<xsl:template match="c:content" xmlns:c="http://cnx.rice.edu/cnxml">
	<xsl:apply-templates mode="json.xmlish" select="."/>
</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
	Extracts additional authors and collaborators in a SWORD mets.xml file
	and outputs a JSON dictionary.
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:bib="http://bibtexml.sf.net/"
	xmlns:epdcx="http://purl.org/eprint/epdcx/2006-11-16/">
	<xsl:output indent="no" method="xml" encoding="UTF-8" />

	<!-- Skip all values except the ones we care about -->
	<xsl:template match="epdcx:valueString" />

	<xsl:template match="epdcx:statement[@epdcx:propertyURI='http://purl.org/dc/elements/1.1/title']">
	  <title><xsl:value-of select="epdcx:valueString/text()" /></title>
	</xsl:template>

	<xsl:template match="epdcx:statement[@epdcx:propertyURI='http://purl.org/dc/terms/abstract']">
	  <abstract><xsl:value-of select="epdcx:valueString/text()" /></abstract>
	</xsl:template>

	<xsl:template match="epdcx:statement[@epdcx:propertyURI='http://purl.org/dc/elements/1.1/language']">
		<language><xsl:value-of select="epdcx:valueString/text()" /></language>
	</xsl:template>


	<xsl:template match="epdcx:valueString[bib:file]">
		<xsl:apply-templates select="bib:file/*" />
	</xsl:template>

	<xsl:template match="bib:entry">
                <has_attribution_note>true</has_attribution_note>
		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="bib:*">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*|node()" />
		</xsl:element>
	</xsl:template>

        <xsl:template match="bib:title|bib:abstract"/>

        <xsl:template match="bib:keywords">
            <keywords><xsl:processing-instruction name="json.force-array"/>
                <xsl:apply-templates select="@*|node()" />
            </keywords>
        </xsl:template>

	<!-- Hacked so we get a JSON array named "import_authors" -->
	<xsl:template match="bib:author">
		<import_authors><xsl:processing-instruction name="json.force-array"/>
			<xsl:apply-templates select="@*|node()" />
		</import_authors>
	</xsl:template>

	<!-- Match the root -->
	<xsl:template match="/">
		<metadata>
			<xsl:apply-templates select="@*|node()" />
			<!-- The editor object has a boolean flag for whether or not the module was imported (to show additional messages to the user) -->
			<is_imported>true</is_imported>
		</metadata>
	</xsl:template>

	<!-- All other elements are ignored -->
	<xsl:template match="@*|*">
		<xsl:apply-templates />
	</xsl:template>

</xsl:stylesheet>

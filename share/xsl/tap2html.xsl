<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:func="http://exslt.org/functions"
	xmlns:set="http://exslt.org/sets"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"
	xmlns:tap="http://xml.elide.org/tap"

	extension-element-prefixes="func set str common tap">

	<xsl:param name="src"/> <!-- ':'-delimited list of tap XML files -->

	<xsl:variable name="root">
		<xsl:for-each select="str:tokenize($src, ':')">
			<xsl:copy-of select="document(.)/tap:tap"/>
		</xsl:for-each>
	</xsl:variable>


	<xsl:output method="xml" version="1.0"
		omit-xml-declaration="no"
		encoding="utf-8"
		indent="yes"
		standalone="yes"
		cdata-section-elements="script"
		doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
		doctype-public="-//W3C//DTD XHTML 1.1//EN"/>

	<xsl:template match="tap:test" mode="overview">
		<li>
			<a class="test {translate(@status, ' ', '')}" href="#TODO">
				<xsl:value-of select="@name"/>
			</a>
		</li>
	</xsl:template>

	<xsl:template match="tap:test" mode="details">
		<dt>
			<a class="test {translate(@status, ' ', '')}" href="#TODO">
				<xsl:value-of select="@name"/>
			</a>
		</dt>

		<dd>
			<pre>
				<xsl:copy-of select="text()"/>
			</pre>
		</dd>
	</xsl:template>

	<xsl:template match="tap:tap" mode="overview">
		<xsl:variable name="ok"  select="count(common:node-set($root)
			/tap:tap/tap:test[@status = 'ok'])"/>
		<xsl:variable name="all" select="count(common:node-set($root)
			/tap:tap/tap:test)"/>

		<dt>
			<xsl:text>some file:</xsl:text> <!-- TODO -->
			<br/>
			<xsl:value-of select="$ok"/>
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$all"/>
			<xsl:text>&#xA0;ok</xsl:text>
		</dt>

		<dd>
			<ol class="overview">
				<xsl:apply-templates select="tap:test" mode="overview"/>
			</ol>
		</dd>
	</xsl:template>

	<xsl:template match="tap:tap" mode="details">
		<section>
			<h2>
				<xsl:text>some file</xsl:text> <!-- TODO -->
			</h2>

			<dl class="details">
				<xsl:apply-templates select="common:node-set($root)//tap:test" mode="details"/>
			</dl>
		</section>
	</xsl:template>

<!-- TODO: pass list of tap xml files to document() in turn -->
	<xsl:template match="/">
		<xsl:variable name="title">
			<xsl:text>TAP Report</xsl:text>
		</xsl:variable>

		<html>
			<head>
				<title>
					<xsl:copy-of select="$title"/>
				</title>

				<link rel="stylesheet" type="text/css" href="css/tap.css"/>

				<script type="text/javascript" src="js/col.js"></script>
			</head>

			<body onload="var r = document.documentElement;
				Colalign.init(r);">

				<h1>
					<xsl:copy-of select="$title"/>
				</h1>

				<dl class="overview">
					<xsl:apply-templates select="common:node-set($root)
						/tap:tap" mode="overview"/>
				</dl>

				<p>
					<xsl:variable name="ok"  select="count(common:node-set($root)
						/tap:tap/tap:test[@status = 'ok'])"/>
					<xsl:variable name="all" select="count(common:node-set($root)
						/tap:tap/tap:test)"/>

					<xsl:value-of select="$ok"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="$all"/>
					<xsl:text> ok total</xsl:text>

					<xsl:variable name="pass" select="($ok div $all) * 100"/>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="round($pass * 100) div 100"/> <!-- for 2dp -->
					<xsl:text>% pass</xsl:text>
				</p>

				<article>
					<xsl:apply-templates select="common:node-set($root)
						/tap:tap" mode="details"/>
				</article>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>


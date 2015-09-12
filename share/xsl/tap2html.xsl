<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:func="http://exslt.org/functions"
	xmlns:set="http://exslt.org/sets"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"
	xmlns:tap="http://xml.elide.org/tap"

	extension-element-prefixes="func set str common">

	<xsl:param name="src"/> <!-- ':'-delimited list of tap XML files -->

	<xsl:variable name="root">
		<xsl:for-each select="str:tokenize($src, ':')">
			<xsl:variable name="filename" select="str:tokenize(., '/')[last()]/text()"/>

			<tap:tap src="{substring-before($filename, '.')}">
				<xsl:copy-of select="document(.)/tap:tap/tap:test"/>
			</tap:tap>
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

	<xsl:template match="tap:tap" mode="overview">
		<xsl:variable name="ok"    select="count(tap:test[@status = 'ok'])"/>
		<xsl:variable name="notok" select="count(tap:test[@status = 'not ok'])"/>

		<!-- TODO: centralise as function -->
		<xsl:variable name="status">
			<xsl:choose>
				<xsl:when test="$notok = 0">
					<xsl:text>ok</xsl:text>
				</xsl:when>
				<xsl:when test="$ok = 0">
					<xsl:text>notok</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>some</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<tr>
			<td class="status {$status}">
				<!-- TODO: centralise as function -->
				<xsl:value-of select="$ok"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$ok + $notok"/>
				<xsl:text>&#xA0;ok</xsl:text>
			</td>

			<td class="status {$status}">
				<xsl:value-of select="@src"/> <!-- TODO -->
			</td>

			<td>
				<ol>
					<xsl:apply-templates select="tap:test" mode="overview"/>
				</ol>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="tap:test" mode="details">
		<tr>
			<td class="status">
				<a class="test {translate(@status, ' ', '')}" href="#TODO">
					<xsl:value-of select="@status"/>
				</a>
			</td>
			<td class="num">
				<xsl:value-of select="position()"/>
			</td>
			<td>
				<xsl:value-of select="@name"/>
			</td>
		</tr>

		<xsl:if test="text()">
			<tr class="text">
				<td colspan="2"/>
				<td>
					<pre>
						<xsl:copy-of select="text()"/>
					</pre>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tap:tap" mode="details">
		<xsl:variable name="ok"    select="count(tap:test[@status = 'ok'])"/>
		<xsl:variable name="notok" select="count(tap:test[@status = 'not ok'])"/>

		<xsl:variable name="status">
			<xsl:choose>
				<xsl:when test="$notok = 0">
					<xsl:text>ok</xsl:text>
				</xsl:when>
				<xsl:when test="$ok = 0">
					<xsl:text>notok</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>some</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<thead class="summary {$status}">
			<th class="{$status}" colspan="2">
				<xsl:value-of select="$ok"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$ok + $notok"/>
				<xsl:text>&#xA0;ok</xsl:text>
			</th>
			<th class="{$status} src">
				<xsl:value-of select="@src"/> <!-- TODO -->
			</th>
		</thead>

		<tbody>
			<xsl:apply-templates select="tap:test" mode="details"/>
		</tbody>
	</xsl:template>

<!-- TODO: pass list of tap xml files to document() in turn -->
	<xsl:template match="/">
		<xsl:variable name="title">
			<xsl:text>TAP Report</xsl:text>
		</xsl:variable>

		<xsl:variable name="ok"    select="count(common:node-set($root)
			//tap:test[@status = 'ok'])"/>
		<xsl:variable name="notok" select="count(common:node-set($root)
			//tap:test[@status = 'not ok'])"/>

		<xsl:variable name="status">
			<xsl:choose>
				<xsl:when test="$notok = 0">
					<xsl:text>ok</xsl:text>
				</xsl:when>
				<xsl:when test="$ok = 0">
					<xsl:text>notok</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>some</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
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

				<table class="overview">
					<xsl:apply-templates select="common:node-set($root)
						/tap:tap" mode="overview"/>

					<tr>
						<td class="status {$status}" colspan="2">
							<!-- TODO: centralise as function -->
							<xsl:value-of select="$ok"/>
							<xsl:text>/</xsl:text>
							<xsl:value-of select="$ok + $notok"/>
							<xsl:text> total</xsl:text>

							<xsl:variable name="pass" select="($ok div ($ok + $notok)) * 100"/>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="round($pass * 100) div 100"/> <!-- for 2dp -->
							<xsl:text>% ok</xsl:text>
						</td>
					</tr>
				</table>

				<table class="details">
					<xsl:apply-templates select="common:node-set($root)
						/tap:tap" mode="details"/>
				</table>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>


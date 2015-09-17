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

			<tap:tap src="{substring-before($filename, '.xml')}">
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

	<func:function name="tap:category">
		<xsl:param name="ok"    select="0"/>
		<xsl:param name="notok" select="0"/>

		<func:result>
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
		</func:result>
	</func:function>

	<func:function name="tap:ratio">
		<xsl:param name="ok"    select="0"/>
		<xsl:param name="notok" select="0"/>

		<func:result>
			<xsl:value-of select="$ok"/>
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$ok + $notok"/>
			<xsl:text>&#xA0;ok</xsl:text>
		</func:result>
	</func:function>

	<func:function name="tap:name">
		<xsl:param name="name"   select="false()"/>
		<xsl:param name="status" select="false()"/>

		<func:result>
			<xsl:choose>
				<xsl:when test="$status = 'todo'">
					<span class="absence">
						<xsl:text>(TODO)</xsl:text>
					</span>
					<xsl:if test="$name or $status = 'missing'">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$status = 'skip'">
					<span class="absence">
						<xsl:text>(skipped)</xsl:text>
					</span>
					<xsl:if test="$name or $status = 'missing'">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:when>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="not($name) and $status = 'missing'">
					<span class="absence">
						<xsl:text>(missing)</xsl:text>
					</span>
				</xsl:when>
				<xsl:when test="not($name)">
					<xsl:text>(no name)</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$name"/>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>

	<xsl:template match="tap:test" mode="index">
		<li>
			<xsl:if test="not(@name)">
				<xsl:attribute name="class">
					<xsl:text>na</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<a class="index {translate(@status, ' ', '')}" href="#TODO">
				<xsl:value-of select="@n"/>
			</a>
		</li>
	</xsl:template>

	<xsl:template name="index">
		<xsl:param name="status"/>

		<xsl:variable name="limit" select="20"/>

		<xsl:if test="tap:test[@status = $status]">
			<tr>
				<th>
					<a class="test status {translate($status, ' ', '')}" href="#TODO">
						<xsl:value-of select="count(tap:test[@status = $status])"/>
						<xsl:text>&#xA0;</xsl:text>
						<xsl:value-of select="$status"/>
					</a>
				</th>
				<td>
					<ol>
						<xsl:apply-templates select="tap:test[@status = $status][position() &lt; $limit]" mode="index"/>
						<xsl:if test="count(tap:test[@status = $status]) &gt; $limit">
							<li>
								<xsl:text>... and </xsl:text>
								<xsl:value-of select="count(tap:test[@status = $status]) - $limit"/>
								<xsl:text>&#xA0;more</xsl:text>
							</li>
						</xsl:if>
					</ol>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tap:tap" mode="overview">
		<xsl:variable name="ok"      select="count(tap:test[@status = 'ok' or @status = 'todo' or @status = 'skip'])"/>
		<xsl:variable name="notok"   select="count(tap:test[@status = 'not ok' or @status = 'missing'])"/>

		<tr>
			<td class="status {tap:category($ok, $notok)}">
				<xsl:copy-of select="tap:ratio($ok, $notok)"/>
			</td>

			<td class="status {tap:category($ok, $notok)}">
				<xsl:value-of select="@src"/> <!-- TODO -->
			</td>

			<td>
				<xsl:choose>
					<xsl:when test="count(tap:test) = count(tap:test[@status = 'ok'])">
						<span class="na">
							<xsl:text>(none)</xsl:text>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<table class="index">
							<xsl:call-template name="index">
								<xsl:with-param name="status" select="'missing'"/>
							</xsl:call-template>
							<xsl:call-template name="index">
								<xsl:with-param name="status" select="'not ok'"/>
							</xsl:call-template>
							<xsl:call-template name="index">
								<xsl:with-param name="status" select="'skip'"/>
							</xsl:call-template>
							<xsl:call-template name="index">
								<xsl:with-param name="status" select="'todo'"/>
							</xsl:call-template>
						</table>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="tap:test" mode="details">
		<tr>
			<xsl:if test="not(@name) or @status = 'todo' or @status = 'skip'">
				<xsl:attribute name="class">
					<xsl:text>na</xsl:text>
				</xsl:attribute>
			</xsl:if>

			<td class="status">
				<a class="test {translate(@status, ' ', '')}" href="#TODO">
					<xsl:value-of select="@status"/>
				</a>
			</td>
			<td class="num">
				<xsl:value-of select="@n"/>
			</td>
			<td>
				<xsl:copy-of select="tap:name(@name, @status)"/>
				<xsl:if test="@rep">
					<xsl:text> </xsl:text>
					<span class="rep">
						<xsl:text> (repeated&#xA0;&#xD7;</xsl:text>
						<xsl:value-of select="@rep"/>
						<xsl:text>)</xsl:text>
					</span>
				</xsl:if>
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
		<xsl:variable name="ok"    select="count(tap:test[@status = 'ok' or @status = 'todo' or @status = 'skip'])"/>
		<xsl:variable name="notok" select="count(tap:test[@status = 'not ok' or @status = 'missing'])"/>

		<thead class="summary {tap:category($ok, $notok)}">
			<th class="{tap:category($ok, $notok)}" colspan="2">
				<xsl:copy-of select="tap:ratio($ok, $notok)"/>
			</th>
			<th class="{tap:category($ok, $notok)} src">
				<xsl:value-of select="@src"/> <!-- TODO -->
			</th>
		</thead>

		<tbody>
			<xsl:apply-templates select="tap:test" mode="details">
				<xsl:sort data-type="text"   select="@status"/>
				<xsl:sort data-type="number" select="@n"/>
			</xsl:apply-templates>
		</tbody>
	</xsl:template>

<!-- TODO: pass list of tap xml files to document() in turn -->
	<xsl:template match="/">
		<xsl:variable name="title">
			<xsl:text>TAP Report</xsl:text>
		</xsl:variable>

		<xsl:variable name="ok"      select="count(common:node-set($root)
			//tap:test[@status = 'ok' or @status = 'todo' or @status = 'skip'])"/>
		<xsl:variable name="notok"   select="count(common:node-set($root)
			//tap:test[@status = 'not ok' or @status = 'missing'])"/>

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
					<tr>
						<td class="status {tap:category($ok, $notok)}" colspan="2">
							<xsl:copy-of select="tap:ratio($ok, $notok)"/>
							<xsl:text> total</xsl:text>

							<xsl:variable name="pass" select="($ok div ($ok + $notok)) * 100"/>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="round($pass * 100) div 100"/> <!-- for 2dp -->
							<xsl:text>% ok</xsl:text>
						</td>
						<th>
							<xsl:text>Unresolved issues</xsl:text>
						</th>
					</tr>

					<xsl:apply-templates select="common:node-set($root)
						/tap:tap" mode="overview"/>
				</table>

				<table class="details">
					<xsl:apply-templates select="common:node-set($root)
						/tap:tap" mode="details"/>
				</table>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>


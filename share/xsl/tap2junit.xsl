<?xml version="1.0"?>

<!--
	Copyright 2015-2017 Katherine Flavel

	See LICENCE for the full copyright terms.
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:func="http://exslt.org/functions"
	xmlns:set="http://exslt.org/sets"
	xmlns:str="http://exslt.org/strings"
	xmlns:common="http://exslt.org/common"
	xmlns:tap="http://xml.elide.org/tap"

	extension-element-prefixes="func set str common"
	exclude-result-prefixes="tap">

	<xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8"
		standalone="yes" cdata-section-elements="system-out system-err"/>

	<xsl:param name="src"/> <!-- ':'-delimited list of tap XML files -->

	<xsl:variable name="root">
		<xsl:for-each select="str:tokenize($src, ':')">
			<xsl:variable name="filename" select="str:tokenize(., '/')[last()]/text()"/>

			<tap:tap src="{substring-before($filename, '.xml')}">
				<xsl:copy-of select="document(.)/tap:tap/tap:test"/>
			</tap:tap>
		</xsl:for-each>
	</xsl:variable>

	<func:function name="tap:name">
		<xsl:param name="name"   select="false()"/>
		<xsl:param name="status" select="false()"/>

		<func:result>
			<xsl:choose>
				<xsl:when test="$status = 'todo'">
					<xsl:text>(TODO)</xsl:text>
					<xsl:if test="$name or $status = 'missing'">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$status = 'skip'">
					<xsl:text>(skipped)</xsl:text>
					<xsl:if test="$name or $status = 'missing'">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:when>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="not($name) and $status = 'missing'">
					<xsl:text>(missing)</xsl:text>
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

	<xsl:template match="tap:test" mode="details">
		<xsl:variable name="name">
			<xsl:copy-of select="tap:name(@name, @status)"/>

			<xsl:if test="@rep">
				<xsl:text> </xsl:text>
				<xsl:text> (repeated&#xA0;&#xD7;</xsl:text>
				<xsl:value-of select="@rep"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</xsl:variable>

		<testcase
			classname="{../@src}"
			name="{$name}">
			<!-- TODO: time="" -->

			<xsl:choose>
				<xsl:when test="@status = 'todo' or @status = 'skip'">
					<skipped/>
				</xsl:when>
				<xsl:when test="@status = 'missing'">
					<error message="{@status}"/>
				</xsl:when>
				<xsl:when test="@status = 'not ok'">
					<failure message="{@status}"/>
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>

			<system-out>
				<xsl:copy-of select="text()"/>
			</system-out>
			<system-err/>
		</testcase>
	</xsl:template>

<!-- TODO: pass list of tap xml files to document() in turn -->
	<xsl:template match="/">
		<xsl:variable name="title">
			<xsl:text>TAP Report</xsl:text>
		</xsl:variable>

		<xsl:variable name="skipped"  select="count(common:node-set($root)
			//tap:test[@status = 'todo' or @status = 'skip'])"/>
		<xsl:variable name="ok"       select="count(common:node-set($root)
			//tap:test[@status = 'ok'])"/>
		<xsl:variable name="errors"   select="count(common:node-set($root)
			//tap:test[@status = 'missing'])"/>
		<xsl:variable name="failures" select="count(common:node-set($root)
			//tap:test[@status = 'not ok'])"/>
		<xsl:variable name="tests"    select="count(common:node-set($root)
			//tap:test)"/>

		<testsuites>
			<testsuite
					name="{$title}"
					errors="{$errors}"
					failures="{$failures}"
					skipped="{$skipped}"
					tests="{$tests}">
				<!-- TODO: time="" -->
				<!-- TODO: timestamp="" -->

				<properties/>

				<xsl:apply-templates select="common:node-set($root)
					/tap:tap" mode="details"/>
			</testsuite>
		</testsuites>
	</xsl:template>

</xsl:stylesheet>


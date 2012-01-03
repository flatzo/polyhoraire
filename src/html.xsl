<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:php="http://php.net/xsl" xmlns:url="http://whatever/java/java.net.URLEncoder"
	xmlns:atom="http://www.w3.org/2005/Atom" xmlns:batch='http://schemas.google.com/gdata/batch'
	xmlns:openSearch='http://a9.com/-/spec/opensearch/1.1/' xmlns:gCal='http://schemas.google.com/gCal/2005'
	xmlns:gd='http://schemas.google.com/g/2005' gd:etag='W/"CkYFSHg-fyp7ImA9WxRVGUo."'
	exclude-result-prefixes="atom gCal openSearch gd fn url php">


	<xsl:output encoding="UTF-8" method="html" indent="yes" />
	<xsl:param name="app" />

	<xsl:template match="/">
		<xsl:apply-templates select="/root/form" />
		<xsl:apply-templates select="/root/atom:feed" />
		<xsl:apply-templates select="/root/linkButton" />
		
		
		<xsl:element name="ul">
			<xsl:apply-templates select="/root/addedRecently" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="addedRecently">
		<xsl:if test="position() = 1">
		<xsl:element name="h1">
			<xsl:text>Modification récentes</xsl:text>
		</xsl:element>
		</xsl:if>
		<xsl:element name="li">
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>

	<xsl:template
		match="atom:feed[atom:id = 'http://www.google.com/calendar/feeds/default/allcalendars/full']">
		<h3>Choix du calendrier</h3>
		<table>
			<xsl:apply-templates select="atom:entry" />
		</table>
	</xsl:template>

	<xsl:template match="atom:feed"></xsl:template>

	<xsl:template
		match="atom:feed[atom:id = 'http://www.google.com/calendar/feeds/default/owncalendars/full']">
		<xsl:element name="h1">
			<xsl:text>Étape 2 : Choisir le calendrier</xsl:text>
		</xsl:element>
		<xsl:element name="ul">
			<xsl:apply-templates select="atom:entry" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="atom:feed[contains(string(atom:id),'/batch/')]">
		<xsl:if test="not(descendant::batch:status/@code = '201')">
			<xsl:variable name="calendarUrl">
				<xsl:value-of select="substring-before(descendant::atom:id, 'batch')" />
				<xsl:text>batch</xsl:text>
			</xsl:variable>
			<xsl:call-template name="linkButton">
				<xsl:with-param name="title">
					Réessayer
				</xsl:with-param>
				<xsl:with-param name="link">?app=PolyHoraire&amp;action=send
					<xsl:value-of select="atom:title" />
					&amp;calendar=
					<xsl:value-of select="$calendarUrl" />
				</xsl:with-param>

			</xsl:call-template>
		</xsl:if>
		<xsl:element name="table">
			<xsl:apply-templates select="descendant::atom:entry" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="atom:entry[namespace::batch]">
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:value-of select="descendant::atom:title" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:choose>
					<xsl:when test="descendant::batch:status/@code = '201'">
						<xsl:attribute name="class">
							<xsl:text>succes</xsl:text>
						</xsl:attribute>
						<xsl:element name="strong">
							<xsl:text>Réussis</xsl:text>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class">
							<xsl:text>failed</xsl:text>
						</xsl:attribute>
						<xsl:element name="strong">
							<xsl:text>Manqué</xsl:text>
						</xsl:element>
					</xsl:otherwise>

				</xsl:choose>
			</xsl:element>
		</xsl:element>

	</xsl:template>

	<xsl:template match="atom:entry">
		<xsl:element name="li">
			<xsl:attribute name="class">
				<xsl:text>linkButton</xsl:text>
			</xsl:attribute>
			<xsl:element name="span">
				<xsl:attribute name="class">
					<xsl:text>gradientBox</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="style">
					<xsl:text>background-color:</xsl:text>
					<xsl:value-of select="gCal:color/@value" />
					<xsl:text>;</xsl:text>
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="a">
				<xsl:attribute name="href">
				 	<xsl:text>?app=</xsl:text>
				 	<xsl:value-of select="$app" />
				 	<xsl:text>&amp;action=send&amp;calendar=</xsl:text>
					<xsl:text>https://www.google.com/calendar/feeds/</xsl:text>
					<xsl:value-of
					select="substring-after(string(atom:id),'http://www.google.com/calendar/feeds/default/owncalendars/full/')" />
					<xsl:text>/private/full/batch</xsl:text>
					<!-- 
					<xsl:choose>
						<xsl:when test="function-available(url:encode)">
							<xsl:value-of select="url:encode(atom:id)"/>
						</xsl:when>
						<xsl:when test="function-available(fn:encode-for-uri)">
							<xsl:value-of select="fn:encode-for-uri(atom:id)"></xsl:value-of>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="php:function('urlencode',string(atom:id))"></xsl:value-of>
						</xsl:otherwise>
					</xsl:choose> 
					 -->
				</xsl:attribute>
				<xsl:value-of select="atom:title" />
			</xsl:element>
		</xsl:element>
	</xsl:template>


	<xsl:template match="section[@name='signIn']">
		<form action="?action=getSchedule" method="post">
			<fieldset>
				<legend>Identifiants du dossier étudiant</legend>
				<div>
					<label for="codeAcces">Code d'accèes</label>
					<input type="text" id="codeAcces" />
				</div>
				<div>
					<label for="motDePasse">Mot de passe</label>
					<input type="password" id="motDePasse" />
				</div>
				<div>
					<label for="dateDeNaissance">Date de naissance (AAMMJJ)</label>
					<input type="text" id="dateDeNaissance" />
				</div>
				<button type="submit">Récupérer l'horaire</button>
			</fieldset>
		</form>
	</xsl:template>

	<xsl:template match="form">
		<xsl:element name="form">
			<xsl:attribute name="action">
				<xsl:text>?app=</xsl:text>
				<xsl:value-of select="$app" />
				<xsl:text>&amp;action=</xsl:text>
				<xsl:value-of select="@action" />
			</xsl:attribute>
			<xsl:attribute name="method">
				<xsl:text>post</xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="fieldset" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="fieldset">
		<xsl:element name="fieldset">
			<xsl:element name="legend">
				<xsl:value-of select="@name" />
			</xsl:element>
			<xsl:apply-templates select="input|button" />

		</xsl:element>
	</xsl:template>


	<xsl:template match="input">
		<xsl:element name="div">
			<xsl:element name="label">
				<xsl:attribute name="for">
					<xsl:value-of select="@id" />
				</xsl:attribute>
				<xsl:value-of select="@label" />
			</xsl:element>
			<xsl:element name="input">
				<xsl:attribute name="type">
					<xsl:value-of select="@type" />
				</xsl:attribute>
				<xsl:attribute name="name">
					<xsl:value-of select="@id" />
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="button">
		<xsl:element name="div">
			<xsl:element name="button">
				<xsl:attribute name="type">
					<xsl:value-of select="@type" />
				</xsl:attribute>
				<xsl:value-of select="." />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="linkButton">
		<xsl:element name="a">
			<xsl:attribute name="href">
				<xsl:value-of select="@href" />
			</xsl:attribute>
			<xsl:attribute name="class">
				<xsl:text>linkButton</xsl:text>
			</xsl:attribute>
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template name="linkButton">
		<xsl:param name="link" />
		<xsl:param name="title" />
		<xsl:element name="a">
			<xsl:attribute name="href">
				<xsl:value-of select="$link" />
			</xsl:attribute>
			<xsl:attribute name="class">
				<xsl:text>linkButton</xsl:text>
			</xsl:attribute>
			<xsl:value-of select="$title" />
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
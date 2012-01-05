<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns = "http://www.w3.org/2005/Atom"
xmlns:str="http://exslt.org/strings"
xmlns:gd="http://schemas.google.com/g/2005"
xmlns:date="http://exslt.org/dates-and-times"
xmlns:batch="http://schemas.google.com/gdata/batch"
exclude-result-prefixes="str date"	>
<xsl:param name="debutSession"/>
<xsl:param name="debutSessionB2"/>
<xsl:param name="debutRelache"/>
<xsl:param name="finRelache"/>
<xsl:param name="finRelacheB2"></xsl:param>
<xsl:param name="finSession"/>
<xsl:param name="calendrierCours"/>
<xsl:param name="calendrierLabs"/>
<xsl:param name="title"/>


	<xsl:template match="/poly">
		<xsl:if test="$debutSession = ''">
			<xsl:message terminate="no">manque la date pour le debut de la session (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		<xsl:if test="$debutSessionB2 = ''">
			<xsl:message terminate="no">manque la date pour le debut de la session pour la semaine B2 (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		<xsl:if test="$debutRelache = ''">
			<xsl:message terminate="no">manque la date pour le debut de la relache (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		<xsl:if test="$finSession = ''">
			<xsl:message terminate="no">manque la date pour la fin de la session (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		<xsl:if test="$finRelache = ''">
			<xsl:message terminate="no">manque la date pour la fin de la relache (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		<xsl:if test="$finRelacheB2 = 'http://schemas.google.com/g/2005'">
			<xsl:message terminate="no">manque la date pour la fin de la relache pour la semaine B2 (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		
		<xsl:element name="feed" namespace="http://www.w3.org/2005/Atom">
			
			<xsl:element name="title">
			<xsl:attribute name="type">text</xsl:attribute>
				<xsl:value-of select="$title"/>
			</xsl:element>
		<xsl:element name="category">
			<xsl:attribute name="scheme">http://schemas.google.com/g/2005#kind</xsl:attribute>
			<xsl:attribute name="term">http://schemas.google.com/g/2005#event</xsl:attribute>
		</xsl:element>
		<xsl:for-each select="horaire/evenement">
			<xsl:element name="entry">
			
				<xsl:element name="batch:id">
					<xsl:value-of select="position()"/>
				</xsl:element>
				<xsl:element name="batch:operation">
					<xsl:attribute name="type">insert</xsl:attribute>
				</xsl:element>
				<xsl:element name="category">
					<xsl:attribute name="scheme">http://schemas.google.com/g/2005#kind</xsl:attribute>
					<xsl:attribute name="term">http://schemas.google.com/g/2005#event</xsl:attribute>
				</xsl:element>
				<xsl:call-template name="event">
					<xsl:with-param name="dateDebutB1" select="$debutSession"/>
					<xsl:with-param name="dateDebutB2" select="$debutSessionB2"/>
					<xsl:with-param name="dateFin" select="$debutRelache"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="jour">
		<xsl:choose>
			<xsl:when test="moment/@jour=1">MO</xsl:when>
			<xsl:when test="moment/@jour=2">TU</xsl:when>
			<xsl:when test="moment/@jour=3">WE</xsl:when>
			<xsl:when test="moment/@jour=4">TH</xsl:when>
			<xsl:when test="moment/@jour=5">FR</xsl:when>
		</xsl:choose>	
	</xsl:template>
	
	<xsl:template name="interval">
		<xsl:choose>
			<xsl:when test="moment/@semaine = 'B1' or moment/@semaine = 'B2'">2</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="dateDebut">
	<xsl:variable name="duration">P<xsl:value-of select="moment/@jour"/>D</xsl:variable>
		<xsl:choose>
			<xsl:when test="moment/@semaine = 'B2'">
				<xsl:for-each select="str:tokenize(date:add($debutSessionB2,$duration),'-')">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="str:tokenize(date:add($debutSession,$duration),'-')">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="dateRetourRelache">
		<xsl:choose>
			<xsl:when test="moment/@semaine = 'B2'"><xsl:value-of select="$debutRelacheB2"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$debutRelache"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="debut">
		<xsl:call-template name="dateDebut"></xsl:call-template>
		<xsl:text>T</xsl:text>		<xsl:if test="str:tokenize(moment/@debut,':')[1] &lt; 10">0</xsl:if>
									<xsl:value-of select="str:tokenize(moment/@debut,':')[1]"/>
									<xsl:value-of select="str:tokenize(moment/@debut,':')[2]"/>
									<xsl:text>00</xsl:text>
	</xsl:template>
	
	<xsl:template name="heure">
		<xsl:param name="heure"/>
		
		<xsl:if test="str:tokenize($heure,':')[1] &lt; 10">0</xsl:if>
		<xsl:value-of select="str:tokenize($heure,':')[1]"/>
		<xsl:value-of select="str:tokenize($heure,':')[2]"/>
		<xsl:text>00</xsl:text>
	</xsl:template>
	
	<xsl:template name="date">
		<xsl:param name="date"/>
		<xsl:param name="jour"/>
		
		<xsl:variable name="duration">P<xsl:value-of select="$jour"/>D</xsl:variable>
		
		<xsl:for-each select="str:tokenize(date:add($date,$duration),'-')">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="dateHeure">
		<xsl:param name="date"/>
		<xsl:param name="jour"/>
		<xsl:param name="heure"/>
		
		<xsl:call-template name="date">
			<xsl:with-param name="date" select="$date"/>
			<xsl:with-param name="jour" select="$jour"/>
		</xsl:call-template>
		<xsl:text>T</xsl:text>
		<xsl:call-template name="heure">
			<xsl:with-param name="heure" select="$heure"/>
		</xsl:call-template>
		<xsl:text>Z</xsl:text>
	</xsl:template>
	
	<xsl:template name="fin">
		<xsl:call-template name="dateDebut"></xsl:call-template>
		<xsl:text>T</xsl:text>		<xsl:if test="str:tokenize(moment/@fin,':')[1] &lt; 10">0</xsl:if>
									<xsl:value-of select="str:tokenize(moment/@fin,':')[1]"/>
									<xsl:value-of select="str:tokenize(moment/@fin,':')[2]"/>
									<xsl:text>00</xsl:text>
	</xsl:template>
	
	<xsl:template name="event">
	<xsl:param name="dateDebutB1"/>
	<xsl:param name="dateDebutB2"/>
	<xsl:param name="dateFin"/>
	
	<xsl:variable name="sigle" select="./sigle"/>
	<xsl:variable name="duration">P<xsl:value-of select="moment/@jour"/>D</xsl:variable>
	<xsl:variable name="dateDebut">
		<xsl:choose>
			<xsl:when test="moment/@semaine = 'B2'">
				<xsl:value-of select="$dateDebutB2"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dateDebutB1"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:variable>
	
		<title><xsl:value-of select="$sigle"/><xsl:if test="@type != 'cours'"> [Lab]</xsl:if></title>
		<content>
			<xsl:value-of select="//cour[@sigle = $sigle]/nom"/>	
			- <xsl:text>Professeur	 	: </xsl:text><xsl:value-of select="//cour[@sigle = $sigle]/prof"/>
			- <xsl:text>Groupe cour	 	: </xsl:text><xsl:value-of select="//cour[@sigle = $sigle]/groupeTheorie"/>
			- <xsl:text>Groupe lab	 	: </xsl:text><xsl:value-of select="//cour[@sigle = $sigle]/groupeLaboratoire"/>
		</content>
		<xsl:element name="gd:transparency">
			<xsl:attribute name="value">http://schemas.google.com/g/2005#event.opaque</xsl:attribute>
		</xsl:element>
		<xsl:element name="gd:eventStatus">
			<xsl:attribute name="value">http://schemas.google.com/g/2005#event.confirmed</xsl:attribute>
		</xsl:element>		
		<xsl:element name="gd:where">
			<xsl:attribute name="valueString">
				<xsl:value-of select="./local"/>
			</xsl:attribute>
		</xsl:element>
		<xsl:element name="gd:recurrence">
				<xsl:text>
DTSTART;TZID=America/Montreal:</xsl:text>
					<xsl:call-template name="dateHeure">
						<xsl:with-param name="date" select="$dateDebut"/>
						<xsl:with-param name="jour" select="moment/@jour"/>
						<xsl:with-param name="heure" select="moment/@debut"/>
					</xsl:call-template>
				<xsl:text>
DTEND;TZID=America/Montreal:</xsl:text>
					<xsl:call-template name="dateHeure">
						<xsl:with-param name="date" select="$dateDebut"/>
						<xsl:with-param name="jour" select="moment/@jour"/>
						<xsl:with-param name="heure" select="moment/@fin"/>
					</xsl:call-template>
				<xsl:text>
RRULE:FREQ=WEEKLY;INTERVAL=</xsl:text>
					<xsl:call-template name="interval"/>
				<xsl:text>;BYDAY=</xsl:text>		<xsl:call-template name="jour"/>
				<xsl:text>;UNTIL=</xsl:text>		
				<xsl:call-template name="dateHeure">
						<xsl:with-param name="date" select="$dateFin"/>
						<xsl:with-param name="jour">0</xsl:with-param>
						<xsl:with-param name="heure">23:59:00</xsl:with-param>
					</xsl:call-template>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:str="http://exslt.org/strings"
xmlns:date="http://exslt.org/dates-and-times"
exclude-result-prefixes="str date"	>
<xsl:param name="debutB1"/>
<xsl:param name="debutB2"/>
<xsl:param name="fin"/>

	<xsl:template match="/poly">
		<xsl:if test="$debutB1 = ''">
			<xsl:message terminate="no">Manque la date pour le debut de la periode B1 (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		<xsl:if test="$debutB2 = ''">
			<xsl:message terminate="no">Manque la date pour le debut de la periode B2 (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		<xsl:if test="$fin = ''">
			<xsl:message terminate="no">Manque la date pour la fin de la periode (format 'YYYYMMJJ')</xsl:message>
		</xsl:if>
		
		<xsl:element name="events">
			<xsl:for-each select="horaire/evenement">
				<xsl:element name="event">
					<xsl:call-template name="event">
						<xsl:with-param name="dateDebutB1" select="$debutB1"/>
						<xsl:with-param name="dateDebutB2" select="$debutB2"/>
						<xsl:with-param name="dateFin" select="$fin"/>
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
				<xsl:for-each select="str:tokenize(date:add($debutB2,$duration),'-')">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="str:tokenize(date:add($debutB1,$duration),'-')">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</xsl:otherwise>
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
		
		<xsl:value-of select="date:format-date(date:add($date,$duration),'YYYY-MM-DD')"/>
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
	
		<summary>
			<xsl:value-of select="$sigle"/>
			<xsl:choose>
				<xsl:when test="@type != 'cours'">
					<xsl:text> (</xsl:text>
					<xsl:value-of select="//cour[@sigle = $sigle]/groupeLaboratoire"/>
					<xsl:text>)</xsl:text>
					<xsl:text> [Lab]</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="//cour[@sigle = $sigle]/groupeTheorie"/>
					<xsl:text>)</xsl:text>
				</xsl:otherwise>
			
			</xsl:choose>
		</summary>
		<description>
			<xsl:value-of select="//cour[@sigle = $sigle]/nom"/>	
			- <xsl:text>Professeur	 	: </xsl:text><xsl:value-of select="//cour[@sigle = $sigle]/prof"/>
			- <xsl:text>Groupe cour	 	: </xsl:text><xsl:value-of select="//cour[@sigle = $sigle]/groupeTheorie"/>
			- <xsl:text>Groupe lab	 	: </xsl:text><xsl:value-of select="//cour[@sigle = $sigle]/groupeLaboratoire"/>
		</description>	
		<location>
			<xsl:value-of select="./local"/>
		</location>
		<recurrence>
				<xsl:text>DTSTART;TZID=America/Montreal:</xsl:text>
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
		</recurrence>
	</xsl:template>
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:str="http://exslt.org/strings" 
xmlns:exslt="http://exslt.org/common"
xmlns:fn="http://www.w3.org/2005/xpath-functions"
exclude-result-prefixes="str fn exslt">


	<!-- Pour la transformation d'identidees -->
	<xsl:template>
		<xsl:call-template name="IdentityTransform"/>
	</xsl:template>
	
	<xsl:template name="IdentityTransform">
		<xsl:copy>
	   		<xsl:apply-templates select="@*|node()"/>
	   	</xsl:copy>
	</xsl:template>
   
   	<xsl:template match="/">
   	<poly>
   		<informations>
			<xsl:for-each select="html/body/center/table[2]/tr/td/table/tr[position() &gt; 1 and position() &lt; last()]">
				<xsl:element name="cour">
					<xsl:attribute name="sigle"><xsl:value-of select="normalize-space(td)"/></xsl:attribute>
				 	<nom><xsl:value-of select="normalize-space(td[2]/node())"/></nom>
					<prof><xsl:value-of select="normalize-space(td[2]/node()[last()])"/></prof>
					<groupeTheorie><xsl:value-of select="normalize-space(td[3])"/></groupeTheorie>
					<groupeLaboratoire><xsl:value-of select="normalize-space(td[4])"/></groupeLaboratoire>
					<nombreCredits><xsl:value-of select="normalize-space(td[5])"/></nombreCredits>
				</xsl:element>
			</xsl:for-each>
		</informations>
   		<horaire>
	   		<xsl:call-template name="tJournee">		<xsl:with-param name="numero" select="1"/> 		</xsl:call-template>
	   		<xsl:call-template name="tJournee">		<xsl:with-param name="numero" select="2"/> 		</xsl:call-template>
	   		<xsl:call-template name="tJournee">		<xsl:with-param name="numero" select="3"/> 		</xsl:call-template>
	   		<xsl:call-template name="tJournee">		<xsl:with-param name="numero" select="4"/> 		</xsl:call-template>
	   		<xsl:call-template name="tJournee">		<xsl:with-param name="numero" select="5"/> 		</xsl:call-template>
   		</horaire>
   	</poly>
	</xsl:template>
	
	<xsl:template name="tJournee">
	<xsl:param name="numero"/>
	
		<xsl:variable name="journee">
	 		<xsl:for-each select="html/body/center/table[3]/tr/td/table/tr/td[position() = ($numero + 1)]">
				<xsl:choose>
					<xsl:when test="./font">
						<xsl:element name="periode">
							<xsl:attribute name="heure">
								<xsl:value-of select="substring-before(string(../td[position()=1]),'h') + 0"/>
								<xsl:text>:</xsl:text>
								<xsl:value-of select="substring-after(string(../td[position()=1]),'h') + 0"/>
							</xsl:attribute>
							
				 			<xsl:for-each select="font/node()">
					 			<xsl:choose>
					 				<xsl:when test="contains(string(.), 'Lab')">
					 					<infoSemaine><xsl:call-template name="IdentityTransform"/></infoSemaine>
					 				</xsl:when>		 			
					 				<xsl:when test="contains(string(.), '(')">
										<infoCour><xsl:call-template name="IdentityTransform"/></infoCour>	 				
					 				</xsl:when>
					 			</xsl:choose>
				 			</xsl:for-each>
						</xsl:element>
					</xsl:when>
				
					<xsl:otherwise>
						<xsl:element name="periode">
							<xsl:attribute name="heure">
								<xsl:value-of select="substring-before(string(../td[position()=1]),'h') + 0"/>
								<xsl:text>:</xsl:text>
								<xsl:value-of select="substring-after(string(../td[position()=1]),'h') + 0"/>
							</xsl:attribute>
							
				 			<xsl:for-each select="node()">
					 			<xsl:choose>
					 				<xsl:when test="contains(string(.), 'Lab')">
					 					<infoSemaine><xsl:call-template name="IdentityTransform"/></infoSemaine>
					 				</xsl:when>		 			
					 				<xsl:when test="contains(string(.), '(')">
										<infoCour><xsl:call-template name="IdentityTransform"/></infoCour>	 				
					 				</xsl:when>
					 			</xsl:choose>
				 			</xsl:for-each>
						</xsl:element>
					
					</xsl:otherwise>
				</xsl:choose>
				
				
	 		</xsl:for-each>	 
	 	</xsl:variable>
	 	
	 	<xsl:variable name="heures">
		 	<xsl:for-each select="exslt:node-set($journee)">
		 		<xsl:for-each select="periode">	
		 			<xsl:variable name="listeCoursPrecedents">
			 			<xsl:for-each select="preceding-sibling::periode[1]/infoCour">
							<xsl:value-of select="."/>
					 	</xsl:for-each>
				 	</xsl:variable>
				 	<xsl:for-each select="./infoCour">
				 		<xsl:choose>
				 			<xsl:when test="not(contains(string($listeCoursPrecedents),string(.)))">
								<xsl:element name="debut">
									
										<xsl:choose>
											<xsl:when test="following-sibling::*[1 and name()='infoSemaine']">
												<xsl:attribute name="type">lab</xsl:attribute>
												<xsl:attribute name="semaine">
													<xsl:choose>
														<xsl:when test="contains(string(following-sibling::*[1 and name()='infoSemaine']),'B1')">B1</xsl:when>
														<xsl:when test="contains(string(following-sibling::*[1 and name()='infoSemaine']),'B2')">B2</xsl:when>
													</xsl:choose>
												</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="type">cours</xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									
					 				<xsl:attribute name="cour"><xsl:value-of select="str:tokenize(.)"/></xsl:attribute>
					 				<xsl:attribute name="groupe"><xsl:value-of select="substring(string(str:tokenize(string(.))[2]),2,2)"/></xsl:attribute>
					 				<xsl:attribute name="local"><xsl:value-of select="str:tokenize(.)[3]"/></xsl:attribute>
						 			<xsl:attribute name="heure"><xsl:value-of select="../@heure"/></xsl:attribute>
					 			</xsl:element>
							</xsl:when>
				 		</xsl:choose>
		 			</xsl:for-each>
		 			
		 			<xsl:variable name="listeCoursSuivants">
			 			<xsl:for-each select="following-sibling::periode[1]/infoCour">
							<xsl:value-of select="."/>
					 	</xsl:for-each>
				 	</xsl:variable>
		 				
	 				<xsl:for-each select="./infoCour">
			 			<xsl:choose>
				 			<xsl:when test="not(contains(string($listeCoursSuivants),string(.)))">
				 			<xsl:element name="fin">
				 				<xsl:attribute name="cour"><xsl:value-of select="str:tokenize(.)"/></xsl:attribute>
				 				<xsl:attribute name="groupe"><xsl:value-of select="substring(string(str:tokenize(string(.))[2]),2,2)"/></xsl:attribute>
				 				<xsl:attribute name="local"><xsl:value-of select="str:tokenize(.)[3]"/></xsl:attribute>
				 				<xsl:attribute name="heure">
				 					<xsl:value-of select="substring-before(string(../@heure),':') + 1"/>
									<xsl:text>:</xsl:text>
									<xsl:value-of select="substring-after(string(../@heure),':') + 0"/>
								</xsl:attribute>
								
				 			</xsl:element>
				 			</xsl:when>
				 		</xsl:choose>
		 			</xsl:for-each>
		 		
		 		</xsl:for-each>
		 	</xsl:for-each>
	 	</xsl:variable>
	 	
	 	
	 	<xsl:for-each select="exslt:node-set($heures)">
	 		<xsl:for-each select="./debut">
	 			<evenement>
	 				<xsl:attribute name="type">
	 					<xsl:value-of select="@type"></xsl:value-of>
	 				</xsl:attribute>
	 				<moment>
		 				<xsl:attribute name="semaine">
		 					<xsl:value-of select="@semaine"/>
		 				</xsl:attribute>
		 				<xsl:attribute name="jour">
		 					<xsl:value-of select="$numero"/>
		 				</xsl:attribute>
		 				<xsl:attribute name="debut">
		 					<xsl:value-of select="@heure"/>
		 				</xsl:attribute>
		 				<xsl:attribute name="fin">
		 					<xsl:value-of select="following-sibling::fin[@cour = current()/@cour]/@heure"/>
		 				</xsl:attribute>
	 				</moment>
	 				<sigle>
	 					<xsl:value-of select="@cour"/>
	 				</sigle>
	 				<groupe>
	 					<xsl:value-of select="@groupe"/>	
	 				</groupe>
	 				<local>
	 					<xsl:value-of select="@local"/>
	 				</local>	 				
	 			</evenement>
	 		</xsl:for-each>
	 	</xsl:for-each>
	 	
	 </xsl:template>
	 
	 

</xsl:stylesheet>

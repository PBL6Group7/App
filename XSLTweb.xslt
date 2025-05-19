<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8"/>

<xsl:template match="/">
    <div class="header">
        <h1>PlasmoScan</h1>
        <p>Somos una empresa dedicada al diagnóstico visual de células infectadas por malaria mediante microscopía e inteligencia artificial.</p>
    </div>

    <div class="contenedor">
        <xsl:for-each select="pacientes/paciente">
            <div class="paciente">
                <h2><xsl:value-of select="nombre"/></h2>
                <p>Edad: <xsl:value-of select="edad"/></p>
                <p>Diagnóstico: <xsl:value-of select="diagnostico"/></p>
                <img>
                    <xsl:attribute name="src">
                        <xsl:value-of select="imagen"/>
                    </xsl:attribute>
                </img>
            </div>
        </xsl:for-each>
    </div>
</xsl:template>
</xsl:stylesheet>
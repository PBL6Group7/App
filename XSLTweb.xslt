<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 

  <xsl:output method="html" indent="yes"/>

  <xsl:template match="/"> 
    <html> 
      <head>
        <title>Resultados de diagnóstico</title>
      </head>
      <body> 
        <h2>Resultados de diagnóstico</h2> 
        <table border="1"> 
          <tr> 
             <th>ID</th>
			<th>Nombre</th> 
            <th>Apellido</th> 
            <th>Edad</th>
            <th>Sexo</th>
            <th>Foto</th>
          </tr> 
          <xsl:for-each select="Pacientes/Paciente"> 
            <tr> 
			  <td><xsl:value-of select="ID"/></td> 
              <td><xsl:value-of select="Nombre"/></td> 
              <td><xsl:value-of select="Apellido"/></td> 
              <td><xsl:value-of select="Edad"/></td>
              <td><xsl:value-of select="Sexo"/></td>
              <td>
                <img>
                  <xsl:attribute name="src">
                    <xsl:value-of select="Foto"/>
                  </xsl:attribute>
                  <xsl:attribute name="alt">
                    <xsl:value-of select="Nombre"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    width:120px; border:1px solid black;
                  </xsl:attribute>
                </img>
              </td>
            </tr> 
          </xsl:for-each> 
        </table> 
      </body> 
    </html>
  </xsl:template>
</xsl:stylesheet>
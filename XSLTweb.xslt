<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
  <xsl:template match="/"> 
    <html> 
      <head>
		<link rel="stylesheet" type="text/css" href="CSSweb.css"/>
      </head>
      <body> 
        <h2>Pacientes registrados</h2>	
        <table border="1"> 
          <tr> 
            <th>ID</th>
			<th>Nombre</th> 
            <th>Apellido</th> 
            <th>Edad</th>
            <th>Sexo</th>
          </tr> 
          <xsl:for-each select="Pacientes/Paciente"> 
		  
            <tr> 
			  <td><xsl:value-of select="ID"/></td> 
              <td><xsl:value-of select="Nombre"/></td> 
              <td><xsl:value-of select="Apellido"/></td> 
              <td><xsl:value-of select="Edad"/></td>
              <td><xsl:value-of select="Sexo"/></td>
            </tr> 
          </xsl:for-each> 
        </table> 
		<h2>Historial de diagnóstico</h2>
		<table border="1"> 
          <tr> 
            <th>ID</th>
			<th>Fecha</th> 
            <th>Resultado</th> 
            <th>Especie</th>
			<th>Foto</th>
          </tr> 
          <xsl:for-each select="Pacientes/Paciente"> 
		  <xsl:variable name="idPaciente" select="ID"/>
		   <xsl:for-each select="Historial/Entrada">
            <tr> 
			  <td><xsl:value-of select="$idPaciente"/></td> 
              <td><xsl:value-of select="Fecha"/></td> 
              <td><xsl:value-of select="Resultado"/></td> 
              <td><xsl:value-of select="Especie"/></td>
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
		  </xsl:for-each> 
        </table> 
      </body> 
    </html>
  </xsl:template>
</xsl:stylesheet>
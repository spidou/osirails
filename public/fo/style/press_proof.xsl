<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:strip-space elements="*"/>

  <xsl:template match="Document">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" 
             font-selection-strategy="character-by-character" 
             line-height-shift-adjustment="disregard-shifts" 
             font-family="sans-serif" 
             font-size="11pt" 
             language="fr">
             
      <fo:layout-master-set>
        
        <fo:simple-page-master master-name="only"
                               page-height="210mm"
                               page-width="297mm"
                               margin-top="0cm"
                               margin-bottom="0cm"
                               margin-left="0m"
                               margin-right="0cm">                
          <fo:region-body margin-top="2.7cm" margin-bottom="0.1cm" margin-left="0.1cm" margin-right="0.1cm"/>
          <fo:region-before extent="2.6cm" overflow="hidden"/>
          <fo:region-after extent="2.7cm"/>
        </fo:simple-page-master>
        
        <fo:simple-page-master master-name="first"
                               page-height="210mm"
                               page-width="297mm"
                               margin-top="0cm"
                               margin-bottom="0cm"
                               margin-left="0cm"
                               margin-right="0cm">
          <fo:region-body margin-top="2.7cm" margin-bottom="0.1cm" margin-left="0.1cm" margin-right="0.1cm"/>
          <fo:region-before extent="2.6cm" overflow="hidden"/>
          <fo:region-after extent="0.6cm"/>
        </fo:simple-page-master>
        
        <fo:simple-page-master master-name="others"
                               page-height="210mm"
                               page-width="297mm"
                               margin-top="0m"
                               margin-bottom="0cm"
                               margin-left="0cm"
                               margin-right="0cm">
          <fo:region-body margin-top="2.1cm" margin-bottom="0.1cm" margin-left="0.1cm" margin-right="0.1cm"/>
          <fo:region-before extent="2cm" overflow="hidden"/>
          <fo:region-after extent="0.6cm"/>
        </fo:simple-page-master>
        
        <fo:simple-page-master master-name="last"
                               page-height="210mm"
                               page-width="297mm"
                               margin-top="0cm"
                               margin-bottom="0cm"
                               margin-left="0cm"
                               margin-right="0cm">
          <fo:region-body margin-top="2.1cm" margin-bottom="0.1cm" margin-left="0.1cm" margin-right="0.1cm"/>
          <fo:region-before extent="2cm" overflow="hidden"/>
          <fo:region-after extent="2.7cm"/>
        </fo:simple-page-master>
        
        <fo:page-sequence-master master-name="unnamed">     
      
          <fo:repeatable-page-master-alternatives>
            <fo:conditional-page-master-reference page-position="only" master-reference="only"/>
            <fo:conditional-page-master-reference page-position="first" master-reference="first"/>         
            <fo:conditional-page-master-reference page-position="last" master-reference="last"/>     
            <fo:conditional-page-master-reference page-position="rest" master-reference="others"/>
          </fo:repeatable-page-master-alternatives>
          
        </fo:page-sequence-master>    
        
      </fo:layout-master-set>
      
      <fo:page-sequence format="1" master-reference="unnamed" initial-page-number="1">
        
        <fo:static-content flow-name="xsl-region-before">
          <fo:table>
            <fo:table-body>
              <fo:table-row background-color="rgb(0,0,0)" page-break-inside="avoid">
                <fo:table-cell width="5.7cm" display-align="center">
                  <fo:block-container height="2cm">
                    <fo:block text-align="center">
                      <fo:external-graphic content-height="2cm">
                        <xsl:attribute name="src">
                          <xsl:value-of select="Supplier/LogoPath"/>
                        </xsl:attribute>
                      </fo:external-graphic>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell width="9cm" display-align="center" text-align="center">
                  <fo:block-container overflow="hidden" height="2cm">
                    <fo:block-container overflow="hidden" height="1cm">
                      <fo:block wrap-option="no-wrap" padding-top="0.3cm" font-weight="bold" font-size="18px" color="rgb(255,255,255)">
                        <xsl:value-of select="Type"/>
                      </fo:block>
                    </fo:block-container>
                    <fo:block-container overflow="hidden" height="1cm">
                      <fo:block wrap-option="no-wrap" padding-bottom="0.2cm" font-weight="bold" font-size="18px" color="rgb(255,255,255)">
                        <xsl:value-of select="Reference"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell width="15cm" display-align="center">
                  <fo:block-container height="2cm">
                    <fo:table>
                      <fo:table-body>
                        <fo:table-row>
                          <fo:table-cell padding-left="0.1cm" width="3cm">
                            <fo:block-container overflow="hidden" height="0.6cm">
                              <fo:block wrap-option="no-wrap" font-weight="bold" font-size="12px" color="rgb(255,255,255)">
                                <xsl:value-of select="../Labels/CustomerName"/>
                              </fo:block>&#160;
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding-left="0.1cm" width="7cm">
                            <fo:block-container overflow="hidden" height="0.6cm">
                              <fo:block font-size="10px" color="rgb(255,255,255)">
                                <xsl:value-of select="CustomerName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding-right="0.1cm" width="5cm">
                            <fo:block-container overflow="hidden" height="0.6cm">
                              <fo:block color="rgb(255,255,255)" text-align="right" margin-right="0.1cm">
                                <fo:inline font-weight="bold" font-size="12px">
                                  <xsl:value-of select="../Labels/Date"/>
                                </fo:inline>&#160;
                                <fo:inline font-size="10px">
                                  <xsl:value-of select="Date"/>
                                </fo:inline>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                          <fo:table-cell padding-left="0.1cm" width="3cm">
                            <fo:block-container overflow="hidden" height="0.6cm">
                              <fo:block wrap-option="no-wrap" font-weight="bold" font-size="12px" color="rgb(255,255,255)">
                                <xsl:value-of select="../Labels/FileName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding-left="0.1cm" width="12cm">
                            <fo:block-container overflow="hidden" height="0.6cm">
                              <fo:block wrap-option="no-wrap" font-size="10px" color="rgb(255,255,255)" text-align="left">
                                <xsl:value-of select="FileName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                          <fo:table-cell padding-left="0.1cm" width="3cm">
                            <fo:block-container overflow="hidden" height="0.6cm">
                              <fo:block wrap-option="no-wrap" font-weight="bold" font-size="12px" color="rgb(255,255,255)">
                                <xsl:value-of select="../Labels/QuoteReference"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding-left="0.1cm" width="12cm">
                            <fo:block-container overflow="hidden" height="0.6cm">
                              <fo:block wrap-option="no-wrap" font-size="10px" color="rgb(255,255,255)" text-align="left">
                                <xsl:value-of select="QuoteReference"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-body>
                    </fo:table>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
          <fo:table>
            <fo:table-body>
              <fo:table-row background-color="rgb(255,149,14)">
                <fo:table-cell padding="0.1cm" width="14.7cm" display-align="center" text-align="left">  
                  <fo:block-container height="0.5cm">
                    <fo:block margin-left="0.1cm">
                      <fo:inline font-weight="bold" font-size="10px" color="rgb(0,0,0)">
                        <xsl:value-of select="../Labels/ProductName"/>
                      </fo:inline>&#160;
                      <fo:inline font-size="9px" color="rgb(0,0,0)">
                        <xsl:value-of select="ProductName"/>
                      </fo:inline>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell padding="0.1cm" width="15cm" display-align="center" text-align="left">
                  <fo:block-container height="0.5cm">
                    <fo:block> 
                      <fo:inline font-weight="bold" font-size="10px" color="rgb(0,0,0)">
                        <xsl:value-of select="../Labels/SupplierRepresentative"/>
                      </fo:inline>&#160;
                      <fo:inline font-size="9px" color="rgb(0,0,0)">
                        <xsl:value-of select="Supplier/Representative/Email"/>
                      </fo:inline>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:static-content>
        
        <fo:static-content flow-name="xsl-region-after">
          <fo:table>
            <fo:table-body>
              <fo:table-row>
                <fo:table-cell padding="0.1cm"  width="15cm">
                  <fo:block text-align="left" font-weight="bold">
                    <xsl:value-of select="../Labels/MockupUnitMeasure"/>&#160;<fo:retrieve-marker retrieve-class-name="unitmeasure" retrieve-boundary="page" retrieve-position="last-starting-within-page"/>
                  </fo:block>
                </fo:table-cell>
                <fo:table-cell width="14.5cm">
                  <fo:block padding="0.1cm" text-align="right" font-weight="bold">
                    <xsl:value-of select="../Labels/Page"/>&#160;<fo:page-number/>/<fo:page-number-citation ref-id="last-page"/>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
          <fo:table>
            <fo:table-body>
              <fo:table-row height="2cm" background-color="rgb(255,255,255)">
                <fo:table-cell display-align="center" width="10.2cm" text-align="left" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                  <fo:block-container overflow="hidden" height="2cm">
                    <fo:block font-size="9px">
                      <xsl:value-of select="../Labels/NotaBene"/><fo:inline><fo:block/></fo:inline>
                      <xsl:value-of select="../Labels/NotaBene2"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell width="7cm" display-align="before" text-align="center" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                  <fo:block-container height="2cm">
                    <fo:block padding-top="0.1cm" font-weight="bold" font-size="9px">
                      <xsl:value-of select="../Labels/Agreement"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell width="7cm" display-align="before" text-align="center" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                  <fo:block-container height="2cm">
                    <fo:block padding-top="0.1cm" font-weight="bold" font-size="9px">
                      <xsl:value-of select="../Labels/Agreement2"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell height="1.8cm" width="5.5cm" display-align="center" text-align="center" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px">
                  <fo:block-container height="2cm">
                    <fo:block font-size="9px">
                      <fo:inline text-align="left" font-weight="bold">
                        <xsl:value-of select="../Labels/Email"/>
                      </fo:inline>&#160;                      <fo:inline text-align="left">
                         <xsl:value-of select="Supplier/Email"/>
                      </fo:inline>
                    </fo:block>
                    <fo:block font-size="9px">
                      <fo:inline text-align="left" font-weight="bold">
                        <xsl:value-of select="../Labels/Phone"/>
                      </fo:inline>&#160;                      <fo:inline text-align="left">
                         <xsl:value-of select="Supplier/Phone"/>
                      </fo:inline>
                    </fo:block>
                    <fo:block font-size="9px">
                      <fo:inline text-align="left" font-weight="bold">
                        <xsl:value-of select="../Labels/Fax"/>
                      </fo:inline>&#160;                      <fo:inline text-align="left">
                         <xsl:value-of select="Supplier/Fax"/>
                      </fo:inline>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:static-content>
                  
        <fo:flow flow-name="xsl-region-body">
          <xsl:apply-templates select="Mockups/Mockup"/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>

  <xsl:template match="Mockups/Mockup">
    <fo:block break-after="page">
      <fo:marker marker-class-name="unitmeasure">
        <xsl:value-of select="UnitMeasure"/>
      </fo:marker>
      <fo:marker marker-class-name="order">
        <xsl:value-of select="Reference"/>
      </fo:marker>
      <fo:table>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell padding="0.1cm" width="15cm">
              <fo:block text-align="left" font-weight="bold">
                <xsl:value-of select="../../../Labels/MockupReference"/>&#160;<xsl:value-of select="Reference"/>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell padding="0.1cm" width="14.5cm">
              <fo:block text-align="right" font-weight="bold">
                <xsl:value-of select="Type"/>
              </fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
      <fo:table>
        <fo:table-body>
          <fo:table-row>
            <xsl:attribute name="height">
              <xsl:choose>
                <xsl:when test="position()=last()">
                  15cm
                </xsl:when>
                <xsl:otherwise>
                  16.5cm
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <fo:table-cell display-align="center" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
              <fo:block text-align="center">
                <fo:external-graphic>
                  <xsl:choose>
                    <xsl:when test="OriginalHeight &gt; OriginalWidth and (((OriginalHeight &lt; 14.8 and position()=last()) or (OriginalHeight &lt; 16.3 and position()!=last())) and OriginalWidth &lt; 29) ">
                      <xsl:attribute name="src">
                        <xsl:value-of select="OriginalPath"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:choose>
                        <xsl:when test="(Height &gt; 14.8 and position()=last()) or (Height &gt; 16.3 and position()!=last()) or Width &gt; 29">
                          <xsl:attribute name="content-height">
                            <xsl:choose>
                              <xsl:when test="position()=last()">
                                14.8cm
                              </xsl:when>
                              <xsl:otherwise>
                                16.3cm
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:attribute>
                          <xsl:attribute name="content-width">
                            29cm
                          </xsl:attribute>
                        </xsl:when>
                      </xsl:choose>
                      <xsl:attribute name="src">
                        <xsl:value-of select="Path"/>
                      </xsl:attribute>
                    </xsl:otherwise>                   
                  </xsl:choose>
                </fo:external-graphic>
              </fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
      <xsl:choose>
        <xsl:when test="position()=last()">
          <fo:block id="last-page"/>
        </xsl:when>
    </xsl:choose>
    </fo:block>    
  </xsl:template>
</xsl:stylesheet>

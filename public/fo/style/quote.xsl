<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:strip-space elements="*"/>
  <xsl:template match="Document">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" font-selection-strategy="character-by-character" line-height-shift-adjustment="disregard-shifts" font-family="sans-serif" font-size="11pt" language="fr">     
      <fo:layout-master-set>
        <fo:simple-page-master master-name="only"
                               page-height="297mm"
                               page-width="210mm"
                               margin-top="0cm"
                               margin-bottom="0cm"
                               margin-left="0m"
                               margin-right="0cm">                
          <fo:region-body margin-top="2.5cm" margin-bottom="1.6cm" margin-left="0.5cm" margin-right="0.5cm"/>
          <fo:region-before/>
          <fo:region-after extent="2.1cm"/>
        </fo:simple-page-master>        
        <fo:simple-page-master master-name="first"
                               page-height="297mm"
                               page-width="210mm"
                               margin-top="0cm"
                               margin-bottom="0cm"
                               margin-left="0cm"
                               margin-right="0cm">
          <fo:region-body margin-top="2.5cm" margin-bottom="2.1cm" margin-left="0.5cm" margin-right="0.5cm"/>
          <fo:region-before/>
          <fo:region-after extent="2.1cm"/>
        </fo:simple-page-master>        
        <fo:simple-page-master master-name="others"
                               page-height="297mm"
                               page-width="210mm"
                               margin-top="0m"
                               margin-bottom="0cm"
                               margin-left="0cm"
                               margin-right="0cm">
          <fo:region-body margin-top="2.5cm" margin-bottom="2.1cm" margin-left="0.5cm" margin-right="0.5cm"/>
          <fo:region-before/>
          <fo:region-after extent="2.1cm"/>
        </fo:simple-page-master>        
        <fo:simple-page-master master-name="last"
                               page-height="297mm"
                               page-width="210mm"
                               margin-top="0cm"
                               margin-bottom="0cm"
                               margin-left="0cm"
                               margin-right="0cm">
          <fo:region-body margin-top="2.5cm" margin-bottom="2.1cm" margin-left="0.5cm" margin-right="0.5cm"/>
          <fo:region-before/>
          <fo:region-after extent="2.1cm"/>
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
                <fo:table-cell width="5.5cm" display-align="center">
                  <fo:block-container height="2cm" overflow="hidden">
                    <fo:block text-align="center">
                      <fo:external-graphic content-width="5.5cm" content-height="2cm" id="header">
                        <xsl:attribute name="src">
                          <xsl:value-of select="Supplier/LogoPath"/>
                        </xsl:attribute>
                      </fo:external-graphic>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell width="5cm" display-align="center" text-align="center">
                  <fo:block-container height="2cm" overflow="hidden">
                    <fo:block font-size="10px" color="rgb(255,255,255)">
                      <fo:inline>
                        <xsl:value-of select="Supplier/Address1"/>
                      </fo:inline>&#160;
                      <fo:inline>
                        <xsl:value-of select="Supplier/Address2"/>
                      </fo:inline>
                    </fo:block>
                    <fo:block font-size="10px" color="rgb(255,255,255)">
                      <fo:inline>
                        <xsl:value-of select="Supplier/ZipCode"/>
                      </fo:inline>&#160;
                      <fo:inline>
                        <xsl:value-of select="Supplier/City"/>
                      </fo:inline>
                    </fo:block>
                    <fo:block font-size="10px" color="rgb(255,255,255)">
                      <fo:inline>
                        <xsl:value-of select="Supplier/Country"/>
                      </fo:inline>                    
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell width="5cm" display-align="center" text-align="center">
                  <fo:block-container height="2cm" overflow="hidden">
                    <fo:block font-size="20px" color="rgb(255,255,255)">
                      <xsl:value-of select="Type"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell width="5.5cm" display-align="center" text-align="center">
                  <fo:block-container height="2cm" overflow="hidden">
                    <fo:block font-size="9px" color="rgb(255,255,255)">
                      <fo:inline>
                        <xsl:value-of select="../Labels/Email"/>
                      </fo:inline>&#160;
                      <fo:inline>
                        <xsl:value-of select="Supplier/Email"/>
                      </fo:inline>
                    </fo:block>
                    <fo:block font-size="9px" color="rgb(255,255,255)">
                      <fo:inline>
                        <xsl:value-of select="../Labels/Phone"/>
                      </fo:inline>&#160;
                      <fo:inline>
                        <xsl:value-of select="Supplier/Phone"/>
                      </fo:inline>
                    </fo:block>
                    <fo:block font-size="9px" color="rgb(255,255,255)">
                      <fo:inline>
                        <xsl:value-of select="../Labels/Fax"/>
                      </fo:inline>   
                      <fo:inline>
                        <xsl:value-of select="Supplier/Fax"/>
                      </fo:inline>                 
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>          
          <fo:table>
            <fo:table-body>
              <fo:table-row background-color="rgb(255,149,14)" page-break-inside="avoid">
                <fo:table-cell width="21cm">
                  <fo:block-container height="0.3cm" overflow="hidden" wrap-option="no-wrap">
                    <fo:block font-size="7px" text-align="center" font-style="italic">
                      <xsl:value-of select="Supplier/Status"/>,&#160;<xsl:value-of select="../Labels/Siret"/>&#160;<xsl:value-of select="Supplier/Siret"/>/<xsl:value-of select="../Labels/NAFCode"/>&#160;<xsl:value-of select="Supplier/NAFCode"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:static-content>              
        <fo:static-content flow-name="xsl-region-after" margin-right="0.5cm" margin-left="0.5cm">
          <fo:table page-break-inside="avoid" border-collapse="collapse" font-size="9.0px">      
            <fo:table-body>
              <fo:table-row page-break-inside="avoid">
                <fo:table-cell number-rows-spanned="2">
                  <fo:block/>
                </fo:table-cell>
                <fo:table-cell number-rows-spanned="2" number-columns-spanned="8">
                  <fo:block text-align="center">
                    <fo:external-graphic content-height="1.5cm" src="url('../images/synafel.png')"/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
                    <fo:external-graphic content-height="1.5cm" src="url('../images/bvqi.png')"/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
                    <fo:external-graphic content-height="1.5cm" src="url('../images/qualifenseignes.png')"/>
                    <fo:block-container overflow="hidden" wrap-option="no-wrap">
                      <fo:block padding-top="1mm" font-size="7.0px" font-style="italic" text-align="center">
                        Membre du Synafel (syndicat des enseignistes européens) et certifié Qualif' enseigne signalétique par Bureau Veritas en 2004
                      </fo:block> 
                    </fo:block-container>
                  </fo:block>
                </fo:table-cell>
                <fo:table-cell display-align="after">
                  <fo:block-container wrap-option="no-wrap">
                    <fo:block text-align="end" font-size="8px" font-weight="bold" text-decoration="underline">
                      <fo:retrieve-marker retrieve-class-name="report-label" retrieve-boundary="page" retrieve-position="last-starting-within-page"/>&#160;<fo:retrieve-marker retrieve-class-name="report-value" retrieve-boundary="page" retrieve-position="last-starting-within-page"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
              <fo:table-row page-break-inside="avoid">                  
                <fo:table-cell display-align="center">
                  <fo:block-container wrap-option="no-wrap">
                    <fo:block text-align="end" font-size="9px">
                      <xsl:value-of select="../Labels/Page"/>&#160;<fo:page-number/>/<fo:page-number-citation ref-id="last-page"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>                                  
          </fo:table>
        </fo:static-content>                  
        <fo:flow flow-name="xsl-region-body">
          <fo:block background-repeat="no-repeat" background-position-horizontal="1.5cm" background-position-vertical="2.2cm">
            <xsl:attribute name="background-image">
              <xsl:value-of select="BackgroundImage"/>
            </xsl:attribute>
            <fo:block-container width="10.5cm" overflow="hidden" wrap-option="no-wrap">
              <fo:block font-weight="bold" font-size="24.0px">
                <xsl:value-of select="Type"/>&#160;<xsl:value-of select="../Labels/Prefix"/>&#160;<xsl:value-of select="Reference"/>
              </fo:block> 
            </fo:block-container>              
            <fo:table margin-bottom="1cm" page-break-inside="avoid" border-collapse="collapse">      
              <fo:table-body>
                <fo:table-row page-break-inside="avoid">
                  <fo:table-cell number-columns-spanned="5">
                    <fo:block-container font-size="10.0px" overflow="hidden" wrap-option="no-wrap">
                      <fo:block margin-bottom="3mm">
                        <fo:inline>
                          <xsl:value-of select="../Labels/Date"/>
                        </fo:inline>&#160;
                        <fo:inline>
                          <xsl:value-of select="Date"/>
                        </fo:inline>
                      </fo:block>
                      <fo:block font-weight="bold">
                        <xsl:value-of select="../Labels/SupplierPrefix"/>&#160;<xsl:value-of select="Supplier/CorporateName2"/>:
                      </fo:block>
                      <fo:block>
                        <xsl:value-of select="Supplier/Representative/FirstName"/>&#160;<xsl:value-of select="Supplier/Representative/LastName"/>, <xsl:value-of select="Supplier/Representative/Function"/>
                      </fo:block>       
                      <fo:block>
                        <fo:inline>
                          <xsl:value-of select="../Labels/Email"/>
                        </fo:inline>&#160;
                        <fo:inline>
                          <xsl:value-of select="Supplier/Representative/Email"/>
                        </fo:inline>
                      </fo:block>
                    </fo:block-container> 
                  </fo:table-cell>
                  <fo:table-cell padding-left="1cm" number-columns-spanned="5">
                    <fo:block-container width="8cm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block font-weight="bold">
                        <xsl:value-of select="Customer/CorporateName2"/>
                      </fo:block>
                      <fo:block>
                        <xsl:value-of select="../Labels/CustomerPrefix"/>&#160;<xsl:value-of select="Customer/Representative/FirstName"/>&#160;<xsl:value-of select="Customer/Representative/LastName"/>
                      </fo:block>
                      <fo:block>
                        <xsl:value-of select="Customer/Address1"/>&#160;<xsl:value-of select="Customer/Address2"/>
                      </fo:block>
                      <fo:block>
                        <xsl:value-of select="Customer/ZipCode"/>&#160;<xsl:value-of select="Customer/City"/>
                      </fo:block>
                      <fo:block>
                        <xsl:value-of select="Customer/Country"/>
                      </fo:block>
                    </fo:block-container>  
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>                
            </fo:table>              
            <fo:table display-align="after" margin-bottom="2pt" border="black" border-style="solid" border-width="1px">
              <fo:table-body>                          
                <fo:table-row keep-with-next="always" page-break-inside="avoid">
                  <fo:table-cell number-columns-spanned="10" padding="1pt" font-size="10.0px" background-color="rgb(255, 149 , 14)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" display-align="before">
                    <fo:block-container overflow="hidden" wrap-option="no-wrap">
                      <fo:block text-align="center" font-weight="bold">
                        <xsl:value-of select="../Labels/SalesTerms"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-row>
                <fo:table-row keep-with-next="always" page-break-inside="avoid">
                  <fo:table-cell number-columns-spanned="10" padding="1pt" font-size="8.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" display-align="before">
                    <fo:block-container height="0.4cm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block text-align="center">
                        <xsl:value-of select="SalesTerms/Description"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-row>
                <fo:table-row keep-with-next="always" font-size="8.0px" page-break-inside="avoid">
                  <fo:table-cell text-align="center" display-align="center" padding="1pt" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" number-columns-spanned="5">
                    <fo:block-container overflow="hidden" wrap-option="no-wrap">
                      <fo:block>  
                        <fo:inline text-align="center" font-weight="bold">
                         <xsl:value-of select="../Labels/QuoteValidity"/>
                        </fo:inline>&#160;
                        <fo:inline text-align="center">
                          <xsl:value-of select="SalesTerms/QuoteValidity"/>
                        </fo:inline>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell text-align="center" display-align="center" padding="1pt" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" number-columns-spanned="5">
                    <fo:block-container overflow="hidden" wrap-option="no-wrap">
                      <fo:block>  
                        <fo:inline text-align="center" font-weight="bold">
                         <xsl:value-of select="../Labels/Deposit"/>
                        </fo:inline>&#160;
                        <fo:inline text-align="center">
                          <xsl:value-of select="SalesTerms/Deposit"/>
                        </fo:inline>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>               
            <fo:table table-layout="fixed" border-collapse="collapse" font-size="9.0px">                
              <fo:table-column column-width="2.8cm"/>
              <fo:table-column column-width="2cm"/>
              <fo:table-column column-width="2cm"/>
              <fo:table-column column-width="2cm"/>
              <fo:table-column column-width="3.6cm"/>
              <fo:table-column column-width="1.4cm"/>
              <fo:table-column column-width="2.1cm"/>
              <fo:table-column column-width="1.2cm"/>
              <fo:table-column column-width="2.1cm"/>
              <fo:table-column column-width="8mm"/>                
              <fo:table-header>
                <fo:table-row page-break-inside="avoid">
                  <fo:table-cell number-columns-spanned="5">
                    <fo:block-container overflow="hidden" wrap-option="no-wrap">
                      <fo:block font-size="10.0px" font-weight="bold" text-align="left">
                        <fo:inline>
                          <xsl:value-of select="../Labels/FileName"/>
                        </fo:inline>&#160;
                        <fo:inline>
                          <xsl:value-of select="FileName"/>
                        </fo:inline>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell padding-left="0.1cm" number-columns-spanned="5">
                    <fo:block-container overflow="hidden" wrap-option="no-wrap">
                      <fo:block font-size="10.0px" font-weight="bold" font-style="italic" text-align="right">
                        <xsl:value-of select="../Labels/Amount"/>&#160;<xsl:value-of select="Currency"/>
                      </fo:block> 
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-row>
                <fo:table-row background-color="rgb(255, 149 , 14)" height="5mm" font-size="10.0px" page-break-inside="avoid">
                  <fo:table-cell border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-weight="bold" text-align="center" display-align="center">
                    <fo:block-container height="5mm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block>
                        <xsl:value-of select="../Labels/Reference"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-weight="bold" text-align="center" display-align="center" number-columns-spanned="4">
                    <fo:block-container height="5mm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block>
                        <xsl:value-of select="../Labels/Description"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-weight="bold" text-align="center" display-align="center">
                    <fo:block-container height="5mm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block>
                        <xsl:value-of select="../Labels/Quantity"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-weight="bold" text-align="center" display-align="center">
                    <fo:block-container height="5mm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block>
                        <xsl:value-of select="../Labels/UnitPrice"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-weight="bold" text-align="center" display-align="center">
                    <fo:block-container height="5mm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block>
                        <xsl:value-of select="../Labels/Prizegiving"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-weight="bold" text-align="center" display-align="center">
                    <fo:block-container height="5mm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block>
                        <xsl:value-of select="../Labels/TotalPrice"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-weight="bold" text-align="center" display-align="center">
                    <fo:block-container height="5mm" overflow="hidden" wrap-option="no-wrap">
                      <fo:block>
                        <xsl:value-of select="../Labels/VAT"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-header>               
<!-- FOOTER IS REQUIRED TO CLOSE THE TABLE ON PAGE BREAKS                  -->
              <fo:table-footer>
                <fo:table-cell id="footline" number-columns-spanned="10" border-top-color="black" border-top-style="solid" border-top-width="1.0px">
                  <fo:block/> 
                </fo:table-cell>
              </fo:table-footer>               
              <fo:table-body>                 
                <fo:table-row font-size="9.0px" >
                  <fo:table-cell>
                    <xsl:apply-templates select="Lines/Line"/>
                  </fo:table-cell>
                </fo:table-row>  
                <fo:table-row>
                  <fo:table-cell id="first-blank-cell" padding-top="0.1cm" number-columns-spanned="1" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell number-columns-spanned="4" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell number-columns-spanned="1" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell number-columns-spanned="1" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell number-columns-spanned="1" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell number-columns-spanned="1" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell number-columns-spanned="1" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
                    <fo:block/>
                  </fo:table-cell>
                </fo:table-row>                  
                <fo:table-row>
                  <fo:table-cell number-columns-spanned="10" padding="1pt" border-top-color="black" border-top-style="solid" border-top-width="1.0px">
                    <fo:block/>
                  </fo:table-cell>
                </fo:table-row>                  
                <fo:table-row keep-with-next="always">
                  <fo:table-cell padding-bottom="5mm" padding-right="2pt" number-columns-spanned="3">                    
                    <fo:table id="address-and-agreement-table" display-align="after" font-size="9.0px" border-color="black" border-width="1px" border-style="solid">
                      <fo:table-body>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell height="1.5cm" padding="1pt" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" display-align="before" number-columns-spanned="4">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block font-weight="bold" text-align="start">
                                <xsl:value-of select="../Labels/BillingAddress"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell padding="1pt" height="3cm" display-align="before" number-columns-spanned="4">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block font-weight="bold" text-align="start">
                                <xsl:value-of select="../Labels/Agreement"/>
                              </fo:block>
                            </fo:block-container>
                            <fo:block-container height="1cm" overflow="hidden">
                              <fo:block font-size="7px" text-align="start">
                                <xsl:value-of select="../Labels/Agreement2"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-body>  
                    </fo:table>                    
                  </fo:table-cell>                  
                  <fo:table-cell number-columns-spanned="3">                  
                    <fo:table id="vat-table" display-align="after" border-color="black" border-style="solid" border-width="1px">
                      <fo:table-column column-width="9mm"/>
                      <fo:table-column column-width="2.5cm"/>
                      <fo:table-column column-width="1cm"/>
                      <fo:table-column column-width="2.5cm"/>                      
                      <fo:table-body>                          
                        <fo:table-row font-size="8.0px" background-color="rgb(255 , 149 , 14)" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell padding="1pt" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" display-align="before">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="center">
                                <xsl:value-of select="../Labels/VATCode"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" display-align="before">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="center">
                                <xsl:value-of select="../Labels/TotalDutyFreePrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" display-align="before">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="center">
                                <xsl:value-of select="../Labels/Coefficient"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" display-align="before">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="center">
                                <xsl:value-of select="../Labels/TotalInclusiveOfTaxPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <xsl:apply-templates select="Taxes/VAT"/>  
                      </fo:table-body>
                    </fo:table>
                  </fo:table-cell>                            
                  <fo:table-cell number-columns-spanned="4">                  
                    <fo:table id="totals-table" display-align="after" border-color="black" border-style="solid" border-width="1px">
                      <fo:table-body>                          
                        <fo:table-row keep-with-next="always" font-size="10.0px" page-break-inside="avoid">
                          <fo:table-cell padding="1pt" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block>
                                <xsl:value-of select="../Labels/TotalDutyFreeGrossPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" text-align="end" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block>
                                <xsl:value-of select="TotalDutyFreeGrossPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row> 
                        <fo:table-row font-size="8.0px" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell padding="1pt" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="start">
                                <xsl:value-of select="../Labels/GlobalPrizegiving"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="end">
                                <xsl:value-of select="Prizegiving"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row  border-color="black" border-style="solid" border-width="1.0px" keep-with-next="always" font-size="10.0px" page-break-inside="avoid">
                          <fo:table-cell padding="1pt" font-weight="bold" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="start">
                                <xsl:value-of select="../Labels/TotalDutyFreeNetPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" font-weight="bold" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="end">
                                <xsl:value-of select="TotalDutyFreeNetPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" font-size="8.0px" page-break-inside="avoid">
                          <fo:table-cell padding="1pt" width="2cm" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="start">
                                <xsl:value-of select="../Labels/Postage"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" width="2cm" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="end">
                                <xsl:value-of select="Postage"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" font-size="8.0px" page-break-inside="avoid">
                          <fo:table-cell padding="1pt" width="2cm" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="start">
                                <xsl:value-of select="../Labels/Discount"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" width="2cm" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="end">
                                <xsl:value-of select="Discount"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" font-size="8.0px" page-break-inside="avoid">
                          <fo:table-cell padding="1pt" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="start">
                                <xsl:value-of select="../Labels/TotalTaxes"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell padding="1pt" display-align="before" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="end">
                                <xsl:value-of select="TotalTaxes"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" border-color="black" border-style="solid" border-width="1.0px" font-size="10.0px" page-break-inside="avoid">
                          <fo:table-cell display-align="center" padding="1pt" font-weight="bold" background-color="rgb(200, 200, 200)" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="start">
                                <xsl:value-of select="../Labels/TotalInclusiveOfTaxNetPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell display-align="center" padding="1pt" font-weight="bold" background-color="rgb(200, 200, 200)" number-columns-spanned="2">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="end">
                                <xsl:value-of select="TotalInclusiveOfTaxNetPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>                                  
                        </fo:table-row>
                      </fo:table-body>
                    </fo:table>                     
                  </fo:table-cell>
                </fo:table-row> 
              </fo:table-body>
            </fo:table>    
          </fo:block>
          <fo:block id="last-page"/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>
  <xsl:template match="Lines/Line">
    <fo:table>
      <fo:table-column column-width="2.8cm"/>
      <fo:table-column column-width="2cm"/>
      <fo:table-column column-width="2cm"/>
      <fo:table-column column-width="2cm"/>
      <fo:table-column column-width="3.6cm"/>
      <fo:table-column column-width="1.4cm"/>
      <fo:table-column column-width="2.1cm"/>
      <fo:table-column column-width="1.2cm"/>
      <fo:table-column column-width="2.1cm"/>
      <fo:table-column column-width="8mm"/>
      <fo:table-body>
        <fo:table-row page-break-inside="avoid" font-size="9.0px" >
          <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" padding-bottom="3mm" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" text-align="left" display-align="before">
            <fo:block-container overflow="hidden" wrap-option="no-wrap">
              <fo:block>
                <fo:marker marker-class-name="report-label">
                  <xsl:choose>
                    <xsl:when test="position()!=last()">
                      <xsl:value-of select="../../../Labels/Subtotal"/>
                    </xsl:when>
                  </xsl:choose>
                </fo:marker>
                <fo:marker marker-class-name="report-value">
                  <xsl:choose>
                    <xsl:when test="position()!=last()">
                      <xsl:value-of select="TotalPrice + sum(preceding::TotalPrice)"/>
                    </xsl:when>
                  </xsl:choose>
                </fo:marker>           
                <xsl:value-of select="Reference"/>
              </fo:block>
            </fo:block-container>
          </fo:table-cell>
          <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" display-align="before" number-columns-spanned="4">
            <fo:block-container overflow="hidden" wrap-option="no-wrap">
              <fo:block font-weight="bold" text-align="start">
                <xsl:value-of select="Name"/>
              </fo:block>
            </fo:block-container>
            <fo:block-container overflow="hidden">
              <fo:block linefeed-treatment="preserve" text-align="start">
                <xsl:value-of select="Description"/>
              </fo:block>
            </fo:block-container>
          </fo:table-cell>
          <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" display-align="before">
            <fo:block text-align="end">
              <xsl:value-of select="Quantity"/>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" display-align="before">
            <fo:block text-align="end">
              <xsl:value-of select="UnitPrice"/>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" display-align="before">
            <fo:block text-align="end">
              <xsl:value-of select="Prizegiving"/>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" display-align="before">
            <fo:block text-align="end">
              <xsl:value-of select="TotalPrice"/>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" display-align="before">
            <fo:block text-align="center">
              <xsl:value-of select="VAT"/>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:template>
  <xsl:template match="Taxes/VAT">
    <fo:table-row font-size="8.0px" keep-with-next="always" page-break-inside="avoid">
      <fo:table-cell padding="1pt" display-align="before">
        <fo:block text-align="center">
          <xsl:value-of select="Code"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell padding="1pt" display-align="before">
        <fo:block text-align="center">
          <xsl:value-of select="TotalDutyFreePrice"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell padding="1pt" display-align="before">
        <fo:block text-align="center">
          <xsl:value-of select="Coefficient"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell padding="1pt" display-align="before">
        <fo:block text-align="center">
          <xsl:value-of select="TotalInclusiveOfTaxPrice"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row> 
  </xsl:template>
</xsl:stylesheet>

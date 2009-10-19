<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:strip-space elements="*"/>

    <xsl:template match="Document">
      <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" font-selection-strategy="character-by-character" line-height-shift-adjustment="disregard-shifts" font-family="serif" font-size="11pt" language="fr" margin-left="0pt" margin-right="0pt">
  
        <fo:layout-master-set>
          
          <fo:simple-page-master master-name="only"
                                 page-height="297mm"
                                 page-width="210mm"
                                 margin-top="0.5cm"
                                 margin-bottom="0cm"
                                 margin-left="0.5cm"
                                 margin-right="0.5cm">
            <fo:region-body margin-top="3cm" margin-bottom="1cm"/>
            <fo:region-before/>
            <fo:region-after extent="1cm"/>
          </fo:simple-page-master>
          
          <fo:simple-page-master master-name="others"
                                 page-height="297mm"
                                 page-width="210mm"
                                 margin-top="0.5cm"
                                 margin-bottom="0cm"
                                 margin-left="0.5cm"
                                 margin-right="0.5cm">
            <fo:region-body margin-top="3cm"/>
            <fo:region-before/>
            <fo:region-after extent="1.3cm"/>
          </fo:simple-page-master>
          
          <fo:simple-page-master master-name="last"
                                 page-height="297mm"
                                 page-width="210mm"
                                 margin-top="0.5cm"
                                 margin-bottom="0cm"
                                 margin-left="0.5cm"
                                 margin-right="0.5cm">
            <fo:region-body margin-top="3cm" margin-bottom="1cm"/>
            <fo:region-before/>
            <fo:region-after extent="1.3cm"/>
          </fo:simple-page-master>
          
          <fo:page-sequence-master master-name="unnamed">     
        
            <fo:repeatable-page-master-alternatives>
              <fo:conditional-page-master-reference page-position="only" master-reference="only"/>
              <fo:conditional-page-master-reference page-position="first" master-reference="others"/>         
              <fo:conditional-page-master-reference page-position="last" master-reference="last"/>     
              <fo:conditional-page-master-reference page-position="rest" master-reference="others"/>
            </fo:repeatable-page-master-alternatives>
            
          </fo:page-sequence-master>    
          
        </fo:layout-master-set>
        
        <fo:page-sequence format="1" master-reference="unnamed" initial-page-number="1">
          <fo:static-content flow-name="xsl-region-before">
            <fo:table>.
              <fo:table-body>
                <fo:table-row height="2cm" background-color="rgb(0,0,0)" font-family="sans-serif" page-break-inside="avoid" unicode-bidi="embed">
                  <fo:table-cell width="5.1cm" display-align="center" padding="2pt">
                    <fo:block text-align="center">
                      <fo:external-graphic id="header" src="url('../images/logo.png')"/>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell width="4.8cm" display-align="center" text-align="center" padding="2pt">
                    <fo:block font-size="12px" color="rgb(255,255,255)">
                      <xsl:value-of select="Supplier/Address1"/>&#160;<xsl:value-of select="SupplierAddress2"/><fo:inline><fo:block/></fo:inline>
                      <xsl:value-of select="Supplier/ZipCode"/>&#160;<xsl:value-of select="Supplier/City"/><fo:inline><fo:block/></fo:inline>
                      <xsl:value-of select="Supplier/Country"/>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell width="4.9cm" display-align="center" text-align="center" padding="2pt">
                    <fo:block font-size="20px" color="rgb(255,255,255)">
                      <xsl:value-of select="Type"/>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell width="5.2cm" display-align="center" text-align="center" padding="2pt">
                    <fo:block font-size="9px" color="rgb(255,255,255)">
                      <xsl:value-of select="../Labels/Email"/>&#160;<xsl:value-of select="Supplier/Email"/><fo:inline><fo:block/></fo:inline>
                      <xsl:value-of select="../Labels/Phone"/>&#160;<xsl:value-of select="Supplier/Phone"/><fo:inline><fo:block/></fo:inline>
                      <xsl:value-of select="../Labels/Fax"/>&#160;<xsl:value-of select="Supplier/Fax"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
            <fo:table>.
              <fo:table-body>
                <fo:table-row background-color="rgb(255,149,14)" font-family="sans-serif" page-break-inside="avoid" unicode-bidi="embed">
                  <fo:table-cell width="20cm" padding="2pt">
                    <fo:block font-size="7px" text-align="center" font-style="italic">
                      <xsl:value-of select="Supplier/Status"/>, <xsl:value-of select="../Labels/Siret"/>&#160;<xsl:value-of select="Supplier/Siret"/>/<xsl:value-of select="../Labels/APECode"/>&#160;<xsl:value-of select="Supplier/APECode"/>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </fo:static-content>
          
          <fo:static-content flow-name="xsl-region-after">
            
            <fo:table page-break-inside="avoid" border-collapse="collapse" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed">      
                <fo:table-body>
                  <fo:table-row font-family="sans-serif" page-break-inside="avoid" unicode-bidi="embed">
                    <fo:table-cell width="140mm" number-rows-spanned="1">
                      <fo:block/>
                    </fo:table-cell>
                    <fo:table-cell padding-left="1mm" number-columns-spanned="1" number-rows-spanned="1">
                      <fo:block text-decoration="underline" font-weight="bold" font-size="8.0px">
                        <fo:retrieve-marker retrieve-class-name="report-label" retrieve-boundary="page" retrieve-position="last-starting-within-page"/>
                      </fo:block>
                    </fo:table-cell>
                    <fo:table-cell padding-right="1mm" number-columns-spanned="1" number-rows-spanned="1">
                      <fo:block text-align="end" text-decoration="underline" font-weight="bold" font-size="8.0px">
                        <fo:retrieve-marker retrieve-class-name="report-value" retrieve-boundary="page" retrieve-position="last-starting-within-page"/>
                      </fo:block>
                    </fo:table-cell>
                    <fo:table-cell padding-top="6mm" number-columns-spanned="1" number-rows-spanned="1">
                      <fo:block text-align="end"
                            font-size="9px"
                            font-family="sans-serif">
                        <xsl:value-of select="../Labels/Page"/>&#160;<fo:page-number/>/<fo:page-number-citation ref-id="last-page"/>
                      </fo:block>
                    </fo:table-cell>
                  </fo:table-row>
                </fo:table-body>
                                  
            </fo:table> 
          </fo:static-content>
                    
          <fo:flow flow-name="xsl-region-body" >
          
                <fo:block font-family="sans-serif" font-weight="bold" font-size="25.0px">
                  <xsl:value-of select="Type"/>&#160;<xsl:value-of select="../Labels/Prefix"/>&#160;<xsl:value-of select="FileNumber"/><xsl:value-of select="Prefix"/><xsl:value-of select="Number"/>
                </fo:block> 
                
                <fo:block font-family="sans-serif">
                  <xsl:value-of select="../Labels/Date"/>&#160;<xsl:value-of select="Date"/>
                </fo:block>
          
                <fo:table margin-bottom="1cm" page-break-inside="avoid" border-collapse="collapse">      
                  <fo:table-body>
                    <fo:table-row font-family="sans-serif" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell number-columns-spanned="5">
                        <fo:block font-size="10.0px">
                          <fo:block font-weight="bold"><xsl:value-of select="../Labels/SupplierPrefix"/>&#160;<xsl:value-of select="Supplier/CorporateName2"/>:</fo:block>
                          <xsl:value-of select="Supplier/Representative/FirstName"/>&#160;<xsl:value-of select="Supplier/Representative/LastName"/>,&#160;<xsl:value-of select="Supplier/Representative/Function"/><fo:inline><fo:block/></fo:inline>
                          <xsl:value-of select="../Labels/Email"/>&#160;<xsl:value-of select="Supplier/Representative/Email"/>
                        </fo:block> 
                      </fo:table-cell>
                      <fo:table-cell padding-left="1cm" number-columns-spanned="5">
                        <fo:block font-size="12.0px">
                          <fo:block font-weight="bold"><xsl:value-of select="Customer/CorporateName2"/></fo:block>
                          <xsl:value-of select="../Labels/CustomerPrefix"/>&#160;<xsl:value-of select="Customer/Representative/FirstName"/>&#160;<xsl:value-of select="Customer/Representative/LastName"/><fo:inline><fo:block/></fo:inline>
                          <xsl:value-of select="Customer/Address1"/>&#160;<xsl:value-of select="Customer/Address2"/><fo:inline><fo:block/></fo:inline>
                          <xsl:value-of select="Customer/ZipCode"/>&#160;<xsl:value-of select="Customer/City"/><fo:inline><fo:block/></fo:inline>
                          <xsl:value-of select="Customer/Country"/>
                        </fo:block>  
                      </fo:table-cell>
                    </fo:table-row>
                  </fo:table-body>                
                </fo:table> 
                
                <fo:table border-collapse="collapse" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed">
                  
                  <fo:table-header font-family="sans-serif" unicode-bidi="embed">
                      <fo:table-row font-family="sans-serif" page-break-inside="avoid" unicode-bidi="embed">
                        <fo:table-cell number-columns-spanned="5">
                          <fo:block font-size="10.0px" font-weight="bold" text-align="left" unicode-bidi="embed">
                            <xsl:value-of select="../Labels/FileName"/>&#160;<xsl:value-of select="FileName"/>
                          </fo:block> 
                        </fo:table-cell>
                        <fo:table-cell number-columns-spanned="5">
                          <fo:block font-size="11.0px" font-weight="bold" font-style="italic" text-align="right" unicode-bidi="embed">
                            <xsl:value-of select="../Labels/Amount"/>&#160;<xsl:value-of select="Currency"/>
                          </fo:block> 
                        </fo:table-cell>
                      </fo:table-row>

                    <fo:table-row height="5mm" font-family="sans-serif" font-size="10.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell width="2.1cm" background-color="rgb(255, 149 , 14)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-weight="bold" text-align="center" unicode-bidi="embed" display-align="center" number-columns-spanned="1" number-rows-spanned="1"><fo:block><xsl:value-of select="../Labels/Reference"/></fo:block></fo:table-cell>
                      <fo:table-cell width="3.5cm" background-color="rgb(255, 149 , 14)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-weight="bold" text-align="center" unicode-bidi="embed" display-align="center" number-columns-spanned="4" number-rows-spanned="1"><fo:block><xsl:value-of select="../Labels/Description"/></fo:block></fo:table-cell>
                      <fo:table-cell width="1.5cm" background-color="rgb(255, 149 , 14)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-weight="bold" text-align="center" unicode-bidi="embed" display-align="center" number-rows-spanned="1" number-columns-spanned="1"><fo:block><xsl:value-of select="../Labels/Quantity"/></fo:block></fo:table-cell>
                      <fo:table-cell width="2.3cm" background-color="rgb(255, 149 , 14)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-weight="bold" text-align="center" unicode-bidi="embed" display-align="center" number-rows-spanned="1" number-columns-spanned="1"><fo:block><xsl:value-of select="../Labels/UnitPrice"/></fo:block></fo:table-cell>
                      <fo:table-cell width="2.3cm" background-color="rgb(255, 149 , 14)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-weight="bold" text-align="center" unicode-bidi="embed" display-align="center" number-rows-spanned="1" number-columns-spanned="1"><fo:block><xsl:value-of select="../Labels/Prizegiving"/></fo:block></fo:table-cell>
                      <fo:table-cell width="2.3cm" background-color="rgb(255, 149 , 14)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-weight="bold" text-align="center" unicode-bidi="embed" display-align="center" number-rows-spanned="1" number-columns-spanned="1"><fo:block><xsl:value-of select="../Labels/TotalPrice"/></fo:block></fo:table-cell>
                      <fo:table-cell width="1.0cm" background-color="rgb(255, 149 , 14)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-weight="bold" text-align="center" unicode-bidi="embed" display-align="center" number-rows-spanned="1" number-columns-spanned="1"><fo:block><xsl:value-of select="../Labels/VAT"/></fo:block></fo:table-cell>
                    </fo:table-row>
                  </fo:table-header>
                  
                  <fo:table-footer font-family="sans-serif" unicode-bidi="embed">
                    <fo:table-cell number-columns-spanned="10" border-top-color="black" border-top-style="solid" border-top-width="1.0px">
                        <fo:block/>
                    </fo:table-cell>
                  </fo:table-footer>
                  
                  <fo:table-body>                 
                    <xsl:apply-templates select="Lines/Line"/>                          
                    
                    <fo:table-row>
                      <fo:table-cell padding-top="7.5cm" number-columns-spanned="1" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px">
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
       
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" background-color="rgb(255, 149 , 14)" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="4" number-rows-spanned="1">
                        <fo:block font-weight="bold" text-align="center" font-size="9.0px">
                          <xsl:value-of select="../Labels/VAT"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell number-columns-spanned="2">
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="9.0px"  unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block font-size="10.0px">
                          <xsl:value-of select="../Labels/TotalDutyFreeGrossPrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" text-align="end" background-color="rgb(255 , 255 , 255)" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block font-size="10.0px">
                          <xsl:value-of select="TotalDutyFreeGrossPrice"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>                  
                  
                    <fo:table-row keep-with-next="always" font-family="sans-serif" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="../Labels/TotalDutyFreePrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="1" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="../Labels/Coefficient"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="1" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="../Labels/TotalInclusiveOfTaxPrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell number-columns-spanned="2">
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="start" font-size="8.0px">
                          <xsl:value-of select="../Labels/GlobalPrizegiving"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="end" font-size="8.0px">
                          <xsl:value-of select="Prizegiving"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-with-next="always" font-family="sans-serif" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" border-left-color="black" border-left-style="solid" border-left-width="1px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[1]/TotalDutyFreePrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="1" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[1]/Coefficient"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" border-right-color="black" border-right-style="solid" border-right-width="1.0px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="1" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[1]/TotalInclusiveOfTaxPrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell number-columns-spanned="2">
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" font-weight="bold" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="start" font-size="10.0px">
                          <xsl:value-of select="../Labels/TotalDutyFreeNetPrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" font-weight="bold" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="end" font-size="10.0px">
                          <xsl:value-of select="TotalDutyFreeNetPrice"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" border-left-color="black" border-left-style="solid" border-left-width="1px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[2]/TotalDutyFreePrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="1" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[2]/Coefficient"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" border-right-color="black" border-right-style="solid" border-right-width="1.0px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="1" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[2]/TotalInclusiveOfTaxPrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell number-columns-spanned="2">
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" width="2cm" background-color="rgb(255 , 255 , 255)" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="start" font-size="/.0px">
                          <xsl:value-of select="../Labels/Postage"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" width="2cm" background-color="rgb(255 , 255 , 255)" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="end" font-size="/.0px">
                          <xsl:value-of select="Postage"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[3]/TotalDutyFreePrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="1" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[3]/Coefficient"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" border-right-color="black" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-right-style="solid" border-right-width="1.0px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="1" number-rows-spanned="1">
                        <fo:block text-align="center">
                          <xsl:value-of select="Taxes/VAT[3]/TotalInclusiveOfTaxPrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell number-columns-spanned="2">
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" width="2cm" background-color="rgb(255 , 255 , 255)" border-left-color="black" border-left-style="solid" border-left-width="1px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="start" font-size="8.0px">
                          <xsl:value-of select="../Labels/Discount"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" width="2cm" border-right-color="black" border-right-style="solid" border-right-width="1px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="end" font-size="8.0px">
                          <xsl:value-of select="Discount"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell number-columns-spanned="6">
                        <fo:block/>
                      </fo:table-cell>
                        <fo:table-cell padding="1pt" width="2cm" background-color="rgb(255 , 255 , 255)" border-left-color="black" border-left-style="solid" border-left-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="start" font-size="8.0px">
                          <xsl:value-of select="../Labels/TotalTaxes"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" width="2cm" background-color="rgb(255 , 255 , 255)" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="end" font-size="8.0px">
                          <xsl:value-of select="TotalTaxes"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell number-columns-spanned="6" number-rows-spanned="1">
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" width="2cm" background-color="rgb(255 , 255 , 255)" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="start" font-size="8.0px">
                          <xsl:value-of select="../Labels/InclusiveOfTaxMisc"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" width="2cm" border-right-color="black" border-right-style="solid" border-right-width="1px" background-color="rgb(255 , 255 , 255)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="end" font-size="8.0px">
                          <xsl:value-of select="InclusiveOfTaxMisc"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-left-color="black"  border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" background-color="rgb(255 , 255 , 255)" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="4" number-rows-spanned="1">
                        <fo:block text-align="start">
                          <xsl:value-of select="../Labels/DeliveryDelay"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell number-columns-spanned="2">
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" font-weight="bold" background-color="rgb(128 , 128 , 128)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="start" font-size="10.0px">
                          <xsl:value-of select="../Labels/TotalInclusiveOfTaxNetPrice"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" font-weight="bold" background-color="rgb(128 , 128 , 128)" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" border-top-color="black" border-top-style="solid" border-top-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-columns-spanned="2" number-rows-spanned="1">
                        <fo:block text-align="end" font-size="10.0px">
                          <xsl:value-of select="TotalInclusiveOfTaxNetPrice"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
              
                    <fo:table-row keep-with-next="always" >
                      <fo:table-cell padding="1pt">
                        <fo:block/>
                      </fo:table-cell>
                    </fo:table-row>
                                
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="10.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" background-color="rgb(255, 149 , 14)" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="10">
                        <fo:block text-align="center" font-weight="bold"><xsl:value-of select="../Labels/PurchaseSaleContract"/></fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="10">
                        <fo:block text-align="center"><xsl:value-of select="PurchaseSaleContract/Description"/></fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="2">
                        <fo:block text-align="center" font-weight="bold"><xsl:value-of select="../Labels/DutyFreeDeposit"/></fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="3">
                        <fo:block text-align="end"><xsl:value-of select="PurchaseSaleContract/DutyFreeDeposit"/></fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="2">
                        <fo:block text-align="center" font-weight="bold"><xsl:value-of select="../Labels/InclusiveOfTaxDeposit"/></fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="8.0px" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="3">
                        <fo:block text-align="end"><xsl:value-of select="PurchaseSaleContract/InclusiveOfTaxDeposit"/></fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    
                    <fo:table-row keep-with-next="always" >
                      <fo:table-cell padding="1pt">
                        <fo:block/>
                      </fo:table-cell>
                    </fo:table-row>
                    
                    <fo:table-row keep-with-next="always" font-family="sans-serif" font-size="9.0px" page-break-inside="avoid" unicode-bidi="embed">
                      <fo:table-cell padding="1pt" height="1.3cm" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="5">
                        <fo:block font-weight="bold" text-align="center">
                          <xsl:value-of select="../Labels/Agreement"/>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell padding="1pt" height="1.3cm" border-top-color="black" border-top-style="solid" border-top-width="1.0px" border-bottom-color="black" border-bottom-style="solid" border-bottom-width="1.0px" border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="5">
                        <fo:block text-align="center">
                          <xsl:value-of select="../Labels/BillingAddress"/>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                
                  </fo:table-body>
                
                </fo:table>    
	
	          <fo:block id="last-page"/>
	
          </fo:flow>
          	
        </fo:page-sequence>
        
      </fo:root>
       
   </xsl:template>

   <xsl:template match="Lines/Line">
     <fo:table-row page-break-inside="avoid">
       <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" padding-bottom="3mm" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" text-align="right" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="1">
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
       </fo:table-cell>
       <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="4">
         <fo:block text-align="start">
           <xsl:value-of select="Description"/>
         </fo:block>
       </fo:table-cell>
       <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="1">
         <fo:block text-align="end">
           <xsl:value-of select="Quantity"/>
         </fo:block>
       </fo:table-cell>
       <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="1">
         <fo:block text-align="end">
           <xsl:value-of select="UnitPrice"/>
         </fo:block>
       </fo:table-cell>
       <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="1">
         <fo:block text-align="end">
           <xsl:value-of select="Prizegiving"/>
         </fo:block>
       </fo:table-cell>
       <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="1">
         <fo:block text-align="end">
           <xsl:value-of select="TotalPrice"/>
         </fo:block>
       </fo:table-cell>
       <fo:table-cell border-left-color="black" border-left-style="solid" border-left-width="1.0px" border-right-color="black" border-right-style="solid" border-right-width="1.0px" font-family="sans-serif" font-size="9.0px" padding-left="2.0px" padding-right="2.0px" padding-top="1mm" padding-bottom="3mm" text-align="right" unicode-bidi="embed" display-align="before" number-rows-spanned="1" number-columns-spanned="1">
         <fo:block text-align="end">
           <xsl:value-of select="VAT"/>
         </fo:block>
       </fo:table-cell>
     </fo:table-row>
   </xsl:template>

</xsl:stylesheet>

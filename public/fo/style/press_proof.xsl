<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:strip-space elements="*"/>
  <!-- Style specifications -->
  <xsl:attribute-set name="a4-page">
    <xsl:attribute name="page-height">21cm</xsl:attribute>
    <xsl:attribute name="page-width">29.7cm</xsl:attribute>
    <xsl:attribute name="margin-top">0cm</xsl:attribute>
    <xsl:attribute name="margin-right">0cm</xsl:attribute>
    <xsl:attribute name="margin-bottom">0cm</xsl:attribute>
    <xsl:attribute name="margin-left">0cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="page-margin-specs-for-first-page">
    <xsl:attribute name="margin-top">2.7cm</xsl:attribute>
    <xsl:attribute name="margin-right">0.1cm</xsl:attribute>
    <xsl:attribute name="margin-bottom">0.1cm</xsl:attribute>
    <xsl:attribute name="margin-left">0.1cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="page-margin-specs-for-other-pages">
    <xsl:attribute name="margin-top">2.1cm</xsl:attribute>
    <xsl:attribute name="margin-right">0.1cm</xsl:attribute>
    <xsl:attribute name="margin-bottom">0.1cm</xsl:attribute>
    <xsl:attribute name="margin-left">0.1cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="region-before-spec-for-first-page">
    <xsl:attribute name="extent">2.6cm</xsl:attribute>
    <xsl:attribute name="overflow">hidden</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="region-before-spec-for-other-pages">
    <xsl:attribute name="extent">2cm</xsl:attribute>
    <xsl:attribute name="overflow">hidden</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="region-after-spec-for-last-page">
    <xsl:attribute name="extent">2.7cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="region-after-spec-for-other-pages">
    <xsl:attribute name="extent">0.6cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="default-style">
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="font-size">9px</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="color">rgb(0, 0, 0)</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="no-wrap-and-hidden">
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
    <xsl:attribute name="overflow">hidden</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table">
    <xsl:attribute name="background-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="color">rgb(255,255,255)</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-cells">
    <xsl:attribute name="display-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-block-containers">
    <xsl:attribute name="overflow">hidden</xsl:attribute>
    <xsl:attribute name="height">2cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-logo-cell" use-attribute-sets="header-table-cells">
    <xsl:attribute name="width">5.7cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-logo-block-container" use-attribute-sets="header-table-block-containers"/>
  
  <xsl:attribute-set name="header-table-logo-image">
    <xsl:attribute name="content-height">2cm</xsl:attribute>
  </xsl:attribute-set>  
  
  <xsl:attribute-set name="header-table-document-type-cell" use-attribute-sets="header-table-cells">
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="width">9cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-document-type-block-container" use-attribute-sets="header-table-block-containers">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">18px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-document-type-type-block-container" use-attribute-sets="header-table-block-containers">
    <xsl:attribute name="height">1cm</xsl:attribute>
  </xsl:attribute-set>
   
  <xsl:attribute-set name="header-table-document-type-reference-block-container" use-attribute-sets="header-table-block-containers">
    <xsl:attribute name="height">1cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-document-type-type-block">
    <xsl:attribute name="padding-top">3mm</xsl:attribute>
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-document-type-reference-block">
    <xsl:attribute name="padding-bottom">2mm</xsl:attribute>
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-document-type-block">
    <xsl:attribute name="font-size">18px</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-cell" use-attribute-sets="header-table-cells">
    <xsl:attribute name="width">15cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-block-container" use-attribute-sets="header-table-block-containers"/>
  
  <xsl:attribute-set name="header-table-infos-default-label-cell">
    <xsl:attribute name="padding-left">1mm</xsl:attribute>
    <xsl:attribute name="width">3cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-customer-label-cell" use-attribute-sets="header-table-infos-default-label-cell"/>
  
  <xsl:attribute-set name="header-table-infos-file-name-label-cell" use-attribute-sets="header-table-infos-default-label-cell"/>
  
  <xsl:attribute-set name="header-table-infos-quote-reference-label-cell" use-attribute-sets="header-table-infos-default-label-cell"/>
  
  <xsl:attribute-set name="header-table-infos-default-value-cell">
    <xsl:attribute name="padding-left">1mm</xsl:attribute>
    <xsl:attribute name="width">12cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-customer-value-cell" use-attribute-sets="header-table-infos-default-value-cell">
    <xsl:attribute name="width">7cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-file-name-value-cell" use-attribute-sets="header-table-infos-default-value-cell"/>
  
  <xsl:attribute-set name="header-table-infos-quote-reference-value-cell" use-attribute-sets="header-table-infos-default-value-cell"/>
  
  <xsl:attribute-set name="header-table-infos-date-cell">
    <xsl:attribute name="padding-right">1mm</xsl:attribute>
    <xsl:attribute name="width">5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-date-cell">
    <xsl:attribute name="padding-right">1mm</xsl:attribute>
    <xsl:attribute name="width">5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-default-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
    <xsl:attribute name="overflow">hidden</xsl:attribute>
    <xsl:attribute name="height">6mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-default-label-block-container" use-attribute-sets="header-table-infos-default-block-container">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">12px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-default-value-block-container" use-attribute-sets="header-table-infos-default-block-container">
    <xsl:attribute name="font-size">10px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-customer-label-block-container" use-attribute-sets="header-table-infos-default-label-block-container"/>
  
  <xsl:attribute-set name="header-table-infos-file-name-label-block-container" use-attribute-sets="header-table-infos-default-label-block-container"/>
  
  <xsl:attribute-set name="header-table-infos-quote-reference-label-block-container" use-attribute-sets="header-table-infos-default-label-block-container"/>
  
  <xsl:attribute-set name="header-table-infos-customer-value-block-container" use-attribute-sets="header-table-infos-default-value-block-container"/>
  
  <xsl:attribute-set name="header-table-infos-file-name-value-block-container" use-attribute-sets="header-table-infos-default-value-block-container"/>
  
  <xsl:attribute-set name="header-table-infos-quote-reference-value-block-container" use-attribute-sets="header-table-infos-default-value-block-container"/>
  
  <xsl:attribute-set name="header-table-infos-date-block-container" use-attribute-sets="header-table-infos-default-block-container"/>
  
  <xsl:attribute-set name="header-table-infos-date-block">
    <xsl:attribute name="margin-right">1mm</xsl:attribute>
    <xsl:attribute name="text-align">right</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-date-inline-label" use-attribute-sets="header-table-infos-default-label-block-container">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">12px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-table-infos-date-inline-value" use-attribute-sets="header-table-infos-default-value-block-container">
    <xsl:attribute name="font-size">10px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header2-table">
    <xsl:attribute name="background-color">rgb(255,149,14)</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header2-table-default-cell">
    <xsl:attribute name="padding">1mm</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="display-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header2-table-product-cell" use-attribute-sets="header2-table-default-cell">
    <xsl:attribute name="width">14.7cm</xsl:attribute>
  </xsl:attribute-set>  <xsl:attribute-set name="header2-table-representative-cell" use-attribute-sets="header2-table-default-cell">
    <xsl:attribute name="width">15cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header2-table-default-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="height">5mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header2-table-product-block-container" use-attribute-sets="header2-table-default-block-container"/>
  
  <xsl:attribute-set name="header2-table-representative-block-container" use-attribute-sets="header2-table-default-block-container"/>
  
  <xsl:attribute-set name="header2-table-product-block" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="margin-left">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header2-table-default-inline-label">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">10px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header2-table-product-inline-label" use-attribute-sets="header2-table-default-inline-label"/>
  
  <xsl:attribute-set name="header2-table-representative-inline-label" use-attribute-sets="header2-table-default-inline-label"/>
  
  <xsl:attribute-set name="measure-and-page-count-line">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">11px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="measure-cell">
    <xsl:attribute name="width">15cm</xsl:attribute>
    <xsl:attribute name="padding">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="page-count-cell">
    <xsl:attribute name="width">14.7cm</xsl:attribute>
    <xsl:attribute name="padding">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="measure-and-page-count-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">11px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="measure-block" use-attribute-sets="measure-and-page-count-block"/>
  
  <xsl:attribute-set name="page-count-block" use-attribute-sets="measure-and-page-count-block">
    <xsl:attribute name="text-align">right</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-row">
    <xsl:attribute name="height">2cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-default-cell">
    <xsl:attribute name="border-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-nota-bene-cell" use-attribute-sets="footer-table-default-cell">
    <xsl:attribute name="width">10.2cm</xsl:attribute>
    <xsl:attribute name="display-align">center</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="padding">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-default-agreement-cell" use-attribute-sets="footer-table-default-cell">
    <xsl:attribute name="width">7cm</xsl:attribute>
    <xsl:attribute name="display-align">before</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-agreement-cell" use-attribute-sets="footer-table-default-agreement-cell"/>
  
  <xsl:attribute-set name="footer-table-agreement2-cell" use-attribute-sets="footer-table-default-agreement-cell"/>
  
  <xsl:attribute-set name="footer-table-default-block-container">
    <xsl:attribute name="height">2cm</xsl:attribute>
    <xsl:attribute name="overflow">hidden</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-nota-bene-block-container" use-attribute-sets="footer-table-default-block-container"/>
  
  <xsl:attribute-set name="footer-table-agreement-block-container" use-attribute-sets="footer-table-default-block-container"/>
  
  <xsl:attribute-set name="footer-table-agreement2-block-container" use-attribute-sets="footer-table-default-block-container"/>
  
  <xsl:attribute-set name="footer-table-contact-block-container" use-attribute-sets="footer-table-default-block-container"/>
  
  <xsl:attribute-set name="footer-table-default-agreement-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="padding-top">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-agreement-block" use-attribute-sets="footer-table-default-agreement-block"/>
  
  <xsl:attribute-set name="footer-table-agreement2-block" use-attribute-sets="footer-table-default-agreement-block"/>
  
  <xsl:attribute-set name="footer-table-contact-cell" use-attribute-sets="footer-table-default-cell">
    <xsl:attribute name="width">5.5cm</xsl:attribute>
    <xsl:attribute name="display-align">center</xsl:attribute>
    <xsl:attribute name="padding-left">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-contact-default-cell">
    <xsl:attribute name="text-align">start</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-table-contact-default-label-cell" use-attribute-sets="footer-table-contact-default-cell">
    <xsl:attribute name="width">1cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="phone-label-cell" use-attribute-sets="footer-table-contact-default-label-cell"/>
  
  <xsl:attribute-set name="fax-label-cell" use-attribute-sets="footer-table-contact-default-label-cell"/>
  
  <xsl:attribute-set name="email-label-cell" use-attribute-sets="footer-table-contact-default-label-cell"/>
  
  <xsl:attribute-set name="phone-value-cell" use-attribute-sets="footer-table-contact-default-cell"/>
  
  <xsl:attribute-set name="fax-value-cell" use-attribute-sets="footer-table-contact-default-cell"/>
  
  <xsl:attribute-set name="email-value-cell" use-attribute-sets="footer-table-contact-default-cell"/>
  
  <xsl:attribute-set name="footer-table-contact-default-label-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="phone-label-block-container" use-attribute-sets="footer-table-contact-default-label-block-container"/>
  
  <xsl:attribute-set name="fax-label-block-container" use-attribute-sets="footer-table-contact-default-label-block-container"/>
  
  <xsl:attribute-set name="email-label-block-container" use-attribute-sets="footer-table-contact-default-label-block-container"/>
  
  <xsl:attribute-set name="mockup-reference-and-mockup-type-line">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">11px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="mockup-reference-cell">
    <xsl:attribute name="width">15cm</xsl:attribute>
    <xsl:attribute name="padding">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="mockup-type-cell">
    <xsl:attribute name="width">14.7cm</xsl:attribute>
    <xsl:attribute name="padding">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="mockup-reference-and-mockup-type-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">11px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="mockup-reference-block" use-attribute-sets="mockup-reference-and-mockup-type-block"/>
  
  <xsl:attribute-set name="mockup-type-block" use-attribute-sets="mockup-reference-and-mockup-type-block">
    <xsl:attribute name="text-align">right</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="mockup-image-cell">
    <xsl:attribute name="display-align">center</xsl:attribute>
    <xsl:attribute name="border-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="mockup-image-block">
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>
  <!-- END -->
  <xsl:template match="Document">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xsl:use-attribute-sets="default-style" font-selection-strategy="character-by-character" line-height-shift-adjustment="disregard-shifts" language="fr">     
      <fo:layout-master-set>
        <fo:simple-page-master master-name="only" xsl:use-attribute-sets="a4-page">                
          <fo:region-body xsl:use-attribute-sets="page-margin-specs-for-first-page"/>
          <fo:region-before xsl:use-attribute-sets="region-before-spec-for-first-page"/>
          <fo:region-after xsl:use-attribute-sets="region-after-spec-for-last-page"/>
        </fo:simple-page-master>        
        <fo:simple-page-master master-name="first" xsl:use-attribute-sets="a4-page">
          <fo:region-body xsl:use-attribute-sets="page-margin-specs-for-first-page"/>
          <fo:region-before xsl:use-attribute-sets="region-before-spec-for-first-page"/>
          <fo:region-after xsl:use-attribute-sets="region-after-spec-for-other-pages"/>
        </fo:simple-page-master>         
        <fo:simple-page-master master-name="other" xsl:use-attribute-sets="a4-page">
          <fo:region-body xsl:use-attribute-sets="page-margin-specs-for-other-pages"/>
          <fo:region-before xsl:use-attribute-sets="region-before-spec-for-other-pages"/>
          <fo:region-after xsl:use-attribute-sets="region-after-spec-for-other-pages"/>
        </fo:simple-page-master>         
        <fo:simple-page-master master-name="last" xsl:use-attribute-sets="a4-page">
          <fo:region-body xsl:use-attribute-sets="page-margin-specs-for-other-pages"/>
          <fo:region-before xsl:use-attribute-sets="region-before-spec-for-other-pages"/>
          <fo:region-after xsl:use-attribute-sets="region-after-spec-for-last-page"/>
        </fo:simple-page-master>        
        <fo:page-sequence-master master-name="unnamed">           
          <fo:repeatable-page-master-alternatives>
            <fo:conditional-page-master-reference page-position="only" master-reference="only"/>
            <fo:conditional-page-master-reference page-position="first" master-reference="first"/>         
            <fo:conditional-page-master-reference page-position="last" master-reference="last"/>     
            <fo:conditional-page-master-reference page-position="rest" master-reference="other"/>
          </fo:repeatable-page-master-alternatives>          
        </fo:page-sequence-master>            
      </fo:layout-master-set>     
      <fo:page-sequence format="1" master-reference="unnamed" initial-page-number="1">        
        <fo:static-content flow-name="xsl-region-before">
          <fo:table xsl:use-attribute-sets="header-table">
            <fo:table-body>
              <fo:table-row page-break-inside="avoid">
                <fo:table-cell xsl:use-attribute-sets="header-table-logo-cell">
                  <fo:block-container xsl:use-attribute-sets="header-table-logo-block-container">
                    <fo:block>
                      <fo:external-graphic xsl:use-attribute-sets="header-table-logo-image">
                        <xsl:attribute name="src">
                          <xsl:value-of select="Supplier/LogoPath"/>
                        </xsl:attribute>
                      </fo:external-graphic>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="header-table-document-type-cell">
                  <fo:block-container xsl:use-attribute-sets="header-table-document-type-block-container">
                    <fo:block-container xsl:use-attribute-sets="header-table-document-type-type-block-container">
                      <fo:block xsl:use-attribute-sets="header-table-document-type-type-block">
                        <xsl:value-of select="Type"/>
                      </fo:block>
                    </fo:block-container>
                    <fo:block-container xsl:use-attribute-sets="header-table-document-type-reference-block-container">
                      <fo:block xsl:use-attribute-sets="header-table-document-type-reference-block">
                        <xsl:value-of select="Reference"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="header-table-infos-cell">
                  <fo:block-container xsl:use-attribute-sets="header-table-infos-cell">
                    <fo:table>
                      <fo:table-body>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="header-table-infos-customer-label-cell">
                            <fo:block-container xsl:use-attribute-sets="header-table-infos-customer-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/CustomerName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="header-table-infos-customer-value-cell">
                            <fo:block-container xsl:use-attribute-sets="header-table-infos-customer-value-block-container">
                              <fo:block>
                                <xsl:value-of select="CustomerName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="header-table-infos-date-cell">
                            <fo:block-container xsl:use-attribute-sets="header-table-infos-date-block-container">
                              <fo:block xsl:use-attribute-sets="header-table-infos-date-block">
                                <fo:inline xsl:use-attribute-sets="header-table-infos-date-inline-label">
                                  <xsl:value-of select="../Labels/Date"/>
                                </fo:inline>&#160;
                                <fo:inline xsl:use-attribute-sets="header-table-infos-date-inline-value">
                                  <xsl:value-of select="Date"/>
                                </fo:inline>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="header-table-infos-file-name-label-cell">
                            <fo:block-container xsl:use-attribute-sets="header-table-infos-file-name-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/FileName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="header-table-infos-file-name-value-cell">
                            <fo:block-container xsl:use-attribute-sets="header-table-infos-file-name-value-block-container">
                              <fo:block>
                                <xsl:value-of select="FileName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="header-table-infos-quote-reference-label-cell">
                            <fo:block-container xsl:use-attribute-sets="header-table-infos-quote-reference-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/QuoteReference"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="header-table-infos-quote-reference-value-cell">
                            <fo:block-container xsl:use-attribute-sets="header-table-infos-quote-reference-value-block-container">
                              <fo:block>
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
          <fo:table xsl:use-attribute-sets="header2-table">
            <fo:table-body>
              <fo:table-row>
                <fo:table-cell xsl:use-attribute-sets="header2-table-product-cell">  
                  <fo:block-container xsl:use-attribute-sets="header2-table-product-block-container"> 
                    <fo:block xsl:use-attribute-sets="header2-table-product-block"> 
                      <fo:inline xsl:use-attribute-sets="header2-table-product-inline-label"> 
                        <xsl:value-of select="../Labels/ProductName"/>
                      </fo:inline>&#160;
                      <fo:inline>
                        <xsl:value-of select="ProductName"/>
                      </fo:inline>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="header2-table-representative-cell">  
                  <fo:block-container xsl:use-attribute-sets="header2-table-representative-block-container"> 
                    <fo:block> 
                      <fo:inline xsl:use-attribute-sets="header2-table-representative-inline-label"> 
                        <xsl:value-of select="../Labels/SupplierRepresentative"/>
                      </fo:inline>&#160;
                      <fo:inline>
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
              <fo:table-row xsl:use-attribute-sets="measure-and-page-count-line">
                <fo:table-cell xsl:use-attribute-sets="measure-cell">
                  <fo:block xsl:use-attribute-sets="measure-block">
                    <xsl:value-of select="../Labels/MockupUnitMeasure"/>&#160;<fo:retrieve-marker retrieve-class-name="unitmeasure" retrieve-boundary="page" retrieve-position="last-starting-within-page"/>
                  </fo:block>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="page-count-cell">
                  <fo:block xsl:use-attribute-sets="page-count-block">
                    <xsl:value-of select="../Labels/Page"/>&#160;<fo:page-number/>/<fo:page-number-citation ref-id="last-page"/>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
          <fo:table>
            <fo:table-body>
              <fo:table-row xsl:use-attribute-sets="footer-table-row">
                <fo:table-cell xsl:use-attribute-sets="footer-table-nota-bene-cell">
                  <fo:block-container xsl:use-attribute-sets="footer-table-nota-bene-block-container">
                    <fo:block>
                      <xsl:value-of select="../Labels/NotaBene"/>
                    </fo:block>
                    <fo:block>
                      <xsl:value-of select="../Labels/NotaBene2"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="footer-table-agreement-cell">
                  <fo:block-container xsl:use-attribute-sets="footer-table-agreement-block-container">
                    <fo:block xsl:use-attribute-sets="footer-table-agreement-block">
                      <xsl:value-of select="../Labels/Agreement"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="footer-table-agreement2-cell">
                  <fo:block-container xsl:use-attribute-sets="footer-table-agreement2-block-container">
                    <fo:block xsl:use-attribute-sets="footer-table-agreement2-block">
                      <xsl:value-of select="../Labels/Agreement2"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="footer-table-contact-cell">
                  <fo:block-container xsl:use-attribute-sets="footer-table-contact-block-container">
                    <fo:table>
                      <fo:table-body>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="phone-label-cell">
                            <fo:block-container xsl:use-attribute-sets="phone-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/Phone"/>&#160;
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="phone-value-cell">
                            <fo:block>
                              :&#160;&#160;<xsl:value-of select="Supplier/Phone"/>
                            </fo:block>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="fax-label-cell">
                            <fo:block-container xsl:use-attribute-sets="fax-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/Fax"/>&#160;
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="fax-value-cell">
                            <fo:block>
                              :&#160;&#160;<xsl:value-of select="Supplier/Fax"/>
                            </fo:block>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="email-label-cell">
                           <fo:block-container xsl:use-attribute-sets="email-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/Email"/>&#160;
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="email-value-cell">
                            <fo:block>
                              :&#160;&#160;<xsl:value-of select="Supplier/Email"/>
                            </fo:block>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-body>
                    </fo:table>
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
          <fo:table-row xsl:use-attribute-sets="mockup-reference-and-mockup-type-line">
            <fo:table-cell xsl:use-attribute-sets="mockup-reference-cell">
              <fo:block xsl:use-attribute-sets="mockup-reference-block">
                <xsl:value-of select="../../../Labels/MockupReference"/>&#160;<xsl:value-of select="Reference"/>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell xsl:use-attribute-sets="mockup-type-cell">
              <fo:block xsl:use-attribute-sets="mockup-type-block">
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
            <fo:table-cell xsl:use-attribute-sets="mockup-image-cell">
              <fo:block xsl:use-attribute-sets="mockup-image-block">
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

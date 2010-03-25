<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:strip-space elements="*"/>
  <!-- Style specifications -->
  <xsl:attribute-set name="a4-page">
    <xsl:attribute name="page-height">29.7cm</xsl:attribute>
    <xsl:attribute name="page-width">21cm</xsl:attribute>
    <xsl:attribute name="margin-top">0cm</xsl:attribute>
    <xsl:attribute name="margin-right">0cm</xsl:attribute>
    <xsl:attribute name="margin-bottom">0cm</xsl:attribute>
    <xsl:attribute name="margin-left">0cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="page-margin-specs-for-only-page">
    <xsl:attribute name="margin-top">2.5cm</xsl:attribute>
    <xsl:attribute name="margin-right">0.5cm</xsl:attribute>
    <xsl:attribute name="margin-bottom">1.6cm</xsl:attribute>
    <xsl:attribute name="margin-left">0.5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="page-margin-specs-for-all-pages">
    <xsl:attribute name="margin-top">2.5cm</xsl:attribute>
    <xsl:attribute name="margin-right">0.5cm</xsl:attribute>
    <xsl:attribute name="margin-bottom">2.1cm</xsl:attribute>
    <xsl:attribute name="margin-left">0.5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="region-after-spec">
    <xsl:attribute name="extent">2.1cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="default-style">
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="font-size">8px</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="color">rgb(0, 0, 0)</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="no-wrap-and-hidden">
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
    <xsl:attribute name="overflow">hidden</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="table">
    <xsl:attribute name="border-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="table-cell">
    <xsl:attribute name="display-align">center</xsl:attribute>
    <xsl:attribute name="border-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="table-title-row">
    <xsl:attribute name="font-size">10px</xsl:attribute>
    <xsl:attribute name="background-color">rgb(255, 149, 14)</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="table-title-cell">
    <xsl:attribute name="display-align">center</xsl:attribute>
    <xsl:attribute name="padding">1pt</xsl:attribute>
    <xsl:attribute name="border-bottom-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
    <xsl:attribute name="border-bottom-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="table-column-title-row">
    <xsl:attribute name="background-color">rgb(230, 230, 230)</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="line-cell">
    <xsl:attribute name="border-left-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-left-style">solid</xsl:attribute>
    <xsl:attribute name="border-left-width">1px</xsl:attribute>
    <xsl:attribute name="border-right-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-right-style">solid</xsl:attribute>
    <xsl:attribute name="border-right-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table">
    <xsl:attribute name="background-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="color">rgb(255,255,255)</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-cells">
    <xsl:attribute name="display-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-block-containers">
    <xsl:attribute name="overflow">hidden</xsl:attribute>
    <xsl:attribute name="height">2cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-logo-cell" use-attribute-sets="header-with-supplier-infos-table-cells">
    <xsl:attribute name="width">5.5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-logo-block-container" use-attribute-sets="header-with-supplier-infos-table-block-containers"/>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-logo">
    <xsl:attribute name="content-height">2cm</xsl:attribute>
    <xsl:attribute name="content-width">5.5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-address-cell" use-attribute-sets="header-with-supplier-infos-table-cells">
    <xsl:attribute name="padding-left">2mm</xsl:attribute>
    <xsl:attribute name="text-align">start</xsl:attribute>
    <xsl:attribute name="width">5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-address-block-container" use-attribute-sets="header-with-supplier-infos-table-block-containers"/>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-document-type-cell" use-attribute-sets="header-with-supplier-infos-table-cells">
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="width">5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-document-type-block-container" use-attribute-sets="header-with-supplier-infos-table-block-containers"/>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-document-type-block">
    <xsl:attribute name="font-size">15px</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-contact-cell" use-attribute-sets="header-with-supplier-infos-table-cells">
    <xsl:attribute name="padding-left">1mm</xsl:attribute>
    <xsl:attribute name="width">5.5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-contact-block-container" use-attribute-sets="header-with-supplier-infos-table-block-containers"/>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-contact-label-cell">
    <xsl:attribute name="width">1cm</xsl:attribute>
    <xsl:attribute name="text-align">start</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-contact-value-cell">
    <xsl:attribute name="text-align">start</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos-table-contact-block">
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos2-table">
    <xsl:attribute name="background-color">rgb(255,149,14)</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos2-cell">
    <xsl:attribute name="width">21cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos2-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="height">3mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="header-with-supplier-infos2-block">
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="font-size">7px</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-flow">
    <xsl:attribute name="margin-right">0.5cm</xsl:attribute>
    <xsl:attribute name="margin-left">0.5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-images-block">
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-images">
    <xsl:attribute name="content-height">1.5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="footer-sentence-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="footer-sentence-block">
    <xsl:attribute name="padding-top">1mm</xsl:attribute>
    <xsl:attribute name="font-size">7px</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="total-pages-cell">
    <xsl:attribute name="display-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="total-pages-block-container">
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="total-pages-block">
    <xsl:attribute name="text-align">end</xsl:attribute>
    <xsl:attribute name="font-size">9px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="region-body-main-block-for-background">
    <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
    <xsl:attribute name="background-position-horizontal">1.5cm</xsl:attribute>
    <xsl:attribute name="background-position-vertical">3.2cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="document-type-and-reference-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="margin-top">0.5cm</xsl:attribute>
    <xsl:attribute name="width">10.5cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="document-type-and-reference-block">
    <xsl:attribute name="font-size">15px</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="date-block">
    <xsl:attribute name="font-size">10px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="top-infos-table">
    <xsl:attribute name="margin-top">0.5cm</xsl:attribute>
    <xsl:attribute name="margin-bottom">1cm</xsl:attribute>
    <xsl:attribute name="border-collapse">collapse</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="representative-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="font-size">10px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="representative-inline">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="client-address-cell">
    <xsl:attribute name="padding-left">1cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="client-address-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="font-size">11px</xsl:attribute>
    <xsl:attribute name="width">8cm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="client-address-client-name-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table">
    <xsl:attribute name="table-layout">fixed</xsl:attribute>
    <xsl:attribute name="border-collapse">collapse</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="filename-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="filename-block">
    <xsl:attribute name="font-size">10px</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-column-title-row" use-attribute-sets="table-column-title-row">    
    <xsl:attribute name="font-size">10px</xsl:attribute>
    <xsl:attribute name="height">5mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-column-title-reference-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-description-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-quantity-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-remarks-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-default-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="height">5mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-column-title-reference-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-column-title-description-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-column-title-quantity-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-column-title-remarks-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-footline-cell">
    <xsl:attribute name="border-top-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-top-style">solid</xsl:attribute>
    <xsl:attribute name="border-top-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-empty-line-cell" use-attribute-sets="line-cell">
    <xsl:attribute name="padding-top">1mm</xsl:attribute> <!-- COMMENT FOR DYNAMIC RESIZE OF THE EMPTY LINE, DO NOT REMOVE ME AND DO NOT COPY ME -->        
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-last-footline-cell">
    <xsl:attribute name="padding">1mm</xsl:attribute>
    <xsl:attribute name="border-top-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-top-style">solid</xsl:attribute>
    <xsl:attribute name="border-top-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-contact-cell">
    <xsl:attribute name="padding-bottom">2mm</xsl:attribute>
    <xsl:attribute name="padding-right">2pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="contact-table" use-attribute-sets="table"/>
  
  <xsl:attribute-set name="contact-title-row" use-attribute-sets="table-title-row"/>
  
  <xsl:attribute-set name="contact-title-cell" use-attribute-sets="table-title-cell"/>  
  
  <xsl:attribute-set name="contact-title-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="contact-default-cell">
    <xsl:attribute name="padding">1mm</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">9px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="contact-name-label-cell" use-attribute-sets="contact-default-cell"/>
  
  <xsl:attribute-set name="contact-name-label-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="contact-phone-label-cell" use-attribute-sets="contact-default-cell"/>
  
  <xsl:attribute-set name="contact-phone-label-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="contact-email-label-cell" use-attribute-sets="contact-default-cell"/>
  
  <xsl:attribute-set name="contact-email-label-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-delivery-and-installation-cell">
    <xsl:attribute name="padding-bottom">2mm</xsl:attribute>
    <xsl:attribute name="padding-right">2pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="delivery-and-installation-table" use-attribute-sets="table"/>
  
  <xsl:attribute-set name="delivery-and-installation-title-row" use-attribute-sets="table-title-row"/>
  
  <xsl:attribute-set name="delivery-and-installation-title-cell" use-attribute-sets="table-title-cell"/>  
  
  <xsl:attribute-set name="delivery-and-installation-title-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="delivery-and-installation-default-cell">
    <xsl:attribute name="padding">1mm</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">9px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="delivery-name-label-cell" use-attribute-sets="delivery-and-installation-default-cell"/>
  
  <xsl:attribute-set name="delivery-name-label-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="installation-name-label-cell" use-attribute-sets="delivery-and-installation-default-cell"/>
  
  <xsl:attribute-set name="installation-name-label-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-status-cell">
    <xsl:attribute name="padding-bottom">2mm</xsl:attribute>
    <xsl:attribute name="padding-right">2pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="status-table" use-attribute-sets="table"/>
  
  <xsl:attribute-set name="status-title-row" use-attribute-sets="table-title-row"/>
  
  <xsl:attribute-set name="status-title-cell" use-attribute-sets="table-title-cell"/>  
  
  <xsl:attribute-set name="status-title-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="status-default-cell">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">9px</xsl:attribute>
    <xsl:attribute name="text-align">end</xsl:attribute>
    <xsl:attribute name="padding">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="status-in-progress-label-cell" use-attribute-sets="status-default-cell"/>
  
  <xsl:attribute-set name="status-in-progress-label-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="status-ended-label-cell" use-attribute-sets="status-default-cell"/>
  
  <xsl:attribute-set name="status-ended-label-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="default-status-box-cell">
    <xsl:attribute name="padding-left">5mm</xsl:attribute>
    <xsl:attribute name="display-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="default-status-box-block-container" use-attribute-sets="table no-wrap-and-hidden">
    <xsl:attribute name="height">2mm</xsl:attribute>
    <xsl:attribute name="width">2mm</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="status-in-progress-box-cell" use-attribute-sets="default-status-box-cell"/>
  
  <xsl:attribute-set name="status-in-progress-box-block-container" use-attribute-sets="default-status-box-block-container"/>
  
  <xsl:attribute-set name="status-ended-box-cell" use-attribute-sets="default-status-box-cell"/>
  
  <xsl:attribute-set name="status-ended-box-block-container" use-attribute-sets="default-status-box-block-container"/>
  
  <xsl:attribute-set name="agreement-table" use-attribute-sets="table">
    <xsl:attribute name="margin-bottom">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="agreement-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="height">4.5cm</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="agreement-block">
    <xsl:attribute name="padding-top">1mm</xsl:attribute>
    <xsl:attribute name="padding-bottom">3.5cm</xsl:attribute> 
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">10px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="agreement2-block">
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="font-size">9px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-line-row">
    <xsl:attribute name="text-align">end</xsl:attribute>
    <xsl:attribute name="font-size">9px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-default-line-cell" use-attribute-sets="line-cell">
    <xsl:attribute name="display-align">before</xsl:attribute>
    <xsl:attribute name="padding-top">1mm</xsl:attribute>
    <xsl:attribute name="padding-right">2px</xsl:attribute> 
    <xsl:attribute name="padding-bottom">3mm</xsl:attribute> 
    <xsl:attribute name="padding-left">2px</xsl:attribute>     
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-line-reference-cell" use-attribute-sets="main-table-default-line-cell"/>
  
  <xsl:attribute-set name="main-table-line-description-cell" use-attribute-sets="main-table-default-line-cell"/>
  
  <xsl:attribute-set name="main-table-line-quantity-cell" use-attribute-sets="main-table-default-line-cell"/>
  
  <xsl:attribute-set name="main-table-line-remarks-cell" use-attribute-sets="main-table-default-line-cell"/>
  
  <xsl:attribute-set name="main-table-line-reference-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="main-table-line-description-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="main-table-line-description2-block-container">
    <xsl:attribute name="overflow">hidden</xsl:attribute> 
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-line-reference-block">
    <xsl:attribute name="text-align">start</xsl:attribute> 
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-line-description-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="text-align">start</xsl:attribute> 
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-line-description2-block">
    <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
    <xsl:attribute name="text-align">start</xsl:attribute>  
    <xsl:attribute name="font-size">7px</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>
    <!-- END -->
  <xsl:template match="Document">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xsl:use-attribute-sets="default-style" font-selection-strategy="character-by-character" line-height-shift-adjustment="disregard-shifts" language="fr">     
      <fo:layout-master-set>
        <fo:simple-page-master master-name="only" xsl:use-attribute-sets="a4-page">                
          <fo:region-body xsl:use-attribute-sets="page-margin-specs-for-only-page"/>
          <fo:region-before/>
          <fo:region-after xsl:use-attribute-sets="region-after-spec"/>
        </fo:simple-page-master>        
        <fo:simple-page-master master-name="first" xsl:use-attribute-sets="a4-page">
          <fo:region-body xsl:use-attribute-sets="page-margin-specs-for-all-pages"/>
          <fo:region-before/>
          <fo:region-after xsl:use-attribute-sets="region-after-spec"/>
        </fo:simple-page-master>        
        <fo:simple-page-master master-name="others" xsl:use-attribute-sets="a4-page">
          <fo:region-body xsl:use-attribute-sets="page-margin-specs-for-all-pages"/>
          <fo:region-before/>
          <fo:region-after xsl:use-attribute-sets="region-after-spec"/>
        </fo:simple-page-master>        
        <fo:simple-page-master master-name="last" xsl:use-attribute-sets="a4-page">
          <fo:region-body xsl:use-attribute-sets="page-margin-specs-for-all-pages"/>
          <fo:region-before/>
          <fo:region-after xsl:use-attribute-sets="region-after-spec"/>
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
          <fo:table xsl:use-attribute-sets="header-with-supplier-infos-table">
            <fo:table-body>
              <fo:table-row page-break-inside="avoid">
                <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-logo-cell">
                  <fo:block-container xsl:use-attribute-sets="header-with-supplier-infos-table-logo-block-container">
                    <fo:block>
                      <fo:external-graphic xsl:use-attribute-sets="header-with-supplier-infos-table-logo">
                        <xsl:attribute name="src">
                          <xsl:value-of select="Supplier/LogoPath"/>
                        </xsl:attribute>
                      </fo:external-graphic>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-address-cell">
                  <fo:block-container xsl:use-attribute-sets="header-with-supplier-infos-table-address-block-container">
                    <fo:block>
                      <xsl:value-of select="Supplier/Address1"/>&#160;<xsl:value-of select="Supplier/Address2"/>
                    </fo:block>
                    <fo:block>
                      <xsl:value-of select="Supplier/ZipCode"/>&#160;<xsl:value-of select="Supplier/City"/>
                    </fo:block>
                    <fo:block>
                      <fo:inline>
                        <xsl:value-of select="Supplier/Country"/>
                      </fo:inline>                    
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-document-type-cell">
                  <fo:block-container xsl:use-attribute-sets="header-with-supplier-infos-table-document-type-block-container">
                    <fo:block xsl:use-attribute-sets="header-with-supplier-infos-table-document-type-block">
                      <xsl:value-of select="Type"/>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="header-with-supplier-infos-table-document-type-block">
                      <xsl:value-of select="Type2"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
                <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-contact-cell">
                  <fo:block-container xsl:use-attribute-sets="header-with-supplier-infos-table-contact-block-container">
                    <fo:table>
                      <fo:table-body>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-contact-label-cell">
                            <fo:block xsl:use-attribute-sets="header-with-supplier-infos-table-contact-block">
                              <xsl:value-of select="../Labels/Phone"/>&#160;
                            </fo:block>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-contact-value-cell">
                            <fo:block>
                              :&#160;&#160;<xsl:value-of select="Supplier/Phone"/>
                            </fo:block>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-contact-label-cell">
                            <fo:block xsl:use-attribute-sets="header-with-supplier-infos-table-contact-block">
                              <xsl:value-of select="../Labels/Fax"/>&#160;
                            </fo:block>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-contact-value-cell">
                            <fo:block>
                              :&#160;&#160;<xsl:value-of select="Supplier/Fax"/>
                            </fo:block>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                          <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-contact-label-cell">
                            <fo:block xsl:use-attribute-sets="header-with-supplier-infos-table-contact-block">
                              <xsl:value-of select="../Labels/Email"/>&#160;
                            </fo:block>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos-table-contact-value-cell">
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
          <fo:table xsl:use-attribute-sets="header-with-supplier-infos2-table">
            <fo:table-body>
              <fo:table-row page-break-inside="avoid">
                <fo:table-cell xsl:use-attribute-sets="header-with-supplier-infos2-cell">
                  <fo:block-container xsl:use-attribute-sets="header-with-supplier-infos2-block-container">
                    <fo:block xsl:use-attribute-sets="header-with-supplier-infos2-block">
                      <xsl:value-of select="Supplier/Status"/>,&#160;<xsl:value-of select="../Labels/Siret"/>&#160;<xsl:value-of select="Supplier/Siret"/>/<xsl:value-of select="../Labels/NAFCode"/>&#160;<xsl:value-of select="Supplier/NAFCode"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:static-content>               
        <fo:static-content flow-name="xsl-region-after" xsl:use-attribute-sets="footer-flow">
          <fo:table page-break-inside="avoid">      
            <fo:table-body>
              <fo:table-row page-break-inside="avoid">
                <fo:table-cell number-rows-spanned="2">
                  <fo:block/>
                </fo:table-cell>
                <fo:table-cell number-rows-spanned="2" number-columns-spanned="8">
                  <fo:block xsl:use-attribute-sets="footer-images-block">
                    <fo:external-graphic xsl:use-attribute-sets="footer-images" src="url('../images/synafel.png')"/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
                    <fo:external-graphic xsl:use-attribute-sets="footer-images" src="url('../images/bvqi.png')"/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;
                    <fo:external-graphic xsl:use-attribute-sets="footer-images" src="url('../images/qualifenseignes.png')"/>
                    <fo:block-container xsl:use-attribute-sets="footer-sentence-block-container">
                      <fo:block xsl:use-attribute-sets="footer-sentence-block">
                        Membre du Synafel (syndicat des enseignistes européens) et certifié Qualif' enseigne signalétique par Bureau Veritas en 2004
                      </fo:block> 
                    </fo:block-container>
                  </fo:block>
                </fo:table-cell>
                <fo:table-cell>
                  <fo:block/>
                </fo:table-cell>
              </fo:table-row>
              <fo:table-row page-break-inside="avoid">                  
                <fo:table-cell xsl:use-attribute-sets="total-pages-cell">
                  <fo:block-container xsl:use-attribute-sets="total-pages-block-container">
                    <fo:block xsl:use-attribute-sets="total-pages-block">
                      <xsl:value-of select="../Labels/Page"/>&#160;<fo:page-number/>/<fo:page-number-citation ref-id="last-page"/>
                    </fo:block>
                  </fo:block-container>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>                                  
          </fo:table>
        </fo:static-content>                 
        <fo:flow flow-name="xsl-region-body">
          <fo:block xsl:use-attribute-sets="region-body-main-block-for-background">
            <xsl:attribute name="background-image">
              <xsl:value-of select="BackgroundImage"/>
            </xsl:attribute>
            <fo:block-container xsl:use-attribute-sets="document-type-and-reference-block-container">
              <fo:block xsl:use-attribute-sets="document-type-and-reference-block">
                <xsl:value-of select="Type"/>&#160;<xsl:value-of select="../Labels/Prefix"/>&#160;<xsl:value-of select="Reference"/>
              </fo:block> 
            </fo:block-container>
            <fo:block xsl:use-attribute-sets="date-block">
              <fo:inline>
                <xsl:value-of select="../Labels/Date"/>
              </fo:inline>&#160;
              <fo:inline>
                <xsl:value-of select="Date"/>
              </fo:inline>
            </fo:block>                   
            <fo:table xsl:use-attribute-sets="top-infos-table" page-break-inside="avoid">      
              <fo:table-body>
                <fo:table-row page-break-inside="avoid">
                  <fo:table-cell number-columns-spanned="5">
                    <fo:block-container xsl:use-attribute-sets="representative-block-container">
                        <fo:block>
                          <fo:inline xsl:use-attribute-sets="representative-inline">
                            <xsl:value-of select="../Labels/SupplierPrefix"/>&#160;<xsl:value-of select="Supplier/CorporateName2"/>&#160;:
                          </fo:inline>
                          <fo:inline>
                            <xsl:value-of select="Supplier/Representative/FirstName"/>&#160;<xsl:value-of select="Supplier/Representative/LastName"/>
                          </fo:inline>
                        </fo:block>
                        <fo:block>
                          <xsl:value-of select="../Labels/SupplierRepresentativePhone"/>&#160;:&#160;<xsl:value-of select="Supplier/Representative/Phone"/>
                        </fo:block>
                        <fo:block>
                          <xsl:value-of select="../Labels/SupplierRepresentativeEmail"/>&#160;:&#160;<xsl:value-of select="Supplier/Representative/Email"/>
                        </fo:block>
                      </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="client-address-cell" number-columns-spanned="5">
                    <fo:block-container xsl:use-attribute-sets="client-address-block-container">
                      <fo:block xsl:use-attribute-sets="client-address-client-name-block">
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
            <fo:table xsl:use-attribute-sets="main-table">                
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
                  <fo:table-cell number-columns-spanned="10">
                    <fo:block-container xsl:use-attribute-sets="filename-block-container">
                      <fo:block xsl:use-attribute-sets="filename-block">
                        <fo:inline>
                          <xsl:value-of select="../Labels/FileName"/>
                        </fo:inline>&#160;
                        <fo:inline>
                          <xsl:value-of select="FileName"/>
                        </fo:inline>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-row>
                <fo:table-row xsl:use-attribute-sets="main-table-column-title-row" page-break-inside="avoid">
                  <fo:table-cell xsl:use-attribute-sets="main-table-column-title-reference-cell">
                    <fo:block-container xsl:use-attribute-sets="main-table-column-title-reference-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/Reference"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-column-title-description-cell" number-columns-spanned="4">
                    <fo:block-container xsl:use-attribute-sets="main-table-column-title-description-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/Description"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-column-title-quantity-cell">
                    <fo:block-container xsl:use-attribute-sets="main-table-column-title-quantity-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/Quantity"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-column-title-remarks-cell" number-columns-spanned="4">
                    <fo:block-container xsl:use-attribute-sets="main-table-column-title-remarks-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/Remarks"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-header>               
              <!-- A FOOTER IS REQUIRED TO CLOSE THE TABLE ON PAGE BREAKS -->
              <fo:table-footer>
                <fo:table-cell id="footline" xsl:use-attribute-sets="main-table-footline-cell" number-columns-spanned="10">
                  <fo:block/> 
                </fo:table-cell>
              </fo:table-footer>               
              <fo:table-body>                 
                <xsl:apply-templates select="Lines/Line"/>
                <!-- THIS EMPTY LINE IS REQUIRED TO FILL THE TABLE DYNAMICALLY -->                
                <fo:table-row>
                  <fo:table-cell xsl:use-attribute-sets="main-table-empty-line-cell">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell number-columns-spanned="4" xsl:use-attribute-sets="main-table-empty-line-cell">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-empty-line-cell">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell number-columns-spanned="4" xsl:use-attribute-sets="main-table-empty-line-cell">
                    <fo:block/>
                  </fo:table-cell>
                </fo:table-row>                  
                <fo:table-row>
                  <fo:table-cell xsl:use-attribute-sets="main-table-last-footline-cell" number-columns-spanned="10">
                    <fo:block/>
                  </fo:table-cell>
                </fo:table-row>              
                <fo:table-row keep-with-next="always">
                  <fo:table-cell xsl:use-attribute-sets="main-table-contact-cell" number-columns-spanned="3">                    
                    <fo:table xsl:use-attribute-sets="contact-table">
                      <fo:table-body>
                        <fo:table-row xsl:use-attribute-sets="contact-title-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="contact-title-cell" number-columns-spanned="4">
                            <fo:block-container xsl:use-attribute-sets="contact-title-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/ContactTitle"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="contact-name-label-cell">
                            <fo:block-container xsl:use-attribute-sets="contact-name-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/ContactName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="contact-phone-label-cell">
                            <fo:block-container xsl:use-attribute-sets="contact-phone-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/ContactPhone"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="contact-email-label-cell">
                            <fo:block-container xsl:use-attribute-sets="contact-email-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/ContactEmail"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-body>  
                    </fo:table>                    
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-status-cell" number-columns-spanned="2">                    
                    <fo:table xsl:use-attribute-sets="status-table">
                      <fo:table-body>
                        <fo:table-row xsl:use-attribute-sets="status-title-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="status-title-cell" number-columns-spanned="4">
                            <fo:block-container xsl:use-attribute-sets="status-title-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/StatusTitle"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="status-in-progress-label-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="status-in-progress-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/StatusInProgress"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="status-in-progress-box-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="status-in-progress-box-block-container">
                              <fo:block/>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell number-columns-spanned="2">
                            <fo:block-container>
                              <fo:block/>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell number-columns-spanned="2">
                            <fo:block-container>
                              <fo:block/>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="status-ended-label-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="status-ended-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/StatusEnded"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="status-ended-box-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="status-ended-box-block-container">
                              <fo:block/>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-body>  
                    </fo:table>                    
                  </fo:table-cell>  
                  <fo:table-cell number-columns-spanned="5" number-rows-spanned="2">
                    <fo:table xsl:use-attribute-sets="agreement-table">
                      <fo:table-body>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell>
                            <fo:block-container xsl:use-attribute-sets="agreement-block-container">
                              <fo:block xsl:use-attribute-sets="agreement-block">
                                <xsl:value-of select="../Labels/Agreement"/>
                              </fo:block>
                              <fo:block xsl:use-attribute-sets="agreement2-block">
                                <xsl:value-of select="../Labels/Agreement2"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-body>
                    </fo:table>
                  </fo:table-cell>
                </fo:table-row>    
                <fo:table-row keep-with-next="always">
                  <fo:table-cell xsl:use-attribute-sets="main-table-delivery-and-installation-cell" number-columns-spanned="5">                    
                    <fo:table xsl:use-attribute-sets="delivery-and-installation-table">
                      <fo:table-body>
                        <fo:table-row xsl:use-attribute-sets="delivery-and-installation-title-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="delivery-and-installation-title-cell" number-columns-spanned="4">
                            <fo:block-container xsl:use-attribute-sets="delivery-and-installation-title-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/DeliveryAndInstallationTitle"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="delivery-name-label-cell">
                            <fo:block-container xsl:use-attribute-sets="delivery-name-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/DeliveryName"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <xsl:choose>
                          <xsl:when test="IsInstallation='true'">
                            <fo:table-row keep-with-next="always" page-break-inside="avoid">
                              <fo:table-cell xsl:use-attribute-sets="installation-name-label-cell">
                                <fo:block-container xsl:use-attribute-sets="installation-name-label-block-container">
                                  <fo:block>
                                    <xsl:value-of select="../Labels/InstallationName"/>
                                  </fo:block>
                                </fo:block-container>
                              </fo:table-cell>
                            </fo:table-row>
                          </xsl:when>
                        </xsl:choose>
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
    <fo:table-row xsl:use-attribute-sets="main-table-line-row" page-break-inside="avoid">
      <fo:table-cell xsl:use-attribute-sets="main-table-line-reference-cell">
        <fo:block-container xsl:use-attribute-sets="main-table-line-reference-block-container">
          <fo:block xsl:use-attribute-sets="main-table-line-reference-block">
            <xsl:value-of select="Reference"/>
          </fo:block>
        </fo:block-container>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="main-table-line-description-cell" number-columns-spanned="4">
        <fo:block-container xsl:use-attribute-sets="main-table-line-description-block-container">
          <fo:block xsl:use-attribute-sets="main-table-line-description-block">
            <xsl:value-of select="Name"/>
          </fo:block>
        </fo:block-container>
        <fo:block-container xsl:use-attribute-sets="main-table-line-description2-block-container">
          <fo:block xsl:use-attribute-sets="main-table-line-description2-block">
            <xsl:value-of select="Description"/>
          </fo:block>
        </fo:block-container>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="main-table-line-quantity-cell">
        <fo:block>
          <xsl:value-of select="Quantity"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="main-table-line-remarks-cell" number-columns-spanned="4">
        <fo:block/>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
</xsl:stylesheet>

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
    <xsl:attribute name="font-size">18px</xsl:attribute>
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
  
  <xsl:attribute-set name="report-label-cell">
    <xsl:attribute name="display-align">after</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="report-label-block-container">
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="report-label-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="text-align">end</xsl:attribute>
    <xsl:attribute name="text-decoration">underline</xsl:attribute>
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
    <xsl:attribute name="font-size">20px</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="top-infos-table">
    <xsl:attribute name="margin-top">1cm</xsl:attribute>
    <xsl:attribute name="margin-bottom">1cm</xsl:attribute>
    <xsl:attribute name="border-collapse">collapse</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="date-and-representative-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="font-size">10px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="date-block">
    <xsl:attribute name="margin-bottom">3mm</xsl:attribute>
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
  
  <xsl:attribute-set name="sales-terms-table" use-attribute-sets="table">
    <xsl:attribute name="margin-bottom">2pt</xsl:attribute>
  </xsl:attribute-set>  
  
  <xsl:attribute-set name="sales-terms-title-row" use-attribute-sets="table-title-row"/>
  
  <xsl:attribute-set name="sales-terms-title-cell" use-attribute-sets="table-title-cell"/>
  
  <xsl:attribute-set name="sales-terms-title-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="sales-terms-description-row" use-attribute-sets="table-title-row"/>
  
  <xsl:attribute-set name="sales-terms-description-cell" use-attribute-sets="table-title-cell">
    <xsl:attribute name="background-color">rgb(255, 255, 255)</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="sales-terms-description-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="height">4mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="sales-terms-description-block" use-attribute-sets="default-style"/>
  
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
  
  <xsl:attribute-set name="currency-cell">
    <xsl:attribute name="padding-left">1mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="currency-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="currency-block">
    <xsl:attribute name="font-size">10px</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="text-align">right</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-column-title-row" use-attribute-sets="table-column-title-row">    
    <xsl:attribute name="font-size">10px</xsl:attribute>
    <xsl:attribute name="height">5mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-column-title-reference-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-description-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-quantity-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-unit-price-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-prizegiving-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-total-price-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-vat-cell" use-attribute-sets="table-cell"/>
  
  <xsl:attribute-set name="main-table-column-title-default-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="height">5mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-column-title-reference-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-column-title-description-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-column-title-quantity-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-column-title-unit-price-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-column-title-prizegiving-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-column-title-total-price-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>  
  
  <xsl:attribute-set name="main-table-column-title-vat-block-container" use-attribute-sets="main-table-column-title-default-block-container"/>
  
  <xsl:attribute-set name="main-table-footline-cell">
    <xsl:attribute name="border-top-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-top-style">solid</xsl:attribute>
    <xsl:attribute name="border-top-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-empty-line-cell" use-attribute-sets="line-cell">
    <xsl:attribute name="padding-top">1mm</xsl:attribute> <!-- COMMENT FOR DYNAMIC RESIZE OF THE EMPTY LINE, DO NOT REMOVE ME AND DO NOT COPY ME -->        
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-last-footline-cell">
    <xsl:attribute name="padding">1pt</xsl:attribute>
    <xsl:attribute name="border-top-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-top-style">solid</xsl:attribute>
    <xsl:attribute name="border-top-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-invoicing-state-cell">
    <xsl:attribute name="padding-bottom">2mm</xsl:attribute>
    <xsl:attribute name="padding-right">2pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="invoicing-state-table" use-attribute-sets="table"/>
  
  <xsl:attribute-set name="invoicing-state-title-row" use-attribute-sets="table-title-row"/>
  
  <xsl:attribute-set name="invoicing-state-title-cell" use-attribute-sets="table-title-cell"/>
  
  <xsl:attribute-set name="invoicing-state-default-cell">
    <xsl:attribute name="padding">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="invoicing-state-quote-total-label-cell" use-attribute-sets="invoicing-state-default-cell"/>
  
  <xsl:attribute-set name="invoicing-state-quote-total-value-cell" use-attribute-sets="invoicing-state-default-cell"/>
  
  <xsl:attribute-set name="invoicing-state-quote-total-label-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="invoicing-state-quote-total-value-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="invoicing-state-quote-total-label-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="invoicing-state-invoiced-total-label-cell" use-attribute-sets="invoicing-state-default-cell"/>
  
  <xsl:attribute-set name="invoicing-state-invoiced-total-value-cell" use-attribute-sets="invoicing-state-default-cell"/>
  
  <xsl:attribute-set name="invoicing-state-invoiced-total-label-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="invoicing-state-invoiced-total-value-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="invoicing-state-invoiced-total-label-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="invoicing-state-invoiced-total-label2-block">
    <xsl:attribute name="font-size">7px</xsl:attribute>  
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="invoicing-state-balance-label-cell" use-attribute-sets="invoicing-state-default-cell"/>
  
  <xsl:attribute-set name="invoicing-state-balance-value-cell" use-attribute-sets="invoicing-state-default-cell"/>
  
  <xsl:attribute-set name="invoicing-state-balance-label-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="invoicing-state-balance-value-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="invoicing-state-balance-label-block">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
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
  
  <xsl:attribute-set name="main-table-line-unit-price-cell" use-attribute-sets="main-table-default-line-cell"/>
  
  <xsl:attribute-set name="main-table-line-prizegiving-cell" use-attribute-sets="main-table-default-line-cell"/>
  
  <xsl:attribute-set name="main-table-line-total-price-cell" use-attribute-sets="main-table-default-line-cell"/>
  
  <xsl:attribute-set name="main-table-line-vat-cell" use-attribute-sets="main-table-default-line-cell"/>
  
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
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-line-vat-block">
    <xsl:attribute name="text-align">center</xsl:attribute> 
  </xsl:attribute-set>
  
  <xsl:attribute-set name="vat-table" use-attribute-sets="table"/>
  
  <xsl:attribute-set name="vat-table-header-row" use-attribute-sets="table-column-title-row"/>    
  
  <xsl:attribute-set name="vat-table-header-default-cell" use-attribute-sets="table-cell">  
    <xsl:attribute name="padding">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="vat-table-header-code-cell" use-attribute-sets="vat-table-header-default-cell"/> 
  
  <xsl:attribute-set name="vat-table-header-total-duty-free-price-cell" use-attribute-sets="vat-table-header-default-cell"/> 
  
  <xsl:attribute-set name="vat-table-header-coefficient-cell" use-attribute-sets="vat-table-header-default-cell"/> 
  
  <xsl:attribute-set name="vat-table-header-total-inclusive-of-tax-price-cell" use-attribute-sets="vat-table-header-default-cell"/> 
  
  <xsl:attribute-set name="vat-table-header-code-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="vat-table-header-total-duty-free-price-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="vat-table-header-coefficient-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="vat-table-header-total-inclusive-of-tax-price-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="vat-table-line-row">
    <xsl:attribute name="text-align">center</xsl:attribute> 
  </xsl:attribute-set>    
  
  <xsl:attribute-set name="vat-table-line-default-cell" use-attribute-sets="table-cell">  
    <xsl:attribute name="padding">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="vat-table-line-code-cell" use-attribute-sets="vat-table-line-default-cell"/> 
  
  <xsl:attribute-set name="vat-table-line-total-duty-free-price-cell" use-attribute-sets="vat-table-line-default-cell"/> 
  
  <xsl:attribute-set name="vat-table-line-coefficient-cell" use-attribute-sets="vat-table-line-default-cell"/> 
  
  <xsl:attribute-set name="vat-table-line-total-inclusive-of-tax-price-cell" use-attribute-sets="vat-table-line-default-cell"/>  
  
  <xsl:attribute-set name="totals-table" use-attribute-sets="table"/>
  
  <xsl:attribute-set name="totals-table-total-duty-free-net-price-row" use-attribute-sets="table-cell">  
    <xsl:attribute name="font-size">10px</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="totals-table-total-inclusive-of-tax-net-price-row" use-attribute-sets="table-cell">  
    <xsl:attribute name="background-color">rgb(180, 180, 180)</xsl:attribute>
    <xsl:attribute name="font-size">11px</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="totals-table-default-cell">  
    <xsl:attribute name="padding">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="totals-table-total-duty-free-net-price-label-cell" use-attribute-sets="totals-table-default-cell"/> 
  
  <xsl:attribute-set name="totals-table-total-duty-free-net-price-value-cell" use-attribute-sets="totals-table-default-cell"/> 
  
  <xsl:attribute-set name="totals-table-total-taxes-label-cell" use-attribute-sets="totals-table-default-cell"/>  
  
  <xsl:attribute-set name="totals-table-total-taxes-value-cell" use-attribute-sets="totals-table-default-cell"/>
  
  <xsl:attribute-set name="totals-table-total-inclusive-of-tax-net-price-label-cell" use-attribute-sets="totals-table-default-cell"/>  
  
  <xsl:attribute-set name="totals-table-total-inclusive-of-tax-net-price-value-cell" use-attribute-sets="totals-table-default-cell"/>
  
  <xsl:attribute-set name="totals-table-total-duty-free-net-price-label-block-container" use-attribute-sets="no-wrap-and-hidden"/>  
  
  <xsl:attribute-set name="totals-table-total-duty-free-net-price-value-block-container" use-attribute-sets="no-wrap-and-hidden"/> 
  
  <xsl:attribute-set name="totals-table-total-taxes-label-block-container" use-attribute-sets="no-wrap-and-hidden"/>  
  
  <xsl:attribute-set name="totals-table-total-taxes-value-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="totals-table-total-inclusive-of-tax-price-label-block-container" use-attribute-sets="no-wrap-and-hidden"/>  
  
  <xsl:attribute-set name="totals-table-total-inclusive-of-tax-price-value-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="totals-table-default-value-block">
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="totals-table-total-duty-free-net-price-value-block" use-attribute-sets="totals-table-default-value-block"/>
  
  <xsl:attribute-set name="totals-table-total-taxes-value-block" use-attribute-sets="totals-table-default-value-block"/>
  
  <xsl:attribute-set name="totals-table-total-inclusive-of-tax-price-value-block" use-attribute-sets="totals-table-default-value-block"/>
  
  <xsl:attribute-set name="main-table-due-dates-cell">
    <xsl:attribute name="padding-bottom">5mm</xsl:attribute>
    <xsl:attribute name="padding-right">2pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="due-dates-table" use-attribute-sets="table"/>
  
  <xsl:attribute-set name="due-dates-title-row" use-attribute-sets="table-title-row"/>
  
  <xsl:attribute-set name="due-dates-title-cell" use-attribute-sets="table-title-cell"/>
  
  <xsl:attribute-set name="due-dates-title-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="due-dates-table-column-title-row" use-attribute-sets="table-column-title-row"/>
  
  <xsl:attribute-set name="due-dates-table-column-title-date-cell" use-attribute-sets="table-cell">
    <xsl:attribute name="padding">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="due-dates-table-column-title-date-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="due-dates-table-column-title-total-cell" use-attribute-sets="table-cell">
    <xsl:attribute name="padding">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="due-dates-table-column-title-total-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="due-dates-table-line-default-cell" use-attribute-sets="table-cell">  
    <xsl:attribute name="padding">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="due-dates-table-line-default-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="height">5mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="due-dates-table-line-default-block">
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="due-dates-table-line-date-cell" use-attribute-sets="due-dates-table-line-default-cell"/>
  
  <xsl:attribute-set name="due-dates-table-line-total-cell" use-attribute-sets="due-dates-table-line-default-cell"/>
  
  <xsl:attribute-set name="due-dates-table-line-date-block-container" use-attribute-sets="due-dates-table-line-default-block-container"/>
  
  <xsl:attribute-set name="due-dates-table-line-total-block-container" use-attribute-sets="due-dates-table-line-default-block-container"/>
  
  <xsl:attribute-set name="due-dates-table-line-date-block" use-attribute-sets="due-dates-table-line-default-block"/>
  
  <xsl:attribute-set name="due-dates-table-line-total-block" use-attribute-sets="due-dates-table-line-default-block"/>
  
  <xsl:attribute-set name="main-table-due-dates-separation-cell">
    <xsl:attribute name="padding-bottom">5mm</xsl:attribute>
    <xsl:attribute name="padding-right">2pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="main-table-form-to-cut-cell">
    <xsl:attribute name="padding-left">1cm</xsl:attribute>
    <xsl:attribute name="padding-bottom">5mm</xsl:attribute>
    <xsl:attribute name="padding-right">2pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table">
    <xsl:attribute name="border-top-width">1px</xsl:attribute>
    <xsl:attribute name="border-top-style">solid</xsl:attribute>
    <xsl:attribute name="border-top-color">rgb(0, 0, 0)</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-title-row" use-attribute-sets="table-title-row">
    <xsl:attribute name="border-left-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-left-style">solid</xsl:attribute>
    <xsl:attribute name="border-left-width">1px</xsl:attribute>
    <xsl:attribute name="border-right-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-right-style">solid</xsl:attribute>
    <xsl:attribute name="border-right-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-title-cell" use-attribute-sets="table-title-cell"/>
  
  <xsl:attribute-set name="form-to-cut-title-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="form-to-cut-table-column-title-row" use-attribute-sets="table-column-title-row"/>
  
  <xsl:attribute-set name="form-to-cut-table-column-title-date-cell" use-attribute-sets="table-cell">
    <xsl:attribute name="padding">1pt</xsl:attribute>
    <xsl:attribute name="border-bottom-style">dashed</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-column-title-date-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="form-to-cut-table-column-title-reference-cell" use-attribute-sets="table-cell">
    <xsl:attribute name="padding">1pt</xsl:attribute>
    <xsl:attribute name="border-bottom-style">dashed</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-column-title-reference-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="form-to-cut-table-column-title-total-cell" use-attribute-sets="table-cell">
    <xsl:attribute name="padding">1pt</xsl:attribute>
    <xsl:attribute name="border-bottom-style">dashed</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-column-title-total-block-container" use-attribute-sets="no-wrap-and-hidden"/>
  
  <xsl:attribute-set name="form-to-cut-table-line-row">
    <xsl:attribute name="border-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-style">dashed</xsl:attribute>
    <xsl:attribute name="border-width">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-line-default-cell">
    <xsl:attribute name="display-align">center</xsl:attribute>
    <xsl:attribute name="padding">1pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-line-default-block-container" use-attribute-sets="no-wrap-and-hidden">
    <xsl:attribute name="height">5mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-line-default-block">
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-line-date-cell" use-attribute-sets="form-to-cut-table-line-default-cell">
    <xsl:attribute name="border-right-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-right-style">solid</xsl:attribute>
    <xsl:attribute name="border-right-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-line-reference-cell" use-attribute-sets="form-to-cut-table-line-default-cell">
    <xsl:attribute name="border-right-color">rgb(0, 0, 0)</xsl:attribute>
    <xsl:attribute name="border-right-style">solid</xsl:attribute>
    <xsl:attribute name="border-right-width">1px</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="form-to-cut-table-line-total-cell" use-attribute-sets="form-to-cut-table-line-default-cell"/>
  
  <xsl:attribute-set name="form-to-cut-table-line-date-block-container" use-attribute-sets="form-to-cut-table-line-default-block-container"/>
  
  <xsl:attribute-set name="form-to-cut-table-line-reference-block-container" use-attribute-sets="form-to-cut-table-line-default-block-container"/>
  
  <xsl:attribute-set name="form-to-cut-table-line-total-block-container" use-attribute-sets="form-to-cut-table-line-default-block-container"/>
  
  <xsl:attribute-set name="form-to-cut-table-line-date-block" use-attribute-sets="form-to-cut-table-line-default-block"/>
  
  <xsl:attribute-set name="form-to-cut-table-line-reference-block" use-attribute-sets="form-to-cut-table-line-default-block"/>
  
  <xsl:attribute-set name="form-to-cut-table-line-total-block" use-attribute-sets="form-to-cut-table-line-default-block"/>
  
  <xsl:attribute-set name="main-table-scissors-cell">
    <xsl:attribute name="padding-top">13.9mm</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="scissors-cell">
    <xsl:attribute name="padding-bottom">1.55mm</xsl:attribute>
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="scissors-image">
    <xsl:attribute name="content-height">3mm</xsl:attribute>
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
                <fo:table-cell xsl:use-attribute-sets="report-label-cell">
                  <fo:block-container xsl:use-attribute-sets="report-label-block-container">
                    <fo:block xsl:use-attribute-sets="report-label-block">
                      <fo:retrieve-marker retrieve-class-name="report-label" retrieve-boundary="page" retrieve-position="last-starting-within-page"/>&#160;<fo:retrieve-marker retrieve-class-name="report-value" retrieve-boundary="page" retrieve-position="last-starting-within-page"/>
                    </fo:block>
                  </fo:block-container>
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
            <fo:table xsl:use-attribute-sets="top-infos-table" page-break-inside="avoid">      
              <fo:table-body>
                <fo:table-row page-break-inside="avoid">
                  <fo:table-cell number-columns-spanned="5">
                    <fo:block-container xsl:use-attribute-sets="date-and-representative-block-container">
                      <fo:block xsl:use-attribute-sets="date-block">
                        <fo:inline>
                          <xsl:value-of select="../Labels/Date"/>
                        </fo:inline>&#160;
                        <fo:inline>
                          <xsl:value-of select="Date"/>
                        </fo:inline>
                      </fo:block>
                      <fo:block>
                        <fo:inline xsl:use-attribute-sets="representative-inline">
                          <xsl:value-of select="../Labels/SupplierCommercialPrefix"/>&#160;<xsl:value-of select="Supplier/CorporateName2"/>:
                        </fo:inline>
                        <fo:inline>
                          <xsl:value-of select="Supplier/CommercialRepresentative/FirstName"/>&#160;<xsl:value-of select="Supplier/CommercialRepresentative/LastName"/>
                        </fo:inline>
                      </fo:block>
                      <fo:block>
                        <fo:inline>
                          <xsl:value-of select="../Labels/SupplierRepresentativeEmail"/>
                        </fo:inline>&#160;
                        <fo:inline>
                          <xsl:value-of select="Supplier/CommercialRepresentative/Email"/>
                        </fo:inline>
                      </fo:block>
                      <fo:block>
                        <fo:inline xsl:use-attribute-sets="representative-inline">
                          <xsl:value-of select="../Labels/SupplierAdministrativePrefix"/>&#160;<xsl:value-of select="Supplier/CorporateName2"/>:
                        </fo:inline>
                        <fo:inline>
                          <xsl:value-of select="Supplier/AdministrativeRepresentative/FirstName"/>&#160;<xsl:value-of select="Supplier/AdministrativeRepresentative/LastName"/>
                        </fo:inline>
                      </fo:block>
                      <fo:block>
                        <fo:inline>
                          <xsl:value-of select="../Labels/SupplierRepresentativeEmail"/>
                        </fo:inline>&#160;
                        <fo:inline>
                          <xsl:value-of select="Supplier/AdministrativeRepresentative/Email"/>
                        </fo:inline>
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
            <fo:table xsl:use-attribute-sets="sales-terms-table">
              <fo:table-body>                          
                <fo:table-row xsl:use-attribute-sets="sales-terms-title-row" keep-with-next="always" page-break-inside="avoid">
                  <fo:table-cell xsl:use-attribute-sets="sales-terms-title-cell" number-columns-spanned="10">
                    <fo:block-container xsl:use-attribute-sets="sales-terms-title-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/SalesTerms"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-row>
                <fo:table-row xsl:use-attribute-sets="sales-terms-description-row" keep-with-next="always" page-break-inside="avoid">
                  <fo:table-cell xsl:use-attribute-sets="sales-terms-description-cell" number-columns-spanned="10">
                    <fo:block-container xsl:use-attribute-sets="sales-terms-description-block-container">
                      <fo:block xsl:use-attribute-sets="sales-terms-description-block">
                        <xsl:value-of select="SalesTerms"/>
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
                  <fo:table-cell number-columns-spanned="5">
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
                  <fo:table-cell xsl:use-attribute-sets="currency-cell" number-columns-spanned="5">
                    <fo:block-container xsl:use-attribute-sets="currency-block-container">
                      <fo:block xsl:use-attribute-sets="currency-block">
                        <xsl:value-of select="../Labels/Amount"/>&#160;<xsl:value-of select="Currency"/>
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
                  <fo:table-cell xsl:use-attribute-sets="main-table-column-title-unit-price-cell">
                    <fo:block-container xsl:use-attribute-sets="main-table-column-title-unit-price-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/UnitPrice"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-column-title-prizegiving-cell">
                    <fo:block-container xsl:use-attribute-sets="main-table-column-title-prizegiving-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/Prizegiving"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-column-title-total-price-cell">
                    <fo:block-container xsl:use-attribute-sets="main-table-column-title-total-price-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/TotalPrice"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-column-title-vat-cell">
                    <fo:block-container xsl:use-attribute-sets="main-table-column-title-vat-block-container">
                      <fo:block>
                        <xsl:value-of select="../Labels/VAT"/>
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
                  <fo:table-cell xsl:use-attribute-sets="main-table-empty-line-cell">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-empty-line-cell">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-empty-line-cell">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-empty-line-cell">
                    <fo:block/>
                  </fo:table-cell>
                </fo:table-row>                  
                <fo:table-row>
                  <fo:table-cell xsl:use-attribute-sets="main-table-last-footline-cell" number-columns-spanned="10">
                    <fo:block/>
                  </fo:table-cell>
                </fo:table-row>                 
                <fo:table-row keep-with-next="always">
                  <fo:table-cell xsl:use-attribute-sets="main-table-invoicing-state-cell" number-columns-spanned="3">                    
                    <fo:table xsl:use-attribute-sets="invoicing-state-table">
                      <fo:table-body>
                        <fo:table-row xsl:use-attribute-sets="invoicing-state-title-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="invoicing-state-title-cell" number-columns-spanned="4">
                            <fo:block-container overflow="hidden" wrap-option="no-wrap">
                              <fo:block text-align="center" font-weight="bold">
                                <xsl:value-of select="../Labels/InvoicingState"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="invoicing-state-quote-total-value-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="invoicing-state-quote-total-label-block-container">
                              <fo:block xsl:use-attribute-sets="invoicing-state-quote-total-label-block">
                                <xsl:value-of select="../Labels/QuoteTotal"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="invoicing-state-quote-total-value-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="invoicing-state-quote-total-value-block-container">
                              <fo:block>
                                <xsl:value-of select="InvoicingState/QuoteTotal"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="invoicing-state-invoiced-total-label-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="invoicing-state-invoiced-total-label-block-container">
                              <fo:block xsl:use-attribute-sets="invoicing-state-invoiced-total-label-block">
                                <xsl:value-of select="../Labels/InvoicedTotal"/>
                              </fo:block>
                              <fo:block xsl:use-attribute-sets="invoicing-state-invoiced-total-label2-block">
                                <xsl:value-of select="../Labels/InvoicedTotal2"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="invoicing-state-invoiced-total-value-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="invoicing-state-invoiced-total-value-block-container">
                              <fo:block>
                                <xsl:value-of select="InvoicingState/InvoicedTotal"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="invoicing-state-balance-label-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="invoicing-state-balance-label-block-container">
                              <fo:block xsl:use-attribute-sets="invoicing-state-balance-label-block">
                                <xsl:value-of select="../Labels/Balance"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="invoicing-state-balance-value-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="invoicing-state-balance-value-block-container">
                              <fo:block>
                                <xsl:value-of select="InvoicingState/Balance"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-body>  
                    </fo:table>                    
                  </fo:table-cell>                  
                  <fo:table-cell number-columns-spanned="3">                  
                    <fo:table xsl:use-attribute-sets="vat-table">
                      <fo:table-column column-width="9mm"/>
                      <fo:table-column column-width="2.5cm"/>
                      <fo:table-column column-width="1cm"/>
                      <fo:table-column column-width="2.5cm"/>                      
                      <fo:table-header>                          
                        <fo:table-row xsl:use-attribute-sets="vat-table-header-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="vat-table-header-code-cell">
                            <fo:block-container xsl:use-attribute-sets="vat-table-header-code-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/VATCode"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="vat-table-header-total-duty-free-price-cell">
                            <fo:block-container xsl:use-attribute-sets="vat-table-header-total-duty-free-price-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/TotalDutyFreePrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="vat-table-header-coefficient-cell">
                            <fo:block-container xsl:use-attribute-sets="vat-table-header-coefficient-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/Coefficient"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="vat-table-header-total-inclusive-of-tax-price-cell">
                            <fo:block-container xsl:use-attribute-sets="vat-table-header-total-inclusive-of-tax-price-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/TotalInclusiveOfTaxPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-header>
                      <fo:table-body> 
                        <xsl:apply-templates select="Taxes/VAT[Code &lt; 5]"/>  
                      </fo:table-body>
                    </fo:table>
                  </fo:table-cell>                             
                  <fo:table-cell number-columns-spanned="4">                  
                    <fo:table xsl:use-attribute-sets="totals-table">
                      <fo:table-body>                          
                        <fo:table-row xsl:use-attribute-sets="totals-table-total-duty-free-net-price-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="totals-table-total-duty-free-net-price-label-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="totals-table-total-duty-free-net-price-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/TotalDutyFreeNetPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="totals-table-total-duty-free-net-price-value-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="totals-table-total-duty-free-net-price-value-block-container">
                              <fo:block xsl:use-attribute-sets="totals-table-total-duty-free-net-price-value-block">
                                <xsl:value-of select="TotalDutyFreeNetPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="totals-table-total-taxes-label-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="totals-table-total-taxes-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/TotalTaxes"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="totals-table-total-taxes-value-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="totals-table-total-taxes-value-block-container">
                              <fo:block xsl:use-attribute-sets="totals-table-total-taxes-value-block">
                                <xsl:value-of select="TotalTaxes"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row xsl:use-attribute-sets="totals-table-total-inclusive-of-tax-net-price-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="totals-table-total-inclusive-of-tax-net-price-label-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="totals-table-total-inclusive-of-tax-price-label-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/TotalInclusiveOfTaxNetPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="totals-table-total-inclusive-of-tax-net-price-value-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="totals-table-total-inclusive-of-tax-price-value-block-container">
                              <fo:block xsl:use-attribute-sets="totals-table-total-inclusive-of-tax-price-value-block">
                                <xsl:value-of select="TotalInclusiveOfTaxNetPrice"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>                                  
                        </fo:table-row>
                      </fo:table-body>
                    </fo:table>                     
                  </fo:table-cell>
                </fo:table-row> 
                <fo:table-row keep-with-next="always">
                  <fo:table-cell xsl:use-attribute-sets="main-table-due-dates-cell" number-columns-spanned="3">                    
                    <fo:table xsl:use-attribute-sets="due-dates-table">
                      <fo:table-column column-width="2cm"/>
                      <fo:table-column/>
                      <fo:table-header>
                        <fo:table-row xsl:use-attribute-sets="due-dates-title-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="due-dates-title-cell" number-columns-spanned="2">
                            <fo:block-container xsl:use-attribute-sets="due-dates-title-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/DueDates"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                      </fo:table-header>
                      <fo:table-body>
                        <fo:table-row xsl:use-attribute-sets="due-dates-table-column-title-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="due-dates-table-column-title-date-cell">
                            <fo:block-container xsl:use-attribute-sets="due-dates-table-column-title-date-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/DueDatesDate"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="due-dates-table-column-title-total-cell">
                            <fo:block-container xsl:use-attribute-sets="due-dates-table-column-title-total-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/DueDatesTotal"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <xsl:apply-templates match="DueDates/DueDate" mode="DueDates"/>
                      </fo:table-body>  
                    </fo:table>                    
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-due-dates-separation-cell">
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-form-to-cut-cell" number-columns-spanned="5">   
                    <fo:table xsl:use-attribute-sets="form-to-cut-table">
                      <fo:table-column column-width="2cm"/>
                      <fo:table-column column-width="4cm"/>
                      <fo:table-column column-width="4cm"/>
                      <fo:table-body>
                        <fo:table-row xsl:use-attribute-sets="form-to-cut-title-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="form-to-cut-title-cell" number-columns-spanned="3">
                            <fo:block-container xsl:use-attribute-sets="form-to-cut-title-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/FormToCut"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row xsl:use-attribute-sets="form-to-cut-table-column-title-row" keep-with-next="always" page-break-inside="avoid">
                          <fo:table-cell xsl:use-attribute-sets="form-to-cut-table-column-title-date-cell">
                            <fo:block-container xsl:use-attribute-sets="form-to-cut-table-column-title-date-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/DueDatesDate"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="form-to-cut-table-column-title-reference-cell">
                            <fo:block-container xsl:use-attribute-sets="form-to-cut-table-column-title-reference-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/DueDatesReference"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="form-to-cut-table-column-title-total-cell">
                            <fo:block-container xsl:use-attribute-sets="form-to-cut-table-column-title-total-block-container">
                              <fo:block>
                                <xsl:value-of select="../Labels/DueDatesTotal"/>
                              </fo:block>
                            </fo:block-container>
                          </fo:table-cell>
                        </fo:table-row>
                        <xsl:apply-templates match="DueDates/DueDate" mode="FormToCut"/>
                      </fo:table-body>  
                    </fo:table> 
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="main-table-scissors-cell">
                    <fo:table>
                      <fo:table-body>
                        <xsl:apply-templates match="DueDates/DueDate" mode="Scissors"/>
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
                  <xsl:value-of select="format-number(TotalPrice + sum(preceding::TotalPrice), '0.00')"/>
                </xsl:when>
              </xsl:choose>
            </fo:marker>           
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
      <fo:table-cell xsl:use-attribute-sets="main-table-line-unit-price-cell">
        <fo:block>
          <xsl:value-of select="UnitPrice"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="main-table-line-prizegiving-cell">
        <fo:block>
          <xsl:value-of select="Prizegiving"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="main-table-line-total-price-cell">
        <fo:block>
          <xsl:value-of select="TotalPrice"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="main-table-line-vat-cell">
        <fo:block xsl:use-attribute-sets="main-table-line-vat-block">
          <xsl:value-of select="VAT"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
  <xsl:template match="Taxes/VAT">
    <fo:table-row xsl:use-attribute-sets="vat-table-line-row" keep-with-next="always" page-break-inside="avoid">
      <fo:table-cell xsl:use-attribute-sets="vat-table-line-code-cell">
        <fo:block>
          <xsl:value-of select="Code"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="vat-table-line-total-duty-free-price-cell">
        <fo:block>
          <xsl:value-of select="TotalDutyFreePrice"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="vat-table-line-coefficient-cell">
        <fo:block>
          <xsl:value-of select="Coefficient"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="vat-table-line-total-inclusive-of-tax-price-cell">
        <fo:block>
          <xsl:value-of select="TotalInclusiveOfTaxPrice"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row> 
  </xsl:template>
  <xsl:template match="DueDates/DueDate" mode="DueDates">
    <fo:table-row keep-with-next="always" page-break-inside="avoid">
      <fo:table-cell xsl:use-attribute-sets="due-dates-table-line-date-cell">
        <fo:block-container xsl:use-attribute-sets="due-dates-table-line-date-block-container">
          <fo:block xsl:use-attribute-sets="due-dates-table-line-date-block">
            <xsl:value-of select="Date"/>
          </fo:block>
        </fo:block-container>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="due-dates-table-line-total-cell">
        <fo:block-container xsl:use-attribute-sets="due-dates-table-line-total-block-container">
          <fo:block xsl:use-attribute-sets="due-dates-table-line-total-block">
            <xsl:value-of select="Total"/>
          </fo:block>
        </fo:block-container>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
  <xsl:template match="DueDates/DueDate" mode="FormToCut">
    <fo:table-row xsl:use-attribute-sets="form-to-cut-table-line-row" keep-with-next="always" page-break-inside="avoid">
      <fo:table-cell xsl:use-attribute-sets="form-to-cut-table-line-date-cell">
        <fo:block-container xsl:use-attribute-sets="form-to-cut-table-line-date-block-container">
          <fo:block xsl:use-attribute-sets="form-to-cut-table-line-date-block">
            <xsl:value-of select="Date"/>
          </fo:block>
        </fo:block-container>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="form-to-cut-table-line-reference-cell">
        <fo:block-container xsl:use-attribute-sets="form-to-cut-table-line-reference-block-container">
          <fo:block xsl:use-attribute-sets="form-to-cut-table-line-reference-block">
            <xsl:value-of select="../../Reference"/>
          </fo:block>
        </fo:block-container>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="form-to-cut-table-line-total-cell">
        <fo:block-container xsl:use-attribute-sets="form-to-cut-table-line-total-block-container">
          <fo:block xsl:use-attribute-sets="form-to-cut-table-line-total-block">
            <xsl:value-of select="Total"/>
          </fo:block>
        </fo:block-container>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
  <xsl:template match="DueDates/DueDate" mode="Scissors">
    <fo:table-row>
      <fo:table-cell xsl:use-attribute-sets="scissors-cell">
        <fo:block>
          <fo:external-graphic xsl:use-attribute-sets="scissors-image" src="../images/scissors.png"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
</xsl:stylesheet>

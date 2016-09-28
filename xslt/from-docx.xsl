<?xml version="1.0" encoding="UTF-8"?>
<!--
From DOCX to RASH XSLT transformation file - Version 1.0, December 25, 2015
by Alberto Nicoletti, based on a work from Silvio Peroni

This work is licensed under a Creative Commons Attribution 4.0 International License (http://creativecommons.org/licenses/by/4.0/).
You are free to:
* Share - copy and redistribute the material in any medium or format
* Adapt - remix, transform, and build upon the material
for any purpose, even commercially.

The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:
* Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
-->
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://illbe.xyz/XSLT/function"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
    xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
    xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
    xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes"
    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
    exclude-result-prefixes="xs xd f xlink svg dc fo meta w r">

    <xsl:include href="omml2mml.xsl"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 25, 2015</xd:p>
            <xd:p><xd:b>Author:</xd:b> Silvio Peroni</xd:p>
            <xd:p>This XSLT document allows the conversion of any DOCX document into RASH.</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output
        encoding="UTF-8"
        method="xml"
        indent="yes" />

    <!--
        This parameters refers to the base path that all the URL of the CSS files
        of the final RASH document should have.
    -->
    <xsl:param name="basecss" select="'./css/'" />

    <!--
        This parameters refers to the base path that all the URL of the Javascript files
        of the final RASH document should have.
    -->
    <xsl:param name="basejs" select="'./js/'" />

    <!--
        This parameters refers to the base path that all the URL of the RelaxNG files
        of the final RASH document should have.
    -->
    <xsl:param name="baserng" select="'./'" />

    <!--
        This parameters refers to the base path that all the URL of the image files
        of the final RASH document should have.
    -->
    <xsl:param name="baseimg" select="'./img'" />

    <!--
        This parameters refers to the directory that contains the actual XML content
        of the ODT document to transform.
    -->
    <xsl:param name="dir" select="'./workingdir/word/'" />
    <!--<xsl:param name="dir" select="'../testbed/docx/testbed-8/word/'" />-->

    <!-- This variable is used to remove separators in captions -->
    <xsl:variable name="subcap" select="'^[!,\.:;\?\|\-\s]+'" as="xs:string" />

    <!--
        These variables are used for identifying the text of the headings referring to the
        sections abstract, acknowledgements and bibliography
    -->
    <xsl:variable name="abstract" select="('abstract', 'summary')" as="xs:string+" />
    <xsl:variable name="acknowledgements" select="('acknowledgements', 'acknowledgement')" as="xs:string+" />
    <xsl:variable name="bibliography" select="('bibliography', 'references', 'reference')" as="xs:string+" />

    <!-- Link references document -->
    <xsl:variable name="links" select="doc(concat($dir, '/_rels/document.xml.rels'))" as="item()?" />

    <!-- Link styles document -->
    <xsl:variable name="styles" select="doc(concat($dir, '/styles.xml'))" as="item()?" />

    <!-- Link numbering document -->
    <xsl:variable name="numbering" select="doc(concat($dir, '/numbering.xml'))" as="item()?" />

    <!-- Link meta document -->
    <xsl:variable name="metaExists" select="doc-available(concat($dir, '/../docProps/custom.xml'))" as="xs:boolean" />
    <xsl:variable name="meta" select="doc(concat($dir, '/../docProps/custom.xml'))" as="item()?" />

    <xsl:variable name="footnotesExists" select="doc-available(concat($dir, '/footnotes.xml'))" as="xs:boolean" />
    <xsl:variable name="footnotes" select="doc(concat($dir, '/footnotes.xml'))" as="item()?" />

    <xd:doc scope="/">
        <xd:desc>
            <xd:p>This template is in charge of starting the transformation.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates>
            <xsl:with-param name="isInsideBlock" select="false()" tunnel="yes" as="xs:boolean" />
            <xsl:with-param name="caption" select="false()" tunnel="yes" as="xs:boolean" />
        </xsl:apply-templates>
    </xsl:template>

    <xd:doc scope="w:body">
        <xd:desc>
            <xd:p>This template is in charge of creating the whole structure of the document in RASH.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:body">
        <xsl:processing-instruction name="xml-model">href="<xsl:value-of select="$baserng" />rash.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>

        <html
            xmlns="http://www.w3.org/1999/xhtml"
            prefix="schema: http://schema.org/ prism: http://prismstandard.org/namespaces/basic/2.0/">
            <head>
                <!-- Visualisation requirements (mandatory for optimal reading) -->
                <meta charset="UTF-8"></meta>
                <meta name="viewport" content="width=device-width, initial-scale=1"></meta>
                <link rel="stylesheet" href="{$basecss}bootstrap.min.css"></link>
                <link rel="stylesheet" href="{$basecss}rash.css"></link>
                <script src="{$basejs}jquery.min.js"><xsl:text> </xsl:text></script>
                <script src="{$basejs}bootstrap.min.js"><xsl:text> </xsl:text></script>
                <script src="{$basejs}rash.js"><xsl:text> </xsl:text></script>
                <script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"><xsl:text> </xsl:text></script>
                <!-- /END Visualisation requirements (mandatory for optimal reading) -->

                <xsl:call-template name="add.title" />
                <xsl:call-template name="add.meta" />
            </head>
            <body>
                <xsl:choose>
                    <xsl:when test="element()[f:isHeading(.)]">
                        <!-- Call all the elements before the first heading (if any) -->
                        <xsl:apply-templates select="element()[f:isHeading(.)][1]/preceding-sibling::element()" />

                        <!-- Call all the remaining elements (i.e., starting from the first heading) -->
                        <xsl:apply-templates select="element()[f:isHeading(.)][1]" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Call all the elements (base case) -->
                        <xsl:apply-templates />
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:call-template name="add.footnotes" />
            </body>
        </html>
    </xsl:template>

    <xd:doc scope="w:p">
        <xd:desc>
            <xd:p>This template is in charge of handling common paragraphs.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:p">
        <xsl:call-template name="add.p">
            <xsl:with-param name="isInsideList" select="false()" />
        </xsl:call-template>
    </xsl:template>

    <xd:doc scope="w:r">
        <xd:desc>
            <xd:p>This template handles all the inline textual elements that appear in the context of a paragraph, excluding links.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:r">
        <xsl:param name="isInsideBlock" as="xs:boolean" tunnel="yes" />
        <xsl:variable name="isBold" select="exists(w:rPr/w:b)" as="xs:boolean" />
        <xsl:variable name="isItalic" select="exists(w:rPr/w:i)" as="xs:boolean" />
        <xsl:variable name="isCourier" select="exists(w:rPr/w:rFonts[contains(@w:ascii, 'Courier')])" as="xs:boolean" />
        <xsl:variable name="isSuperscript" select="w:rPr/w:vertAlign/@w:val = 'superscript'" as="xs:boolean" />
        <xsl:variable name="isSubscript" select="w:rPr/w:vertAlign/@w:val = 'subscript'" as="xs:boolean" />
        <xsl:variable name="isNote" select="f:isNote(.)" as="xs:boolean" />
        <xsl:variable name="isImage" select="f:rHasAnImage(.)" as="xs:boolean" />

        <!-- If the immediately previous element doesn't have the same style then proceed -->
        <xsl:variable name="previousElementSameStyle" as="xs:boolean">
            <xsl:variable name="prev" select="f:getPreceding(.)[last()]" as="item()?" />
            <xsl:variable name="prevIsBold" select="exists($prev/w:rPr/w:b)" as="xs:boolean" />
            <xsl:variable name="prevIsItalic" select="exists($prev/w:rPr/w:i)" as="xs:boolean" />
            <xsl:variable name="prevIsCourier" select="exists($prev/w:rPr/w:rFonts[contains(@w:ascii, 'Courier')])" as="xs:boolean" />
            <xsl:variable name="prevIsSuperscript"
                          select="$prev/w:rPr/w:vertAlign/@w:val = 'superscript'" as="xs:boolean" />
            <xsl:variable name="prevIsSubscript"
                          select="$prev/w:rPr/w:vertAlign/@w:val = 'subscript'" as="xs:boolean" />
            <xsl:variable name="prevIsNote" select="f:isNote($prev)" as="xs:boolean" />
            <xsl:variable name="prevIsImage" select="f:rHasAnImage($prev)" as="xs:boolean" />
            <xsl:value-of select="$prev[self::w:r] and
                $isBold = $prevIsBold and $isItalic = $prevIsItalic and $isCourier = $prevIsCourier and
                $isSuperscript = $prevIsSuperscript and $isSubscript = $prevIsSubscript and $isNote = $prevIsNote and $isImage = $prevIsImage" />
        </xsl:variable>

        <xsl:if test="not($previousElementSameStyle)">
            <!-- The following elements that doesn't have the same kind of text -->
            <xsl:variable name="follTNotEqual" as="element()*">
                <xsl:for-each select="f:getFollowing(.)">
                    <xsl:variable name="follIsBold" select="exists(w:rPr/w:b)" as="xs:boolean" />
                    <xsl:variable name="follIsItalic" select="exists(w:rPr/w:i)" as="xs:boolean" />
                    <xsl:variable name="follIsCourier" select="exists(w:rPr/w:rFonts[contains(@w:ascii, 'Courier')])" as="xs:boolean" />
                    <xsl:variable name="follIsSuperscript" select="w:rPr/w:vertAlign/@w:val = 'superscript'" as="xs:boolean" />
                    <xsl:variable name="follIsSubscript" select="w:rPr/w:vertAlign/@w:val = 'subscript'" as="xs:boolean" />
                    <xsl:variable name="follIsNote" select="f:isNote(.)" as="xs:boolean" />
                    <xsl:variable name="follIsImage" select="f:rHasAnImage(.)" as="xs:boolean" />
                    <xsl:if test="not(self::w:r) or not(
                        $isBold = $follIsBold and $isItalic = $follIsItalic and $isCourier = $follIsCourier and
                        $isSuperscript = $follIsSuperscript and $isSubscript = $follIsSubscript and $isNote = $follIsNote and $isImage = $follIsImage)">
                        <xsl:sequence select="." />
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <!-- All the following elements that have the same kind of text -->
            <xsl:variable name="follTEqual" as="element()*">
                <xsl:for-each select="f:getFollowing(.)">
                    <xsl:variable name="follIsBold" select="exists(w:rPr/w:b)" as="xs:boolean" />
                    <xsl:variable name="follIsItalic" select="exists(w:rPr/w:i)" as="xs:boolean" />
                    <xsl:variable name="follIsCourier" select="exists(w:rPr/w:rFonts[contains(@w:ascii, 'Courier')])" as="xs:boolean" />
                    <xsl:variable name="follIsSuperscript" select="w:rPr/w:vertAlign/@w:val = 'superscript'" as="xs:boolean" />
                    <xsl:variable name="follIsSubscript" select="w:rPr/w:vertAlign/@w:val = 'subscript'" as="xs:boolean" />
                    <xsl:variable name="follIsNote" select="f:isNote(.)" as="xs:boolean" />
                    <xsl:variable name="follIsImage" select="f:rHasAnImage(.)" as="xs:boolean" />
                    <xsl:if test="
                        self::w:r and
                        $isBold = $follIsBold and $isItalic = $follIsItalic and $isCourier = $follIsCourier and
                        $isSuperscript = $follIsSuperscript and $isSubscript = $follIsSubscript and $isNote = $follIsNote and $isImage = $follIsImage">
                        <xsl:sequence select="." />
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:call-template name="add.inline">
                <xsl:with-param name="select"
                                select="(w:t, ($follTEqual except ($follTNotEqual, f:getFollowing($follTNotEqual)))/w:t)" tunnel="yes" />
                <xsl:with-param name="super" as="xs:boolean" tunnel="yes" select="$isSuperscript and not($isInsideBlock)" />
                <xsl:with-param name="sub" as="xs:boolean" tunnel="yes" select="$isSubscript and not($isInsideBlock)" />
                <xsl:with-param name="bold" as="xs:boolean" tunnel="yes" select="$isBold and not($isInsideBlock)" />
                <xsl:with-param name="italic" as="xs:boolean" tunnel="yes" select="$isItalic and not($isInsideBlock)" />
                <xsl:with-param name="courier" as="xs:boolean" tunnel="yes" select="$isCourier and not($isInsideBlock)" />
                <xsl:with-param name="note" as="xs:boolean" tunnel="yes" select="$isNote and not($isInsideBlock)" />
                <xsl:with-param name="image" as="xs:boolean" tunnel="yes" select="$isImage and not($isInsideBlock)" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="w:hyperlink">
        <xd:desc>
            <xd:p>This template handles all the inline external (i.e., to an external website) links that appear in the context of a paragraph, excluding links.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:hyperlink" xpath-default-namespace="http://schemas.openxmlformats.org/package/2006/relationships">
        <xsl:variable name="id" select="@r:id" as="xs:string" />
        <a href="{$links//Relationship[@Id = $id]/@Target}">
            <xsl:apply-templates />
        </a>
    </xsl:template>

    <xd:doc scope="w:pPr">
        <xd:desc>
            <xd:p>This template is used for avoiding to process certain elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:hyperlink[not(exists(@r:id))] | w:pPr | w:rPr | w:sectPr | w:p[f:getRealStyleNameFromP(.) = 'Title'] | w:p[f:getRealStyleNameFromP(.) = 'Subtitle']" />

    <xd:doc scope="w:r">
        <xd:desc>
            <xd:p>This template creates all the references to dereferanceable objects in the document content (i.e., sections, figures with caption, formulas with caption, and tables).</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:r[w:instrText]">
        <!--<a href="#{w:instrText}"><xsl:text> </xsl:text></a>-->
        <a href="www.google.com">Google</a>
    </xsl:template>

    <xd:doc scope="m:oMathPara">
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="m:oMathPara">
        <xsl:variable name="thereIsCaption"
                      as="xs:boolean"
                      select="f:pIsCaption(following::w:p[1])"
        />
        <figure>
            <p>
                <xsl:apply-templates />
            </p>
            <xsl:if test="$thereIsCaption">
                <xsl:variable name="captionParagraph"
                              as="element()"
                              select="following::w:p[1]" />
                <xsl:call-template name="add.caption" >
                    <xsl:with-param name="captionParagraph" select="$captionParagraph" />
                </xsl:call-template>
            </xsl:if>
        </figure>
    </xsl:template>

    <xd:doc scope="m:oMath">
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="m:oMath">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
            <!--<semantics>-->
                <xsl:apply-templates />
            <!--</semantics>-->
        </math>
    </xsl:template>

    <xd:doc scope="w:tbl">
        <xd:desc>
            <xd:p>This template creates new table boxes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:tbl">
        <xsl:variable name="thereIsCaption"
                      as="xs:boolean"
                      select="f:pIsCaption(following-sibling::w:p[1])"
        />
        <!--<xsl:variable name="caption" select="following-sibling::text:p[normalize-space() != ''][1][(@text:style-name = 'Table') or (some $s in //style:style[@style:parent-style-name = 'Table']/@style:name satisfies @text:style-name = $s)]" as="element()?" />-->
        <figure>
            <!--<xsl:call-template name="set.captioned.object.id">-->
                <!--<xsl:with-param name="caption" select="$caption" />-->
            <!--</xsl:call-template>-->
            <table>
                <xsl:apply-templates />
            </table>
            <xsl:if test="$thereIsCaption">
                <xsl:variable name="captionParagraph"
                              as="element()"
                              select="following-sibling::w:p[1]" />
                <xsl:call-template name="add.caption" >
                    <xsl:with-param name="captionParagraph" select="$captionParagraph" />
                </xsl:call-template>
            </xsl:if>
            <!--<xsl:call-template name="add.caption">-->
                <!--<xsl:with-param name="caption" select="f:getCaptionNodes($caption)" />-->
            <!--</xsl:call-template>-->
        </figure>
    </xsl:template>

    <xd:doc scope="w:tr">
        <xd:desc>
            <xd:p>This template creates table rows.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:tr">
        <xsl:variable name="isHeading"
                      as="xs:boolean"
                      select="./preceding-sibling::w:tblPr/w:tblLook/@w:firstRow = 1
                        and (not(exists(./preceding-sibling::w:tr)))"
        />
        <tr>
            <xsl:apply-templates>
                <xsl:with-param name="isHeading" select="$isHeading" tunnel="yes" />
            </xsl:apply-templates>
        </tr>
    </xsl:template>

    <xd:doc scope="w:tc">
        <xd:desc>
            <xd:p>This template creates new table heading cells.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="w:tc">
        <xsl:param name="isHeading" as="xs:boolean" tunnel="yes" />
        <xsl:choose>
            <xsl:when test="$isHeading">
                <th>
                    <xsl:apply-templates select=".//w:t" />
                </th>
            </xsl:when>
            <xsl:otherwise>
                <td>
                    <xsl:apply-templates />
                </td>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <!--<xd:doc scope="w:tc">-->
        <!--<xd:desc>-->
            <!--<xd:p>This template creates new table content cells.</xd:p>-->
        <!--</xd:desc>-->
    <!--</xd:doc>-->
    <!--<xsl:template match="w:tc">-->
        <!--<td>-->
            <!--<xsl:choose>-->
                <!--<xsl:when test="normalize-space() = ''">-->
                    <!--<p><xsl:text> </xsl:text></p>-->
                <!--</xsl:when>-->
                <!--<xsl:otherwise>-->
                    <!--<xsl:apply-templates />-->
                <!--</xsl:otherwise>-->
            <!--</xsl:choose>-->
        <!--</td>-->
    <!--</xsl:template>-->

    <xd:doc scope="element()">
        <xd:desc>
            <xd:p>This template continues the processing of its child elements without adding any markup.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="element()">
        <xsl:apply-templates />
    </xsl:template>

    <xd:doc scope="text()">
        <xd:desc>
            <xd:p>This template handles all text nodes and, in case there is an inline quotation, it adds the appropriate element to the RASH document.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="text()">
        <xsl:value-of select="." />
    </xsl:template>

    <xd:doc scope="add.p">
        <xd:desc>
            <xd:p>This template is in charge of handling common paragraphs.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.p">
        <xsl:param name="isInsideList" as="xs:boolean" />
        <xsl:variable name="parent" select="parent::w:body" as="element()?" />
        <xsl:choose>
            <xsl:when test="f:pIsCaption(.) or (f:pIsBetweenTwoListItems(.) and not($isInsideList))">
                <!--Ignore-->
            </xsl:when>
            <!-- Headings -->
            <xsl:when test="f:isHeading(.)">
                <xsl:call-template name="create.section.with.heading" />
            </xsl:when>
            <!-- When a pure text paragraph is defined in the DOCX document without providing any particular structured
            organisation of it into a paper (such as defining headings), a section is created automatically in the final
            RASH document. -->
            <xsl:when test="$parent and f:getContentChildElements($parent)[1] is .">
                <xsl:call-template name="create.untitled.section" />
            </xsl:when>
            <xsl:when test="f:isPreformattedParagraph(.)">
                <xsl:call-template name="add.blockOfCode" />
            </xsl:when>
            <xsl:when test="contains(f:getRealStyleNameFromP(.), 'Quote')">
                <xsl:call-template name="add.quote" />
            </xsl:when>
            <xsl:when test="f:pIsListElement(.) and not($isInsideList)">
                <xsl:if test="f:isFirstListItem(.)">
                    <xsl:call-template name="add.list" />
                </xsl:if>
            </xsl:when>
            <xsl:when test="f:pIsListingBox(.)">
                <xsl:call-template name="add.listingBox" />
            </xsl:when>
            <xsl:when test="f:rHasAnImage(.) and not(f:containsText(.))">
                <figure>
                    <p>
                        <xsl:call-template name="add.image" />
                    </p>
                </figure>
            </xsl:when>
            <!-- This is the basic case for the creation of paragraphs. -->
            <xsl:otherwise>
                <!--<xsl:if test="f:containsText(.)">-->
                    <p>
                        <xsl:apply-templates />
                    </p>
                <!--</xsl:if>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc scope="add.quote">
        <xd:desc>
            <xd:p>This template is in charge of handling a cited paragraph.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.quote">
        <blockquote><p>
            <xsl:apply-templates />
        </p></blockquote>
    </xsl:template>

    <xd:doc scope="add.caption">
        <xd:desc>
            <xd:p>This named template is in charge of creating captions to figures or tables.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.caption">
        <xsl:param name="captionParagraph" as="element()" />
        <xsl:variable name="captionNodes" as="node()*" select="f:getCaptionNodes($captionParagraph/descendant::w:r)" />
        <!--<xsl:variable name="ftn" select="($caption//text())[1]" as="text()?" />-->
        <figcaption>
            <xsl:choose>
                <xsl:when test="exists($captionNodes)">
                    <xsl:for-each select="$captionNodes">
                        <xsl:apply-templates select="." />
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    No caption has been provided.
                </xsl:otherwise>
            </xsl:choose>
        </figcaption>
    </xsl:template>

    <xd:doc scope="add.blockOfCode">
        <xd:desc>
            <xd:p>This template is in charge of handling a sequence of paragraph that defines a block of code.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.blockOfCode">
        <xsl:variable name="prevp" select="preceding-sibling::w:p[1]" as="element()?"/>
        <xsl:if test="not($prevp) or not(f:isPreformattedParagraph($prevp))">
            <xsl:variable name="allCodes"
                          as="element()*"
                          select="following-sibling::w:p"
            />
            <xsl:variable name="followingNotCodes"
                          as="element()*"
                          select="following-sibling::w:p[not(f:isPreformattedParagraph(.))]"
            />
            <pre><code>
                <xsl:for-each select="(., $allCodes) except $followingNotCodes/(.|following-sibling::element())">
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:apply-templates />
                </xsl:for-each>
            </code></pre>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="add.listingBox">
        <xd:desc>
            <xd:p>This template is in charge of creating the listing boxes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.listingBox">
        <xsl:variable name="textbox"
                      as="element()"
                      select="w:r/mc:AlternateContent/mc:Choice/w:drawing/wp:inline/a:graphic/a:graphicData/wps:wsp/wps:txbx"/>
        <xsl:variable name="thereIsCaption"
                      as="xs:boolean"
                      select="f:pIsCaption(following-sibling::w:p[1])"
        />
        <figure>
            <pre><code>
                <xsl:for-each select="$textbox/w:txbxContent/w:p">
                    <xsl:apply-templates>
                        <xsl:with-param name="isInsideBlock" tunnel="yes" as="xs:boolean" select="true()" />
                    </xsl:apply-templates>
                    <xsl:if test="position() != last()">
                        <!-- Add a \n character if it is not the last paragraph -->
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </code></pre>
            <xsl:if test="$thereIsCaption">
                <xsl:variable name="captionParagraph"
                              as="element()"
                              select="following-sibling::w:p[1]" />
                <xsl:call-template name="add.caption" >
                    <xsl:with-param name="captionParagraph" select="$captionParagraph" />
                </xsl:call-template>
            </xsl:if>
        </figure>
    </xsl:template>

    <xd:doc scope="add.image">
        <xd:desc>
            <xd:p>This template is used for avoiding to process certain elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.image" xpath-default-namespace="http://schemas.openxmlformats.org/package/2006/relationships">
        <xsl:variable name="thereIsCaption"
                      as="xs:boolean"
                      select="f:pIsCaption(following::w:p[1])"
        />
        <xsl:variable name="imageId"
                      as="xs:string"
                      select=".//pic:blipFill/a:blip/@r:embed"
        />
        <img src="{$baseimg}/{substring-after(f:getImageNameById($imageId), 'media/')}"
                 alt="Alt" />
        <xsl:if test="$thereIsCaption">
            <xsl:variable name="captionParagraph"
                          as="element()"
                          select="following::w:p[1]" />
            <xsl:call-template name="add.caption" >
                <xsl:with-param name="captionParagraph" select="$captionParagraph" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="add.list">
        <xd:desc>
            <xd:p>This template is in charge of handling lists.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.list">
        <xsl:variable name="currentNumId"
                      as="xs:integer"
                      select="w:pPr/w:numPr/w:numId/@w:val"
        />
        <xsl:variable name="isFirstElement"
                      as="xs:boolean"
                      select="
                          not(
                              exists(
                                  preceding-sibling::w:p[f:pIsListElement(.)]
                              )
                          )
                        or
                          preceding-sibling::w:p[f:pIsListElement(.)][1]/w:pPr/w:numPr/w:numId/@w:val
                          !=
                          $currentNumId
                        "
        />
        <xsl:if test="$isFirstElement">
            <xsl:variable name="thisListItems"
                          as="element()*"
                          select="f:getListItems(.)"
            />
            <xsl:if test="f:isBullet($currentNumId)">
                <ul>
                    <xsl:call-template name="add.listItems">
                        <xsl:with-param name="listElements" as="element()*" select="$thisListItems"/>
                    </xsl:call-template>
                </ul>
            </xsl:if>
            <xsl:if test="not(f:isBullet($currentNumId))">
                <ol>
                    <xsl:call-template name="add.listItems">
                        <xsl:with-param name="listElements" as="element()*" select="$thisListItems"/>
                    </xsl:call-template>
                </ol>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="add.listItems" >
        <xd:desc>
            <xd:p>This template handles the list items</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.listItems">
        <xsl:param name="listElements" as="element()*" />
        <xsl:for-each select="$listElements">
            <xsl:variable name="nextParagraphsNotInList"
                          as="element()*"
                          select="following-sibling::w:p[not(f:pIsListElement(.))]"
            />
            <xsl:variable name="nextListItemIndex"
                          as="xs:integer"
                          select="position()+1"
            />
            <xsl:variable name="paragraphs"
                          as="element()*"
                          select="$nextParagraphsNotInList intersect $listElements[$nextListItemIndex]/preceding-sibling::w:p"
            />
            <li>
                <xsl:if test="some $content in $bibliography satisfies lower-case(normalize-space(preceding::w:p[f:isHeading(.)][1])) = $content">
                    <xsl:attribute name="role">doc-biblioentry</xsl:attribute>
                </xsl:if>
                <xsl:call-template name="add.p">
                    <xsl:with-param name="isInsideList" select="true()"/>
                </xsl:call-template>
                <xsl:for-each select="$paragraphs">
                    <xsl:call-template name="add.p">
                        <xsl:with-param name="isInsideList" select="true()"/>
                    </xsl:call-template>
                </xsl:for-each>
            </li>
        </xsl:for-each>
    </xsl:template>

    <xd:doc scope="add.notes">
        <xd:desc>
            <xd:p>This template is in charge of handling references to footnotes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.notes">
        <a href="#ftn{w:footnoteReference/@w:id}"><xsl:text> </xsl:text></a>
    </xsl:template>

    <xd:doc scope="add.meta">
        <xd:desc>
            <xd:p>This named template is in charge of handling the head data of the document, i.e., authors, emails, affiliations, keywords, categories.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.meta" xpath-default-namespace="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties">
        <xsl:if test="$metaExists">
            <!-- Affiliations -->
            <xsl:variable name="aff" as="xs:string*">
                <xsl:variable name="afflist" as="xs:string*">
                    <xsl:for-each select="$meta//property[matches(@name, '^ *(A|a)uthor', 'i')]/vt:lpwstr/text()">
                        <xsl:variable name="tokens" select="tokenize(., '--')" as="xs:string*" />
                        <xsl:variable name="len" select="count($tokens)" as="xs:integer" />
                        <xsl:if test="$len > 2">
                            <xsl:value-of select="normalize-space($tokens[3])" />
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="distaff" select="distinct-values($afflist)" as="xs:string*" />
                <xsl:sequence select="(for $a in $distaff return lower-case($a), $distaff)" />
            </xsl:variable>
            <xsl:variable name="afflen" select="xs:integer(count($aff) div 2)" as="xs:integer" />
            <xsl:for-each select="$aff[position() > $afflen]">
                <meta about="#affiliation-{position()}" property="schema:name" content="{.}" />
            </xsl:for-each>

            <!-- Author -->
            <xsl:for-each select="$meta//property[matches(@name, '^ *(A|a)uthor', 'i')]/vt:lpwstr/text()">
                <xsl:variable name="authiri" select="concat('#author-', position())" as="xs:string" />
                <xsl:variable name="tokens" select="tokenize(., '--')" as="xs:string*" />
                <xsl:variable name="len" select="count($tokens)" as="xs:integer" />
                <xsl:if test="$len > 0">
                    <meta about="{$authiri}" name="dc.creator" property="schema:name"
                          content="{normalize-space($tokens[1])}"/>
                    <xsl:if test="$len > 1">
                        <meta about="{$authiri}" property="schema:email" content="{normalize-space($tokens[2])}" />
                        <xsl:if test="$len > 2">
                            <xsl:variable name="idx"
                                          select="index-of($aff, lower-case(normalize-space($tokens[3])))" as="xs:integer*" />
                            <xsl:if test="$idx">
                                <link about="{$authiri}" property="schema:affiliation"
                                      href="#affiliation-{$idx[1]}" />
                            </xsl:if>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>

            <!-- Keywords -->
            <xsl:for-each select="$meta//property[matches(@name, '^ *(K|k)eyword?', 'i')]/vt:lpwstr/text()">
                <xsl:for-each select="tokenize(., '--')">
                    <meta property="prism:keyword" content="{normalize-space()}" />
                </xsl:for-each>
            </xsl:for-each>

            <!-- Categories -->
            <xsl:for-each select="$meta//property[matches(@name, '^ *(C|c)ategor(y|ies)', 'i')]/vt:lpwstr/text()">
                <xsl:for-each select="tokenize(., '--')">
                    <meta name="dcterms.subject" content="{normalize-space()}" />
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="add.footnotes">
        <xd:desc>
            <xd:p>This named template is in change of handling all the footnotes contained in the paper.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.footnotes">
        <xsl:if test="$footnotesExists">
            <!-- Select only the paragraphs containing text -->
            <xsl:variable name="footnoteElements" select="$footnotes//w:footnote[descendant-or-self::text()]" as="element()*" />
            <section role="doc-footnotes">
                <xsl:for-each select="$footnoteElements">
                    <section id="ftn{./@w:id}" role="doc-footnote">
                        <xsl:apply-templates />
                    </section>
                </xsl:for-each>
            </section>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="get.following.content.elements">
        <xd:desc>
            <xd:p>This named template allow one to get all the content elements after the first one. Since this particular sequence of element is used by different templates (e.g., for headings), the call has been implemented as a named template.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="get.following.content.elements">
        <xsl:param name="curlev" select="1" as="xs:integer" />

        <xsl:variable name="seq" select="for $v in (1 to $curlev) return $v" as="xs:integer+" />
        <xsl:variable name="level" select="string($curlev)" as="xs:string" />
        <xsl:apply-templates select="(following-sibling::w:p[f:isHeading(.)])[some $l in $seq satisfies f:getLevel(.) = $l][1][f:getLevel(.) = $curlev]" />
    </xsl:template>

    <xd:doc scope="add.inline">
        <xd:desc>
            <xd:p>This named template is in change of handling all the inline textual elements that may appear within a paragraph. The links are handled in another appropriate template.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="add.inline">
        <xsl:param name="select" as="item()*" tunnel="yes" />
        <xsl:param name="bold" as="xs:boolean" tunnel="yes" />
        <xsl:param name="italic" as="xs:boolean" tunnel="yes" />
        <xsl:param name="super" as="xs:boolean" tunnel="yes" />
        <xsl:param name="sub" as="xs:boolean" tunnel="yes" />
        <xsl:param name="courier" as="xs:boolean" tunnel="yes" />
        <xsl:param name="note" as="xs:boolean" tunnel="yes" />
        <xsl:param name="image" as="xs:boolean" tunnel="yes" />
        <xsl:choose>
            <xsl:when test="$super">
                <sup>
                    <xsl:call-template name="add.inline">
                        <xsl:with-param name="super" tunnel="yes" as="xs:boolean" select="false()" />
                    </xsl:call-template>
                </sup>
            </xsl:when>
            <xsl:when test="$sub">
                <sub>
                    <xsl:call-template name="add.inline">
                        <xsl:with-param name="sub" tunnel="yes" as="xs:boolean" select="false()" />
                    </xsl:call-template>
                </sub>
            </xsl:when>
            <xsl:when test="$bold">
                <strong>
                    <xsl:call-template name="add.inline">
                        <xsl:with-param name="bold" tunnel="yes" as="xs:boolean" select="false()" />
                    </xsl:call-template>
                </strong>
            </xsl:when>
            <xsl:when test="$italic">
                <em>
                    <xsl:call-template name="add.inline">
                        <xsl:with-param name="italic" tunnel="yes" as="xs:boolean" select="false()" />
                    </xsl:call-template>
                </em>
            </xsl:when>
            <xsl:when test="$courier">
                <code>
                    <xsl:call-template name="add.inline">
                        <xsl:with-param name="courier" tunnel="yes" as="xs:boolean" select="false()" />
                    </xsl:call-template>
                </code>
            </xsl:when>
            <xsl:when test="$note">
                <a href="#ftn{w:footnoteReference/@w:id}">
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="add.inline">
                        <xsl:with-param name="note" tunnel="yes" as="xs:boolean" select="false()" />
                    </xsl:call-template>
                </a>
            </xsl:when>
            <xsl:when test="$image">
                <xsl:call-template name="add.image" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$select"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="add.title">
        <xsl:variable name="title"
                      select="//w:p[f:getRealStyleNameFromP(.) = 'Title'][1]" as="element()?" />
        <xsl:variable name="subtitle"
                      select="//w:p[f:getRealStyleNameFromP(.) = 'Subtitle'][1]" as="element()?" />
        <title>
            <xsl:choose>
                <xsl:when test="normalize-space($title) != ''">
                    <xsl:value-of select="$title" />
                    <xsl:if test="normalize-space($subtitle) != ''">
                        <xsl:text> -- </xsl:text>
                        <xsl:value-of select="$subtitle" />
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>No title specified</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </title>
    </xsl:template>

    <xd:doc scope="set.section.type">
        <xd:desc>
            <xd:p>This named template set the type of a section if any ('section' is the default).</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="set.section.type">
        <xsl:variable name="content" select="lower-case(normalize-space(string-join(.//w:t, '')))" as="xs:string" />

        <xsl:choose>
            <xsl:when test="some $item in $abstract satisfies $content = $item">
                <xsl:attribute name="role" select="'doc-abstract'" />
            </xsl:when>
            <xsl:when test="some $item in $acknowledgements satisfies $content = $item">
                <xsl:attribute name="role" select="'doc-acknowledgements'" />
            </xsl:when>
            <xsl:when test="some $item in $bibliography satisfies $content = $item">
                <xsl:attribute name="role" select="'doc-bibliography'" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc scope="create.section.with.heading">
        <xd:desc>
            <xd:p>This named template creates the section according the particular heading in consideration.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="create.section.with.heading">
        <xsl:variable name="next.header" select="(following-sibling::w:p[f:isHeading(.)])[1]" as="element()*" />
        <xsl:variable name="level" select="f:getLevel(.)" as="xs:integer" />
        <section>
            <xsl:call-template name="set.section.type" />
            <h1>
                <xsl:apply-templates />
            </h1>
            <xsl:apply-templates
                select="(following-sibling::text()|following-sibling::element()) except
                $next.header/(.|following-sibling::text()|following-sibling::element())" />

            <!-- If the next header exists and has a higher level (it is starts a subsection), call it -->
            <xsl:if test="$next.header">
                <xsl:variable name="nextLevel" as="xs:integer" select="f:getLevel($next.header)" />
                <xsl:if test="$nextLevel > xs:integer($level)">
                    <xsl:apply-templates select="$next.header" />
                </xsl:if>
            </xsl:if>
        </section>

        <xsl:call-template name="get.following.content.elements">
            <xsl:with-param name="curlev" select="$level" />
        </xsl:call-template>
    </xsl:template>

    <xd:doc scope="create.section.with.heading">
        <xd:desc>
            <xd:p>This named template creates a new section with no heading and containing the paragraph in consideration.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="create.untitled.section">
        <section>
            <h1>No heading specified</h1>
            <p>
                <xsl:apply-templates />
            </p>
            <xsl:apply-templates select="following-sibling::element()" />
        </section>
    </xsl:template>

    <!-- FUNCTIONS -->
    <xsl:function name="f:listType" as="xs:string">
        <xsl:param name="listId" as="xs:integer"/>
        <xsl:variable name="abstractNumId"
                      as="xs:integer"
                      select="$numbering//w:num[@w:numId = $listId]/w:abstractNumId/@w:val"
        />
        <xsl:variable name="abstractNumProps"
                      as="element()"
                      select="$numbering//w:abstractNum[@w:abstractNumId = $abstractNumId]"
        />
        <xsl:variable name="listType"
                      as="xs:string"
                      select="$abstractNumProps/w:lvl[@w:ilvl = 0]/w:numFmt/@w:val"
        />
        <xsl:value-of select="$listType"/>
    </xsl:function>

    <xsl:function name="f:isBullet" as="xs:boolean">
        <xsl:param name="listId" as="xs:integer"/>
        <xsl:variable name="isBullet"
                      as="xs:boolean"
                      select="f:listType($listId) = 'bullet'"
        />
        <xsl:value-of select="$isBullet"/>
    </xsl:function>

    <xsl:function name="f:getContentChildElements" as="element()*">
        <xsl:param name="parent" as="element()" />
        <xsl:sequence select="$parent/element()" />
    </xsl:function>

    <xsl:function name="f:getFollowing" as="element()*">
        <xsl:param name="curel" as="element()*" />
        <xsl:sequence select="$curel/(following-sibling::w:r|following-sibling::w:hyperlink)" />
    </xsl:function>
    <xsl:function name="f:getPreceding" as="element()*">
        <xsl:param name="curel" as="element()*" />
        <xsl:sequence select="$curel/(preceding-sibling::w:r|preceding-sibling::w:hyperlink)" />
    </xsl:function>

    <xd:doc scope="f:getLevel">
        <xd:desc>
            <xd:p>This function retrieves the level of a particular logic section of a paper starting from its header element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getLevel" as="xs:integer">
        <xsl:param name="curel" as="element()" />
        <xsl:variable name="value" as="xs:string">
            <xsl:variable name="title-ref" select="$curel/w:pPr/w:pStyle/@w:val" as="xs:string" />
            <xsl:value-of select="$styles//w:style[@w:styleId = $title-ref]/w:name/@w:val" />
        </xsl:variable>
        <xsl:value-of select="xs:integer(substring($value,string-length($value)))" />
    </xsl:function>

    <xd:doc scope="f:isHeading">
        <xd:desc>
            <xd:p>This function checks if a certain paragraph is an header or not.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:isHeading" as="xs:boolean">
        <xsl:param name="curel" as="element()" />
        <xsl:variable name="value" as="xs:string?">
            <xsl:variable name="title-ref" select="$curel/w:pPr/w:pStyle/@w:val" as="xs:string?" />
            <xsl:value-of select="$styles//w:style[@w:styleId = $title-ref]/w:name/@w:val" />
        </xsl:variable>
        <xsl:value-of select="starts-with($value, 'heading')" />
    </xsl:function>

    <xd:doc scope="f:getTranslatedPStyleName">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getTranslatedPStyleName" as="xs:string">
        <xsl:param name="element" as="element()?" />
        <xsl:variable name="translatedStyleName" as="xs:string" select="string($element/descendant-or-self::w:pStyle[1]/@w:val)"/>
        <xsl:value-of select="$translatedStyleName"/>
    </xsl:function>

    <xd:doc scope="f:getTranslatedRStyleName">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getTranslatedRStyleName" as="xs:string">
        <xsl:param name="element" as="element()?" />
        <xsl:variable name="translatedStyleName" as="xs:string" select="string($element/descendant-or-self::w:rStyle[1]/@w:val)"/>
        <xsl:value-of select="$translatedStyleName"/>
    </xsl:function>

    <xd:doc scope="f:getRealStyleNameFromTranslatedStyle">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getRealStyleNameFromTranslatedStyle" as="xs:string">
        <xsl:param name="translatedStyle" as="xs:string" />
        <xsl:variable name="realStyle" as="xs:string" select="$styles//w:style[@w:styleId = $translatedStyle]/w:name/@w:val"/>
        <xsl:value-of select="$realStyle"/>
    </xsl:function>

    <xd:doc scope="f:getRealStyleNameFromP">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getRealStyleNameFromP" as="xs:string">
        <xsl:param name="element" as="element()?" />
        <xsl:variable name="translatedStyle" as="xs:string" select="f:getTranslatedPStyleName($element)" />
        <xsl:variable name="realStyle" as="xs:string" select="string($styles//w:style[@w:styleId = $translatedStyle]/w:name/@w:val)"/>
        <xsl:value-of select="$realStyle"/>
    </xsl:function>

    <xd:doc scope="f:getRealStyleNameFromR">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getRealStyleNameFromR" as="xs:string">
        <xsl:param name="element" as="element()?" />
        <xsl:variable name="translatedStyle" as="xs:string" select="f:getTranslatedRStyleName($element)" />
        <xsl:variable name="realStyle" as="xs:string" select="string($styles//w:style[@w:styleId = $translatedStyle]/w:name/@w:val)"/>
        <xsl:value-of select="$realStyle"/>
    </xsl:function>

    <xd:doc scope="f:isPreformattedParagraph">
        <xd:desc>
            <xd:p>This function says whether a particular paragraph is marked as preformatted.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:isPreformattedParagraph" as="xs:boolean">
        <xsl:param name="element" as="element()" />
        <xsl:variable name="isPreformatted"
                      as="xs:boolean"
                      select="f:getRealStyleNameFromP($element) = 'HTML Preformatted'"/>
        <xsl:value-of select="$isPreformatted"/>
    </xsl:function>

    <xd:doc scope="f:pIsListElement">
        <xd:desc>
            <xd:p>This function says whether a paragraph is contained in a list.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:pIsListElement" as="xs:boolean">
        <xsl:param name="element" as="element()?" />
        <xsl:variable name="isListElement"
                      as="xs:boolean"
                      select="f:getRealStyleNameFromP($element) = 'List Paragraph'"
        />
        <xsl:value-of select="$isListElement"/>
    </xsl:function>

    <xd:doc scope="f:isNote">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:isNote" as="xs:boolean">
        <xsl:param name="element" as="element()?" />
        <xsl:variable name="hasNoteStyle"
                      as="xs:boolean"
                      select="f:getRealStyleNameFromR($element) = 'footnote reference'"
        />
        <xsl:variable name="containsFootnoteRef"
                      as="xs:boolean"
                      select="exists($element/descendant-or-self::w:footnoteReference)"
        />
        <xsl:value-of select="$hasNoteStyle and $containsFootnoteRef"/>
    </xsl:function>

    <xd:doc scope="f:pIsListingBox">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:pIsListingBox" as="xs:boolean">
        <xsl:param name="element" as="element()" />
        <xsl:variable name="isListingBox"
                      as="xs:boolean"
                      select="exists($element/w:r/mc:AlternateContent/mc:Choice/w:drawing/wp:inline/a:graphic/a:graphicData/wps:wsp/wps:txbx)"
        />
        <xsl:value-of select="$isListingBox"/>
    </xsl:function>

    <xd:doc scope="f:getListItems">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getListItems" as="element()*">
        <xsl:param name="firstListItem" as="element()" />
        <xsl:variable name="currentNumId"
                      as="xs:integer"
                      select="$firstListItem/w:pPr/w:numPr/w:numId/@w:val"
        />
        <xsl:variable name="nextListsElements"
                      as="element()*"
                      select="$firstListItem/following-sibling::w:p[f:pIsListElement(.)]"
        />
        <xsl:variable name="firstElementOfNextList"
                      as="element()?"
                      select="$firstListItem/following-sibling::w:p[f:pIsListElement(.)][w:pPr/w:numPr/w:numId/@w:val != $currentNumId][1]"
        />
        <xsl:variable name="nextListsElementsNotInTheSameList"
                      as="element()*"
                      select="$firstElementOfNextList/following-sibling::w:p[f:pIsListElement(.)]"
        />
        <xsl:variable name="thisListItems"
                      as="element()*"
                      select="($firstListItem , $nextListsElements) except ($firstElementOfNextList, $nextListsElementsNotInTheSameList)"
        />
        <xsl:sequence select="$thisListItems"/>
    </xsl:function>

    <xd:doc scope="f:isFirstListItem">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:isFirstListItem" as="xs:boolean">
        <xsl:param name="element" as="element()" />
        <xsl:variable name="precedingItem"
                      as="element()?"
                      select="$element/preceding-sibling::w:p[f:pIsListElement(.)][1]"
        />
        <xsl:variable name="nextItem"
                      as="element()?"
                      select="$element/following-sibling::w:p[f:pIsListElement(.)][1]"
        />
        <xsl:value-of select="
                not(exists($precedingItem))
                or ($precedingItem/w:pPr/w:numPr/w:numId/@w:val = $nextItem/w:pPr/w:numPr/w:numId/@w:val)
                or ($precedingItem/w:pPr/w:numPr/w:numId/@w:val != $element/w:pPr/w:numPr/w:numId/@w:val)
            "
        />
    </xsl:function>

    <xd:doc scope="f:pIsBetweenTwoListItems">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:pIsBetweenTwoListItems" as="xs:boolean">
        <xsl:param name="element" as="element()" />
        <xsl:variable name="previousItem"
                      as="element()?"
                      select="$element/preceding-sibling::w:p[1]"
        />
        <xsl:variable name="nextItem"
                      as="element()?"
                      select="$element/following-sibling::w:p[1]"
        />
        <xsl:variable name="isBetweenTwoItems"
                      as="xs:boolean"
                      select="f:pIsListElement($previousItem)
                              and f:pIsListElement($nextItem)
                              and $previousItem/w:pPr/w:numPr/w:numId/@w:val = $nextItem/w:pPr/w:numPr/w:numId/@w:val"
        />
        <xsl:value-of select="$isBetweenTwoItems"/>
    </xsl:function>

    <xd:doc scope="f:pIsCaption">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:pIsCaption" as="xs:boolean">
        <xsl:param name="element" as="element()" />
        <xsl:variable name="previousItem"
                      as="element()?"
                      select="$element/preceding-sibling::w:p[1]"
        />

        <xsl:variable name="isCaption"
                      as="xs:boolean"
                      select="f:getRealStyleNameFromP($element) = 'caption'"
        />
        <xsl:value-of select="$isCaption and exists($previousItem)"/>
    </xsl:function>

    <xd:doc scope="f:rHasAnImage">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:rHasAnImage" as="xs:boolean">
        <xsl:param name="element" as="element()?" />
        <xsl:variable name="image"
                      as="element()?"
                      select="$element/descendant::pic:pic[pic:blipFill/a:blip]"
        />
        <xsl:value-of select="exists($image)"/>
    </xsl:function>

    <xd:doc scope="f:getImageNameById">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getImageNameById" as="xs:string" xpath-default-namespace="http://schemas.openxmlformats.org/package/2006/relationships">
        <xsl:param name="id" as="xs:string" />
        <xsl:variable name="imageName"
                      as="xs:string"
                      select="string($links//Relationship[@Id = $id]/@Target)"
        />
        <xsl:value-of select="$imageName"/>
    </xsl:function>

    <xd:doc scope="f:containsText">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:containsText" as="xs:boolean">
        <xsl:param name="element" as="element()" />
        <xsl:value-of select="exists($element/descendant-or-self::w:t)" />
    </xsl:function>

    <xd:doc scope="f:substringAfterFirstNumber">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:substringAfterFirstNumber" as="xs:string">
        <xsl:param name="s" as="xs:string?" />
        <xsl:variable name="substrings" as="xs:string*">
            <xsl:for-each select="(0 to 9)">
                <xsl:if test="contains($s, string(.))">
                    <xsl:value-of select="substring-after($s, string(.))"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$substrings[1]" />
    </xsl:function>

    <xd:doc scope="f:nodeContainsANumber">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:nodeContainsANumber" as="xs:boolean">
        <xsl:param name="node" as="node()" />
        <xsl:variable name="nodeText"
                      as="xs:string"
                      select="string($node//text())"
        />
        <xsl:value-of select="if (some $i in (0 to 9) satisfies contains($nodeText, string($i))) then true() else false()" />
    </xsl:function>

    <xd:doc scope="f:getCaptionNodes">
        <xd:desc>
            <xd:p>TODO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getCaptionNodes" as="node()*">
        <xsl:param name="nodes" as="node()*" />
        <xsl:variable name="firstNodeContainingANumberIndex"
                      as="xs:integer"
                      select="index-of($nodes, $nodes[f:nodeContainsANumber(.)][1])"
        />
        <xsl:value-of select="subsequence($nodes, $firstNodeContainingANumberIndex + 1)" />
    </xsl:function>

    <!--<xd:doc scope="f:getCaptionText">-->
        <!--<xd:desc>-->
            <!--<xd:p>TODO</xd:p>-->
        <!--</xd:desc>-->
    <!--</xd:doc>-->
    <!--<xsl:function name="f:getCaptionText" as="xs:string">-->
        <!--<xsl:param name="element" as="element()" />-->
        <!--<xsl:variable name="text" as="xs:string">-->
            <!--<xsl:for-each select="$element/descendant-or-self::text()">-->
                <!--<xsl:value-of select="concat($text, .)" />-->
            <!--</xsl:for-each>-->
        <!--</xsl:variable>-->
        <!--<xsl:value-of select="$text" />-->
    <!--</xsl:function>-->

    <!--<xd:doc scope="f:getCaptionNodes">-->
        <!--<xd:desc>-->
            <!--<xd:p>This function returns the caption nodes of a particular image or table.</xd:p>-->
        <!--</xd:desc>-->
    <!--</xd:doc>-->
    <!--<xsl:function name="f:getCaptionNodes" as="node()*">-->
        <!--<xsl:param name="imgel" as="element()" />-->
        <!--<xsl:sequence select="$imgel/ancestor-or-self::text:p[1]/text:sequence/-->
            <!--(following-sibling::element()|following-sibling::text())" />-->
    <!--</xsl:function>-->

</xsl:stylesheet>

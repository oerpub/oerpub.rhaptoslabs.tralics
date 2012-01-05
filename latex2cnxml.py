#! /usr/bin/env python
import sys
import os
import shutil
import urllib2
import subprocess
import libxml2
import libxslt
import tempfile
import glob
import re
from PIL import Image
from lxml import etree
from zipfile import ZipFile, ZIP_DEFLATED, is_zipfile
#import magic

#current_dir = os.path.dirname(__file__) # This does not give the absolute file path
current_dir = os.path.dirname(os.path.abspath(__file__))
XSL_LOCATION = os.path.join(current_dir, 'www')
CNXML_AUTOID_XSL = os.path.join(current_dir, 'www', 'generateIds.xsl')


# ============================================

def writeToGood(binData,strOriginalFileName):
    bSaveToTemp = True
    (strHead, strTail) = os.path.split(strOriginalFileName)
    (strRoot, strExt)  = os.path.splitext(strTail)

    if bSaveToTemp:
        strFileName = tempfile.mktemp(suffix=strExt)
        file = open(strFileName, 'w')
        file.write(binData)
        file.close()

    return strFileName

# TODO
def moveToBad(strFileName):
    pass

def cleanup(strFileName):
    bSaveToTemp = True
    if bSaveToTemp:
        print ("LaTeX2CNXML: Removing: %s" % strFileName)
        os.remove(strFileName)


# === TODO!!! ===
def convert(data, original_filename):
    """Input is a zip file."""

    strOriginalFileName = original_filename
    #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO,
    #         "Original file name is : \"" + strOriginalFileName + "\". User is : \"" + strUserName + "\"")
    print "Latex2CNXML: Original file name is : \"" + strOriginalFileName + "\""

    strHarvestedFileName = writeToGood(data,strOriginalFileName)

    # incoming foo.zip must contain a foo.tex file, where "foo" is the base name.
    (strHead, strTail) = os.path.split(strOriginalFileName)
    (strRoot, strExt)  = os.path.splitext(strTail)
    strBaseName = strRoot

    # creating temp working where we can perform our magic
    strTempWorkingDirectory = tempfile.mkdtemp()

    # special processing for a likely bad input scenario
    if strExt == ".tex":
        #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, '.tex file was input')
        print "Latex2CNXML: .tex file was input"
        # users who do not read documentation land here, where we bail them out
        # create zip file from input .tex file
        texfile=open(strHarvestedFileName)
        bintex=texfile.read()
        texfile.close()

        strZipFile = strTempWorkingDirectory + '/' + strBaseName + '.zip'
        zipfile = ZipFile(strZipFile, 'w', ZIP_DEFLATED)
        zipfile.writestr(strTail, bintex)
        zipfile.close()
    else:
        strZipFile = strHarvestedFileName

    if not is_zipfile(strZipFile):
        #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "expecting a .zip file and got a " + strExt + " file.")
        print "Latex2CNXML: expecting a .zip file and got a " + strExt + " file."
        moveToBad(strHarvestedFileName)
        #raise OOoImportError, "Expecting a .zip file containing your .tex and auxiliary files. Instead got a " + strExt + " file.  See the below LaTeX importer instruction page link for help."
        raise Exception, "Expecting a .zip file containing your .tex and auxiliary files. Instead got a " + strExt + " file.  See the below LaTeX importer instruction page link for help." 

    #strScript = os.getenv('LATEXIMPORT', os.path.join(package_home(GLOBALS), 'LatexImport.bash'))
    strScript = os.path.join(current_dir, "LatexImport.sh")

    args = ['LatexImport.sh', strBaseName, strZipFile, strTempWorkingDirectory, XSL_LOCATION, CNXML_AUTOID_XSL]
    #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO,
    print("Latex2CNXML: " +
             "Calling\n" +
             "\t" + strScript + "\n" +
             "\t\t'" + strBaseName + "'\n" +
             "\t\t'" + strZipFile + "'\n" +
             "\t\t'" + strTempWorkingDirectory + "'\n" +
             "\t\t'" + XSL_LOCATION + "'\n" +
             "\t\t'" + CNXML_AUTOID_XSL + "'")
    rc = os.spawnv(os.P_WAIT, strScript, args)
    if rc != 0:
        #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "LatexImport.bash returned " + str(rc) + " and not zero.")
        print("Latex2CNXML: LatexImport.bash returned " + str(rc) + " and not zero.")
        moveToBad(strHarvestedFileName)
        strTexFile = strTempWorkingDirectory + '/' + strBaseName + '.tex'
        bGivenTexFile = os.path.isfile(strTexFile)
        if bGivenTexFile:
            strDviFile = strTempWorkingDirectory + '/' + strBaseName + '.div'
            strPdfFile = strTempWorkingDirectory + '/' + strBaseName + '.pdf'
            bDivCreated = os.path.isfile(strDviFile)
            bPdfCreated = os.path.isfile(strPdfFile)
            if not bDivCreated:
                #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "latex in LatexImport.bash failed to create a DVI file.")
                print("LaTeX2CNXML: latex in LatexImport.bash failed to create a DVI file.")
                if not bPdfCreated:
                    #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "pdflatex in LatexImport.bash failed to create a PDF file.")
                    print("LaTeX2CNXML: pdflatex in LatexImport.bash failed to create a PDF file.")
                    #raise OOoImportError, "Unable to latex/pdflatex the source .tex file. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
                    raise Exception, "Unable to latex/pdflatex the source .tex file. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
                else:
                    #raise OOoImportError, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
                    raise Exception, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
            else:
                #raise OOoImportError, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
                raise Exception, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
        else:
            #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "Input zip file did not contain a liked named tex file:" + strTexFile)
            print("LaTeX2CNXML: Input zip file did not contain a liked named tex file:" + strTexFile)
            #raise OOoImportError, "The .zip file does not contain a .tex file of the same name. See the below LaTeX importer instruction page link and ensure that your .tex and .zip files have been properly prepared."
            raise Exception, "The .zip file does not contain a .tex file of the same name. See the below LaTeX importer instruction page link and ensure that your .tex and .zip files have been properly prepared."

    strCnxmlFile = strTempWorkingDirectory + '/index.cnxml'
    bCnxmlCreated = os.path.isfile(strCnxmlFile)
    if not bCnxmlCreated:
        # defensive code: should never get here. 
        # import script should return a bad rc if it can not create the cnxml file
        #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "LatexImport.bash did create the cnxml file.")
        print("LaTeX2CNXML: LatexImport.bash did create the cnxml file.")
        moveToBad(strHarvestedFileName)
        raise Exception, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."

    objFile = open(strCnxmlFile, "r")
    strCnxml = objFile.read()
    objFile.close()

    if len(strCnxml) == 0:
        #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "LatexImport.bash created an empty cnxml file.")
        print("LaTeX2CNXML: LatexImport.bash created an empty cnxml file.")
        moveToBad(strHarvestedFileName)
        #raise OOoImportError, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
        raise Exception, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."

    # setting additional module resources (files/images/etc)
    objects = {}   # dictionary of filename:binarydata

    listPngFiles = glob.glob(strTempWorkingDirectory + '/*.png')
    #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO,
    #         str(len(listPngFiles)) + " .png files were found.")
    print("LaTeX2CNXML" + str(len(listPngFiles)) + " .png files were found.")
    for file in listPngFiles:
        (strDirectory, strFile) = os.path.split(file)
        objFile = open(file, 'r')
        binData = objFile.read()
        objects[strFile] = binData
        objFile.close
        objImage = Image.open(file)
        (iWidth, iHeight) = objImage.size
        results = re.findall("(<image mime-type=\"image/png\" src=\"" + strFile + "\".*?)(/>)", strCnxml)
        for result in results:
            strOldImageTag = result[0] + result[1]
            strNewImageTag = result[0] + " width=\"" + str(iWidth) + "\">" + \
                         "<!-- NOTE: attribute width changes image size online (pixels). " + \
                         "original width is " + str(iWidth) + ". --></image>"
            strNewCnxml = strCnxml.replace(strOldImageTag, strNewImageTag);
            if len(strNewCnxml) >  len(strCnxml):
                #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "adding width parameter to image tag for " + strFile + " file.")
                print("LaTeX2CNXML: adding width parameter to image tag for " + strFile + " file.")
                strCnxml = strNewCnxml

    listEpsFiles = glob.glob(strTempWorkingDirectory + '/*.eps')
    #zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO,
    #         str(len(listEpsFiles)) + " .eps files were found.")
    print("LaTeX2CNXML: " + str(len(listEpsFiles)) + " .eps files were found.")

    for file in listEpsFiles:
        objFile = open(file, 'r')
        binData = objFile.read()
        objFile.close
        (strDirectory, strFile) = os.path.split(file)
        objects[strFile] = binData

    # save the original import zip. could be used later by the print pipeline.
    objFile = open(strZipFile, 'r')
    binData = objFile.read()
    strFile = strBaseName + '.zip'
    objects[strFile] = binData
    objFile.close

    #TODO:    
    #outdata.setData(strCnxml)

    #TODO:
    #outdata.setSubObjects(objects)

    # cleanup the temp working directory
    shutil.rmtree(strTempWorkingDirectory);

    cleanup(strHarvestedFileName)

    return strCnxml, objects


# ============================================

def latex_transform(content, original_filename):
    objects = {}
    #print "Transformiere ne..."
    cnxml, objects = convert(content, original_filename)
    return cnxml, objects

def latex_to_cnxml(content, original_filename):
    objects = {}
    cnxml, objects = latex_transform(content, original_filename)
    return cnxml, objects

if __name__ == "__main__":
    f = open(sys.argv[1])
    content = f.read()
    cnxml, objects = latex_to_cnxml(content, sys.argv[1])
    print cnxml

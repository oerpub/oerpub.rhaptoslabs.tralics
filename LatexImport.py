"""
Transform Zip file of LaTeX to CNXML module.

The main part of the returned idata (getData) will be the
index.cnxml file. The sub objects (getSubObjects) will be
the other objects in the module, which should be siblings to
the CNXML file.

Parameter 'data' is expected to be a binary zipfile containing
appropriately simple LaTeX. TODO: format of zipfile to be defined
(ZipImport allows either all-in-root, or all-in-greatest common subdir,
but this need not.)

NOTE: see OOoTransform header about compatibility with Archetypes fields.
"""
from StringIO import StringIO
import os
import shutil
from zipfile import ZipFile, ZIP_DEFLATED, is_zipfile
import tempfile
import zLOG
from Globals import package_home
from config import GLOBALS
import glob
import re
from PIL import Image

from helpers import OOoImportError, harvestImportFile, moveImportFile, XSL_LOCATION
from Products.CNXMLDocument.CNXMLFile import CNXML_AUTOID_XSL

from Products.PortalTransforms.interfaces import itransform

class latex_to_folder:
    """Transform zip file of LaTeX document to RhaptosModuleEditor with contents."""
    __implements__ = itransform

    __name__ = "latex_to_folder"
    inputs  = ("application/zip+latex",)
    output = "application/cmf+folderish"

    config = {
        'harvest_dir_success':'',
        'harvest_dir_failure':'',
    }
    config_metadata = {
        'harvest_dir_success':('string', 'Successful harvest directory', 'Directory where successful import files are saved.',),
        'harvest_dir_failure':('string', 'Failure harvest directory', 'Directory where files, which could not be successfully imported, are saved.',),
    }

    def name(self):
        return self.__name__

    ## helper methods

    def writeToGood(self,binData,strUser,strOriginalFileName):
        bSaveToTemp = True
        bHarvestingOn = ( len(self.config['harvest_dir_success']) > 0 )
        # zLOG.LOG("OOo2CNXML Transform", zLOG.INFO, "bHarvestingOn is %s" % bHarvestingOn)
        (strHead, strTail) = os.path.split(strOriginalFileName)
        (strRoot, strExt)  = os.path.splitext(strTail)

        if bHarvestingOn:
            strHarvestDirectory = self.config['harvest_dir_success']
            # zLOG.LOG("OOo2CNXML Transform", zLOG.INFO, "Harvested directory: " + strHarvestDirectory)
            (strHarvestDirectory,strFileName) = harvestImportFile(binData,strHarvestDirectory,strOriginalFileName,strUser)
            if len(strFileName) > 0:
                bSaveToTemp = False
                strFileName = strHarvestDirectory + strFileName
                zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "Harvested imported LaTeX doc: " + strFileName)
            else:
                zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "Failed to harvest imported LaTeX doc " + strOriginalFileName + " to directory " + strHarvestDirectory)

        if bSaveToTemp:
            strFileName = tempfile.mktemp(suffix=strExt)
            # zLOG.LOG("OOo2CNXML Transform", zLOG.INFO, "No harvested directory.  Writing to temporary file instead: %s" % strFileName)
            file = open(strFileName, 'w')
            file.write(binData)
            file.close()

        return strFileName

    def moveToBad(self,strFileName):
        bHarvestingOn = ( len(self.config['harvest_dir_failure']) > 0 )
        if bHarvestingOn:
            strBadHarvestDirectory = self.config['harvest_dir_failure']
            zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "Moving: %s" % strFileName)
            zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "to: %s" % strBadHarvestDirectory)
            strNewFileName = moveImportFile(strFileName,strBadHarvestDirectory)
            if len(strNewFileName) == 0:
                zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "Failed to move BAD imported LaTeX doc: %s" % strFileName)

    def cleanup(self, strFileName):
        # if we are not harvesting the import input file, we are operating on a copy in the temp directory,
        # which needs to be removed after the import has completed.
        bHarvestingOn = ( len(self.config['harvest_dir_success']) > 0 )
        bSaveToTemp = not bHarvestingOn
        if bSaveToTemp:
            zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "Removing: %s" % strFileName)
            os.remove(strFileName)

    def convert(self, data, outdata, **kwargs):
        """Input is a zip file. Output is idata, with getData being index.cnxml and subObjects being other siblings."""

        # FF yields 'foo.zip' while IE yields 'C:\foo.zip'.  since we are running on Linux
        # os.path.splitdrive() is a no-op :( thus the split is needed below.
        strOriginalFileName = kwargs['original_file_name'].split('\\')[-1]
        strUserName = kwargs['user_name']
        zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO,
                 "Original file name is : \"" + strOriginalFileName + "\". User is : \"" + strUserName + "\"")

        strHarvestedFileName = self.writeToGood(data,strUserName,strOriginalFileName)

        # incoming foo.zip must contain a foo.tex file, where "foo" is the base name.
        (strHead, strTail) = os.path.split(strOriginalFileName)
        (strRoot, strExt)  = os.path.splitext(strTail)
        strBaseName = strRoot

        # creating temp working where we can perform our magic
        strTempWorkingDirectory = tempfile.mkdtemp()

        # special processing for a likely bad input scenario
        if strExt == ".tex":
            zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, '.tex file was input')
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
            zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "expecting a .zip file and got a " + strExt + " file.")
            self.moveToBad(strHarvestedFileName)
            raise OOoImportError, "Expecting a .zip file containing your .tex and auxiliary files. Instead got a " + strExt + " file.  See the below LaTeX importer instruction page link for help."

        #strScript = os.path.join(package_home(GLOBALS), 'LatexImport.bash')
        strScript = os.getenv('LATEXIMPORT', os.path.join(package_home(GLOBALS), 'LatexImport.bash'))

        args = ['LatexImport.bash', strBaseName, strZipFile, strTempWorkingDirectory, XSL_LOCATION, CNXML_AUTOID_XSL]
        zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO,
                 "Calling\n" +
                 "\t" + strScript + "\n" +
                 "\t\t'" + strBaseName + "'\n" +
                 "\t\t'" + strZipFile + "'\n" +
                 "\t\t'" + strTempWorkingDirectory + "'\n" +
                 "\t\t'" + XSL_LOCATION + "'\n" +
                 "\t\t'" + CNXML_AUTOID_XSL + "'")
        rc = os.spawnv(os.P_WAIT, strScript, args)
        if rc != 0:
            zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "LatexImport.bash returned " + str(rc) + " and not zero.")
            self.moveToBad(strHarvestedFileName)
            strTexFile = strTempWorkingDirectory + '/' + strBaseName + '.tex'
            bGivenTexFile = os.path.isfile(strTexFile)
            if bGivenTexFile:
                strDviFile = strTempWorkingDirectory + '/' + strBaseName + '.div'
                strPdfFile = strTempWorkingDirectory + '/' + strBaseName + '.pdf'
                bDivCreated = os.path.isfile(strDviFile)
                bPdfCreated = os.path.isfile(strPdfFile)
                if not bDivCreated:
                    zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "latex in LatexImport.bash failed to create a DVI file.")
                    if not bPdfCreated:
                        zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "pdflatex in LatexImport.bash failed to create a PDF file.")
                        raise OOoImportError, "Unable to latex/pdflatex the source .tex file. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
                    else:
                        raise OOoImportError, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
                else:
                    raise OOoImportError, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."
            else:
                zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "Input zip file did not contain a liked named tex file:" + strTexFile)
                raise OOoImportError, "The .zip file does not contain a .tex file of the same name. See the below LaTeX importer instruction page link and ensure that your .tex and .zip files have been properly prepared."

        strCnxmlFile = strTempWorkingDirectory + '/index.cnxml'
        bCnxmlCreated = os.path.isfile(strCnxmlFile)
        if not bCnxmlCreated:
            # defensive code: should never get here. 
            # import script should return a bad rc if it can not create the cnxml file
            zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "LatexImport.bash did create the cnxml file.")
            self.moveToBad(strHarvestedFileName)
            raise OOoImportError, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."

        objFile = open(strCnxmlFile, "r")
        strCnxml = objFile.read()
        objFile.close()

        if len(strCnxml) == 0:
            zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "LatexImport.bash created an empty cnxml file.")
            self.moveToBad(strHarvestedFileName)
            raise OOoImportError, "Import failed. See the below LaTeX importer instruction page link and ensure that your .tex file has been properly prepared."

        # setting additional module resources (files/images/etc)
        objects = {}   # dictionary of filename:binarydata

        listPngFiles = glob.glob(strTempWorkingDirectory + '/*.png')
        zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO,
                 str(len(listPngFiles)) + " .png files were found.")
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
                    zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "adding width parameter to image tag for " + strFile + " file.")
                    # zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO, "xfroming cnxml from:\n\n" + strOldImageTag + "\n\nto:\n\n" + strNewImageTag)
                    strCnxml = strNewCnxml

        listEpsFiles = glob.glob(strTempWorkingDirectory + '/*.eps')
        zLOG.LOG("LaTeX2CNXML Transform", zLOG.INFO,
                 str(len(listEpsFiles)) + " .eps files were found.")
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

        outdata.setData(strCnxml)

        outdata.setSubObjects(objects)

        # cleanup the temp working directory
        shutil.rmtree(strTempWorkingDirectory);

        self.cleanup(strHarvestedFileName)

        return outdata

def register():
    return latex_to_folder()

#! /bin/bash -vx

# usage: LatexImport.ksh basename zippath tempworkdir importxsldir autogenidxsl

# process commanline options.

document=$1

zippath=$2
temp=${zippath#/} # remove the first character of zippath if it is a '/'
if [[ ${zippath} = ${temp} ]] ; then
    # the first character of zippath is not '/' => zippath is a relative path
    # make zippath be an absolute path
    zippath=${PWD}/$1
fi
zipdir=${zippath%/*.zip}
zipfile=${zippath##*/}
# document=${zipfile%%.zip}

tempworkdir=$3

importxsldir=$4

autogenidxsl=$5

cd ${tempworkdir}

# Step #1 - unzip the input zip file into the working directory
# and remove files that should not be in the zip

unzip -o "${zippath}"
\rm *.aux

# Step #2 - verify that the zip file contains a like named tex file

texfile=${document}.tex
if [[ ! -s ${texfile} ]] ; then
    texfile=${document}.TEX
    if [[ ! -s ${texfile} ]] ; then
        echo "zip file did not contain the file : ${document}.tex."
        echo "conversion aborted"
        exit 255
    fi
    # tralics can not do ${document}.TEX
    ln -s ${document}.TEX ${document}.tex
    texfile=${document}.tex
fi


# Step #3 - as a sanity check, make sure latex or pdflatex can compile the tex file

dvifile=${document}.dvi
pdffile=${document}.pdf

latex -halt-on-error -interaction='nonstopmode' "${texfile}"
rc=$?
echo "latex return code is ${rc}."
if [[ ${rc} != '0' || ! -s "${dvifile}" ]]; then
    echo "latex did not successfully create a dvi file."

    pdflatex -halt-on-error -interaction='nonstopmode' "${texfile}"
    rc=$?
    echo "pdflatex return code is ${rc}."
    if [[ ${rc} != '0' || ! -s "${pdffile}" ]]; then
        echo "pdflatex did not successfully create a pdf file."
        exit 255
    fi
fi

# step #4 - create files to assist tralics in generating its xml.
# without the below file(s) tralics would revert to its default behavior.

# create a verbatim.plt which will guide tralics in translation
# of LaTeX verbatim environments, generating cnxml friendly xml.

cat > ./verbatim.plt << EOF
\def\DefineVerbatimEnvironment#1#2#3{%
\expandafter \def\csname#1@hook\endcsname{#3}%
\expandafter\let\csname#1\expandafter\endcsname\csname#2\endcsname
\expandafter\let\csname end#1\expandafter\endcsname\csname end#2\endcsname}


\def\define@key#1#2{%
  \@ifnextchar[{\KV@def{#1}{#2}}{\@namedef{KV@#1@#2}##1}}
\def\KV@def#1#2[#3]{%
  \@namedef{KV@#1@#2@default\expandafter}\expandafter
    {\csname KV@#1@#2\endcsname{#3}}%
  \@namedef{KV@#1@#2}##1}

\def\FV@pre@verbatim{\begin{xmlelement*}{cnxverbatim}}
\def\FV@post@verbatim{\end{xmlelement*}}
\DefineVerbatimEnvironment{verbatim}{Verbatim}{pre=verbatim}
EOF

# Step #5 - convert a tex file into an xml file.

tralicsoutfile=${document}.xml
# tralics better be in your path!!!
# /usr/bin/tralics
# Marvin: Use local path for tralics
~/Dev/oerpub.rhaptoslabs.tralics/src/tralics -noentnames -math_variant -oe8 "${texfile}" # -noundefmac??? or -noxmlerror???
if [[ ! -s "${tralicsoutfile}" ]]; then
   echo "tralics failed to create its output xml file."
   exit 255
fi

# Step #6 - convert xml file into a cnxml file

cnxmlfile=${document}.cn.xml
rm -f "${cnxmlfile}"

xsltproc --novalid ${importxsldir}/tralics2cnxml.xsl "${tralicsoutfile}" > "${cnxmlfile}"
echo "return code for xml to cnxml tranform is $?"
if [[ ! -s "${cnxmlfile}" ]]; then
   echo "failed to create cnxml file via xsltproc."
   exit 255
fi

# Step #7 - autogen @ids

cnxmlfile_with_ids=${document}.ided.cn.xml
xsltproc --novalid --stringparam id-prefix 'latex-' "${autogenidxsl}" "${cnxmlfile}" > "${cnxmlfile_with_ids}"

# Step #8 - tidy the cnxml file

tidycnxmlfile=${document}_tidy.cn.xml
rm -f "${tidycnxmlfile}"

xsltproc ${importxsldir}/cnxmltidy.xsl "${cnxmlfile_with_ids}" > "${tidycnxmlfile}"
echo "return code for tidying cnxml is $?"
if [[ ! -s "${tidycnxmlfile}" ]]; then
   echo "failed to tidy cnxml file via xsltproc."
   exit 255
fi

# Step #9 - remove any of the remaining Figure Figure et al sequences
# from the cnxml. also remove parens surrounding <link> nodes.
# This would be better done in the XSLT from an architecture perspective,
# but there's no XSLT regexp support.  sed lives for this.

# note:
# unescaped () are literals
# outer \(..\) marks patterns to be accesses in the RHS match
# inner \(..\|..\) are extended RE which let you match a choice of patterns
# [^)]* forces the match to be non-greedy
# using -r breaks the sed script
sed -i ':<link: s:(\(<link[^)]*\(/>\|/link>\)\)):\1:g' "${tidycnxmlfile}"

# multi-line, job security sed magic ...
sed -ri '/([Ff]ig(ure|\.)|[Tt]able|[Ss]ec(tion|\.))\W*$/N
        s/(^|\W)([Ff]ig(ure|\.)|[Tt]able|[Ss]ec(tion|\.))\W*<link/\1<link/g' "${tidycnxmlfile}"

# Step #10 - validate the cnxml.
# this is where all points of failure from previous steps will be displayed.

# xmllint --noout --relaxng /usr/share/xml/cnxml/schema/rng/0.6/cnxml.rng "${tidycnxmlfile}"
# /usr/local/bin/jing.sh /usr/share/xml/cnxml/schema/rng/0.6/cnxml-jing.rng "${tidycnxmlfile}"

# Marvin
#XML_CATALOG_FILES=/etc/xml/catalog java -jar ${JING_JAR} /usr/share/xml/cnxml/schema/rng/0.7/cnxml-jing.rng "${tidycnxmlfile}"
#rc=$?
#echo "xmllint returned ${rc}."
#if (( rc != 0 )); then
#    echo "produced cnxml can not be validated by xmllint."
#    exit 255
#fi

# Step #11 - create an import friendly file

cp -f "${tidycnxmlfile}" index.cnxml

# Step #12 - convert all image files to png files (pdf file can multiple image files embedded in them)

pdf_image_files=$( ls *.pdf | grep -v ${pdffile} )

# set free the eps files buried in pdf files
mogrify -format eps ${pdf_image_files}
original_eps_files=$( ls *.eps )

mogrify -format eps *.ps
mogrify -format eps *.jpg
mogrify -format eps *.jpeg
mogrify -format eps *.png

mogrify -format png *.ps
mogrify -format png *.jpg
mogrify -format png *.jpeg
mogrify -format png ${original_eps_files}

# Done.  caller can now create a cnxml module with
# ${tempworkdir}/*.png
# ${tempworkdir}/index.cnxml

exit 0

# Step #13 - (done by the caller) add width params to the PNG media files


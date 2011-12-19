%%  -*- latex -*-
\ProvidesPackage{ra}[2009/10/15 v1.6 Utilities for INRIA's activity report]
% This file is part of Tralics

%% This software is governed by the CeCILL license under French law and
%% abiding by the rules of distribution of free software.  You can  use, 
%% modify and/ or redistribute the software under the terms of the CeCILL
%% license as circulated by CEA, CNRS and INRIA at the following URL
%% "http:%%www.cecill.info". 
%% (See the file COPYING in the main directory for details)
% copyright (C) INRIA/apics (Jose' Grimm) 2008

%% Note the condition is false by default
\newif\ifra@emptymodule %% true if empty module names allowed
\newif\ifra@catperso %% true if catperso is defined
\newif\ifra@participant %% true if participant is different from participants
\newif\ifra@old %% true if compiling ra before 2006
\newif\ifra@composition %% true if env composition is defined
\newif\ifra@moduleref %% true if moduleref is defined
\newif\ifra@topic %% true if topics can be used
\newif\ifra@topics %% true if topics are effectively used

\newif\ifra@inmodule % true inside a module
\newif\ifra@firstsection\ra@firstsectiontrue % true if in first section
\def\@allmodules{,} % The list of module names
\newcounter{modules}
\newtoks\ra@topics % topics declarations

\let\glo\@glo % needed in Tralics 2.13.3
\let\glossaire\@glossaire
\let\endglossaire\end@glossaire
\DeclareOption{catperso}{\ra@catpersotrue}
\DeclareOption{participant}{\ra@participanttrue}
\DeclareOption{co-publiants}{\ra@copubliantstrue}
\DeclareOption{emptymodule}{\ra@emptymoduletrue}
\DeclareOption{old}{\ra@oldtrue}
\DeclareOption{composition}{\ra@compositiontrue}
\DeclareOption{moduleref}{\ra@modulereftrue}
\DeclareOption{topic}{\ra@topictrue}

\ProcessOptions\relax

%--------------------------------------------------


% Following commands store their arguments somewhere to be used later.
\def\theme#1{\def\ra@theme{#1}}
\def\UR#1{\def\ra@UR{#1}}
\def\isproject#1{\def\ra@isproject{#1}}
\def\projet#1#2#3{\def\ra@proj@a{#1}\def\ra@proj@b{#2}\def\ra@proj@c{#3}}
\let\project\projet


%% Conditionally define the catperso environment
%% There are optional constraints on the argument.
\ifra@catperso
\newenvironment{catperso}[1]{%
  \begin{xmlelement*}{catperso}\let\par\empty
    \edef\@tmp{\tralics@find@config{catperso}}%
    \xbox{head}{\ifx\@tmp\empty#1\else\tralics@get@config{catperso}{#1}\fi}%
    \@addnl}
  {\end{xmlelement*}\@addnl}
\fi

%% environment participants defines \pers to be \persA
\newenvironment{participants}{%
  \begin{xmlelement*}{participants}\let\par\empty\let\pers\persA}
  {\end{xmlelement*}\@addnl}

%% environment co-publiants defines \pays
\newenvironment{co-publiants}{%
  \begin{xmlelement*}{co-publiants}\let\par\empty\let\pays\@pays}
  {\end{xmlelement*}\@addnl}

%% Alternate names are conditionnally defined.
\ifra@participant
\newenvironment{participante}{%
  \begin{xmlelement*}{participante}\let\par\empty\let\pers\persA}
  {\end{xmlelement*}\@addnl}

\newenvironment{participant}{%
  \begin{xmlelement*}{participant}\let\par\empty\let\pers\persA}
  {\end{xmlelement*}\@addnl}

\newenvironment{participantes}{%
  \begin{xmlelement*}{participantes}\let\par\empty\let\pers\persA}
  {\end{xmlelement*}\@addnl}
\else
\let\participante\participants
\let\participant\participants
\let\participantes\participants
\let\endparticipante\endparticipants
\let\endparticipant\endparticipants
\let\endparticipantes\endparticipants
\fi

% #1=list name, #2=key
\def\tralics@use@config#1#2{%
  \edef\@tmp{\tralics@find@config{#1}}%
  \ifx\@tmp\empty#2\else\tralics@get@config{#1}{#2}\fi}


%% 
\def\remove@fl@space@#1#2{%
\expandafter\def\expandafter #1\expandafter {\zap@fl@space{#2}}}

\def\remove@fl@space#1{%
  \expandafter\remove@fl@space@\expandafter#1\expandafter{#1}}

\def\@pays#1#2{\xbox{pays}{\XMLaddatt{court}{#2}\XMLaddatt{long}{#1}}%
\@addnl\@ifnextchar,\@gobble\empty}

% Hack applied to \persA and \persB
\def\pers@hack#1#2#3{%
  \def\t@pnom{#1}%
  \def\t@nom{#2}%
  \def\t@aux{#3}%
  \tralics@fnhack\t@nom\t@aux
  \remove@fl@space\t@aux
  \remove@fl@space\t@pnom
  \remove@fl@space\t@nom}


%% This is \persA, the simple command
\def\persA#1{\@ifnextchar[{\persA@part{#1}}{\persA@nom{#1}}}
\def\persA@part#1[#2]#3{\persA@nom{#1}{#2 #3}}
\def\persA@nom#1#2{\@ifnextchar[{\persA@opt{#1}{#2}}{\persA@opt{#1}{#2}[]}}

\def\persA@opt#1#2[#3]{%
  \pers@hack{#1}{#2}{#3}%
  \@persA{\t@pnom}{\t@nom}{\t@aux}}


%% This is \persB the complicated command
\def\persB#1{\@ifnextchar[{\persB@part{#1}}{\persB@nom{#1}}}
\def\persB@part#1[#2]#3{\persB@nom{#1}{#2 #3}}
\def\persB@nom#1#2{\@ifnextchar[{\persB@rc{#1}{#2}}{\persB@rc{#1}{#2}[]}}
\def\persB@rc#1#2[#3]#4#5{\@ifnextchar[{\persB@aux{#1}{#2}{#3}{#4}{#5}}
  {\persB@aux{#1}{#2}{#3}{#4}{#5}[]}}
\def\persB@aux#1#2#3#4#5[#6]{\@ifnextchar[{\persB@hdr{#1}{#2}{#3}{#4}{#5}{#6}}
  {\persB@hdr{#1}{#2}{#3}{#4}{#5}{#6}[]}}

\def\persB@hdr#1#2#3#4#5#6[#7]{%
  \pers@hack{#1}{#2}{#6}%
  \def\t@rc{#3}\remove@fl@space\t@rc
  \def\t@catpro{#4}\remove@fl@space\t@catpro
  \def\t@orga{#5}\remove@fl@space\t@orga
  \def\t@hdr{#7}\remove@fl@space\t@hdr
  \ifx\t@rc\empty\def\tmp{}\else\def\tmp{[\t@rc]}\fi
  \expandafter\@persB\tmp{\t@pnom}{\t@nom}{\t@catpro}{\t@orga}{\t@aux}{\t@hdr}}

\def\@persA#1#2#3{\xbox{pers}{\XMLaddatt{nom}{#2}\XMLaddatt{prenom}{#1}#3}%
\@addnl\@ifnextchar,\@gobble\empty}

\newcommand\@persB[7][]{%
  % Make sure error token are outside the xbox
  \edef\@tmp{\tralics@find@config{profession}}%
  \edef\t@pro{\ifx\@tmp\empty#4\else\tralics@get@config{profession}{#4}\fi}%
  \edef\@tmp{\tralics@find@config{affiliation}}%
  \edef\t@aff{\ifx\@tmp\empty#5\else\tralics@get@config{affiliation}{#5}\fi}%
  \edef\@tmp{\tralics@find@config{ur}}%
  \ifnum\ra@year>2006 
  \edef\t@rc{\ifx\@tmp\empty#1\else\tralics@get@config{ur}{#1}\fi}%
  \else\let\t@rc\empty\fi
  \xbox{pers}{%
    \unless\ifx\t@rc\empty\XMLaddatt{research-centre}{\t@rc}\fi
    \edef\tmp{#7}\unless\ifx\tmp\empty\XMLaddatt{hdr}{#7}\fi
    \XMLaddatt{profession}{\t@pro}%
    \XMLaddatt{affiliation}{\t@aff}%
    \XMLaddatt{nom}{#3}\XMLaddatt{prenom}{#2}%
    #6}\@addnl\@ifnextchar,\@gobble\empty}


\newenvironment{moreinfo}{\begin{xmlelement*}{moreinfo}}
  {\end{xmlelement*}\@addnl}
  

%% obsolete in 2007
\def\declaretopic#1#2{}

\newenvironment{module}{\@start@module}{\tralics@pop@module}

% first optional argument #1=topic ignored; #2=section, #3=aux, #4=title
\newcommand\@start@module[4][]{%
  \ifra@inmodule\PackageError{Raweb}{Nested modules are illegal}{}\fi
  \ra@inmoduletrue
  \edef\@tmp{\tralics@get@config{fullsection}{#2}}%
  \ifx\@tmp\empty\else
    \ifra@firstsection\else \tralics@pop@section\fi
     \global\ra@firstsectionfalse
     \typeout{Translating section #2}%
     \tralics@push@section{#2}
     \ifnum\ra@year>2006 \XMLaddatt{titre}{\@tmp}\fi
  \fi
  \refstepcounter{modules}%
  \edef\foo{\noexpand\in@{,#3,}{\@allmodules}}\foo
  \ifin@ \ClassError{Raweb}{Duplicate module: #3}{}\else
  \xdef\@allmodules{,#3\@allmodules}\fi
  \ifra@emptymodule
  \tralics@push@module{#3}{#4}%
  \else
  \tralics@push@module{#3}{\@ifbempty{#4}{(Sans Titre)}{#4}}%
  \fi
  \ifra@topic\XMLaddatt{html}{module\themodules}\fi
  \ifra@topics\edef\t@topic{\tralics@get@config{section}{#1}}
  \unless\ifx\t@topic\empty\XMLaddatt{topic}{\@nameuse{ra@topicval@\t@topic}}\fi
  \fi}

%% Is this a Team or a Project Team ?
\def\ra@check@isproject#1#2\relax{%
  \@tempswafalse
  \if y#1\@tempswatrue\fi
  \if Y#1\@tempswatrue\fi
  \if o#1\@tempswatrue\fi
  \if O#1\@tempswatrue\fi
  \XMLaddatt{isproject}{\if@tempswa true\else false\fi}}

\def\ra@check@project{%
  \ifx\ra@proj@a\relax \PackageError{Raweb}{Missing \string \project}{}\fi
  \def\tmpA##1{\lowercase{\xdef\tmpA{\detokenize{##1}}}}
  \expandafter\tmpA\expandafter{\ra@proj@a}
  \ifx\tmpA\tmpB \else\PackageError{Raweb}{Invalid Team name \ra@proj@a}{}\fi
  \xbox{projet}{\ifx\ra@proj@b\empty \tmpB\else\ra@proj@b\fi}%
}

\def\rawebstartdocument{%
  \@addnl
  \begin{xmlelement*}{accueil}%
    \edef\tmpB{\ra@jobname}
    \XMLaddatt{html}{\ra@jobname}%
    \expandafter\ra@check@isproject\ra@isproject n\relax    \@addnl
    \xbox{theme}{\ifnum\ra@year>2008 Dummy%
      \else\tralics@get@config{theme}{\ra@theme}\fi} \@addnl
    \ra@check@project\@addnl
    \xbox{projetdeveloppe}{\ra@proj@c}\@addnl
    \expandafter\tralics@interpret@rc\expandafter{\ra@UR}\@addnl
    \the\ra@topics
  \end{xmlelement*}\@addnl
}


%\def\theme#1{\def\ra@theme{#1}}
%\def\UR#1{\def\ra@UR{#1}}
%\def\isproject#1{\def\ra@isproject{#1}}
%\def\projet#1#2#3{\def\ra@proj@a{#1}\def\ra@proj@b{#2}\def\ra@proj@c{#3}}

\let\ra@proj@a\relax
\let\pers\persB
\let\pays\relax

% The documentation says to use these commands, so let's define them
\let\maketitle\relax
\let\loadbiblio\relax
\let\keywords\motscle

%% --------------------------------------------------
\ifra@moduleref
% syntax \moduleref[yr]{p}{s}{a}
\newcommand\moduleref[4][]{%
  \def\@tmp{#1}%
  \unless\ifx\@tmp\empty\edef\@tmpA{\ra@year}\ifx\@tmp\@tmpA\let\@tmp\empty\fi\fi
  \ifx\@tmp\empty
  \@iftempty{#4}{\ref{section:#3}}{\ref{mod:#4}}%
  \else \PackageError{Raweb}{\string \moduleref[#1] is not implemented}{}\fi}

\else
\def\moduleref#1#2#3{\ref{mod:#3}}

\fi

%% --------------------------------------------------
\ifra@old

\let\pers\persA
\fi

%% --------------------------------------------------
\ifra@composition

\let\pers\undefined
\newenvironment{composition}
{\let\pers\persB
  \ifra@inmodule\PackageError{Raweb}{Composition forbidden in Module}{}\fi
  \unless\ifra@firstsection
    \PackageError{Raweb}{Composition must be before first module}{}
    \tralics@pop@section
  \fi
  \edef\@tmp{\tralics@get@config{fullsection}{composition}}%
  \ifx\@tmp\empty\else
  \ifra@firstsection\else \tralics@pop@section\fi
  \global\ra@firstsectionfalse
  \typeout{Translating composition}%
  \tralics@push@section{composition}%
  \XMLaddatt{titre}{\@tmp}\@addnl%
  \fi
}{}


\fi
%% --------------------------------------------------

\def\declaretopic#1#2{%
\xbox{topic}{\XMLaddatt{num}{#1}\xbox{t\_titre}{#2}}\@addnl
}

\ifra@topic
\newcounter{topics}
\def\ra@topicval@default{1}
\let\ra@declaretopic\declaretopic
\def\declaretopic#1#2{%
  \ra@topicstrue
 \stepcounter{topics}%
 \expandafter\ra@declaretopicaux\expandafter{\the\c@topics}{#1}{#2}}

\def\ra@declaretopicaux#1#2#3{%
 \@namedef{ra@topicval@#2}{#1}
 \ra@topics=\expandafter{\the\ra@topics\ra@declaretopic{#1}{#3}}}
\fi
%% --------------------------------------------------

\endinput

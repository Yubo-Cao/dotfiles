\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{notebook}[2020/09/15 v1.0 Notebook class]

\newif\if@loadtikz\@loadtikzfalse
\newif\if@microtype\@microtypefalse

\DeclareOption{tikz}{\@loadtikztrue}
\DeclareOption{microtype}{\@microtypetrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[11pt,letterpaper]{article}

\if@loadtikz
\RequirePackage{tikz}
\RequirePackage{pgfplots}
\pgfplotsset{compat=1.18}
\fi

\if@microtype
\RequirePackage{microtype}
\fi

% references
\RequirePackage[hidelinks]{hyperref}
\providecommand*{\listingautorefname}{Listing}

% fancy headers
\RequirePackage{fancyhdr}
\pagestyle{fancy}

\fancyhf[LH]{\textsc{Robotics: Engineering}}
\fancyhf[FL]{\member}
\fancyhf[FR]{\name}
\setlength{\headheight}{15pt}

% load image
\RequirePackage{graphicx}
\RequirePackage{wrapfig}
\RequirePackage[ruled]{algorithm2e}

% almost always need to use unit
\RequirePackage{siunitx}
\DeclareSIUnit\inch{in}
\DeclareSIUnit\foot{ft}
\DeclareSIUnit\pound{lb}

% set linespacing
\RequirePackage{setspace}
\setstretch{1.15}

% allow any caption
\RequirePackage{subcaption}
% common space
\RequirePackage{xspace}


% set specific font
\RequirePackage{fontspec}
% \setmonofont{Cascadia Code}

\makeatletter
\def\@maketitle{
    \begin{titlepage}
        \begin{center}
            \vspace*{1cm}
            \textbf{\Huge Robotics: Engineering Notebook}
    
            \vfill
    
            \vspace{1cm}
            \textbf{\Large Challenge Name\\
                \normalsize\normalfont\name}
    
            \vspace{1cm}
            \textbf{\Large Group Members\\
                \normalsize\normalfont\member}
    
            \vspace{1cm}
            \textbf{\Large Date of Challenge\\
                \normalsize\normalfont\today}
        \end{center}
    \end{titlepage}
}
\makeatother

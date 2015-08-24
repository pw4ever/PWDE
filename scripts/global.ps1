<#
.SYNOPSIS
  Setup the Portable Windows Development Environment (PWDE) on the target machine.
.PARAMETER PkgList
  List of ZIP packages to download/extract. No need to specify unless to select a subset.
.PARAMETER Destination
  Destination path.
#>

[CmdletBinding(
SupportsShouldProcess=$True,
# named argument required to prevent accidental unzipping
PositionalBinding=$False
)]
param(
    # ls *.zip | % { write-host "`"$(basename $_ .zip)`","}
    [Parameter(
    HelpMessage="List of ZIP packages to download/extract. No need to specify unless to select a subset."    
    )]
    [String[]]
    $PkgList,

    [Parameter(
    HelpMessage="Destination path.",
    Mandatory=$True
    )]
    $Destination
)

function ensure-dir ($dir) {
    if (!$(Test-Path $dir)) {
        mkdir $dir -Force > $NULL
        Write-Host "$dir created."
    }
}

function main
{

    ensure-dir $Destination    
    $Destination=$(Resolve-Path $Destination)
    
    if ("global" -in $PkgList) {
        work $Destination
    }    
}


function work ($prefix) {
$prefix=$(Resolve-Path "$prefix")

$name=[System.IO.Path]::Combine($prefix, ".globalrc")
$globallib=[System.IO.Path]::Combine($prefix, "global", "lib", "gtags").Replace("\", "\\").Replace(":", "\:")
New-Item -Path "$name" -Force -ItemType File > $NULL

@"
#
# Copyright (c) 1998, 1999, 2000, 2001, 2002, 2003, 2010, 2011, 2013,
#	2015
#	Tama Communications Corporation
#
# This file is part of GNU GLOBAL.
#
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# *
# Configuration file for GNU GLOBAL source code tag system.
#
# Basically, GLOBAL doesn't need this file ('gtags.conf'), because it has
# default values in itsself. If you have the file as '/etc/gtags.conf' or
# "`$HOME/.globalrc" in your system then GLOBAL overwrite the default values
# with the values in the file.
#
# The format is similar to termcap(5). You can specify a target with
# GTAGSLABEL environment variable. Default target is 'default'.
#
default:\
	:tc=native:tc=pygments:
native:\
	:tc=gtags:tc=htags:
user:\
	:tc=user-custom:tc=htags:
ctags:\
	:tc=exuberant-ctags:tc=htags:
pygments:\
	:tc=pygments-parser:tc=htags:
#---------------------------------------------------------------------
# Configuration for gtags(1)
# See gtags(1).
#---------------------------------------------------------------------
common:\
	:skip=HTML/,HTML.pub/,tags,TAGS,ID,y.tab.c,y.tab.h,gtags.files,cscope.files,cscope.out,cscope.po.out,cscope.in.out,SCCS/,RCS/,CVS/,CVSROOT/,{arch}/,autom4te.cache/,*.orig,*.rej,*.bak,*~,#*#,*.swp,*.tmp,*_flymake.*,*_flymake:
#
# Built-in parsers.
#
gtags:\
	:tc=common:\
	:tc=builtin-parser:
builtin-parser:\
	:langmap=c\:.c.h,yacc\:.y,asm\:.s.S,java\:.java,cpp\:.c++.cc.hh.cpp.cxx.hxx.hpp.C.H,php\:.php.php3.phtml:
#
# skeleton for user's custom parser.
#
user-custom|User custom plugin parser:\
	:tc=common:\
	:langmap=c\:.c.h:\
	:gtags_parser=c\:$globallib/user-custom.dll:
#
# Plug-in parser to use Exuberant Ctags.
#
exuberant-ctags|plugin-example|setting to use Exuberant Ctags plug-in parser:\
	:tc=common:\
	:langmap=Asm\:.asm.ASM.s.S:\
	:langmap=Asp\:.asp.asa:\
	:langmap=Awk\:.awk.gawk.mawk:\
	:langmap=Basic\:.bas.bi.bb.pb:\
	:langmap=BETA\:.bet:\
	:langmap=C\:.c:\
	:langmap=C++\:.c++.cc.cp.cpp.cxx.h.h++.hh.hp.hpp.hxx.C.H:\
	:langmap=C#\:.cs:\
	:langmap=Cobol\:.cbl.cob.CBL.COB:\
	:langmap=DosBatch\:.bat.cmd:\
	:langmap=Eiffel\:.e:\
	:langmap=Erlang\:.erl.ERL.hrl.HRL:\
	:langmap=Flex\:.as.mxml:\
	:langmap=Fortran\:.f.for.ftn.f77.f90.f95.F.FOR.FTN.F77.F90.F95:\
	:langmap=HTML\:.htm.html:\
	:langmap=Java\:.java:\
	:langmap=JavaScript\:.js:\
	:langmap=Lisp\:.cl.clisp.el.l.lisp.lsp:\
	:langmap=Lua\:.lua:\
	:langmap=MatLab\:.m:\
	:langmap=OCaml\:.ml.mli:\
	:langmap=Pascal\:.p.pas:\
	:langmap=Perl\:.pl.pm.plx.perl:\
	:langmap=PHP\:.php.php3.phtml:\
	:langmap=Python\:.py.pyx.pxd.pxi.scons:\
	:langmap=REXX\:.cmd.rexx.rx:\
	:langmap=Ruby\:.rb.ruby:\
	:langmap=Scheme\:.SCM.SM.sch.scheme.scm.sm:\
	:langmap=Sh\:.sh.SH.bsh.bash.ksh.zsh:\
	:langmap=SLang\:.sl:\
	:langmap=SML\:.sml.sig:\
	:langmap=SQL\:.sql:\
	:langmap=Tcl\:.tcl.tk.wish.itcl:\
	:langmap=Tex\:.tex:\
	:langmap=Vera\:.vr.vri.vrh:\
	:langmap=Verilog\:.v:\
	:langmap=VHDL\:.vhdl.vhd:\
	:langmap=Vim\:.vim:\
	:langmap=YACC\:.y:\
	:gtags_parser=Asm\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Asp\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Awk\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Basic\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=BETA\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=C\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=C++\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=C#\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Cobol\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=DosBatch\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Eiffel\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Erlang\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Flex\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Fortran\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=HTML\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Java\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=JavaScript\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Lisp\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Lua\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=MatLab\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=OCaml\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Pascal\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Perl\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=PHP\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Python\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=REXX\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Ruby\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Scheme\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Sh\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=SLang\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=SML\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=SQL\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Tcl\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Tex\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Vera\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Verilog\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=VHDL\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=Vim\:$globallib/exuberant-ctags.dll:\
	:gtags_parser=YACC\:$globallib/exuberant-ctags.dll:
#
# Plug-in parser to use Pygments.
#
pygments-parser|Pygments plug-in parser:\
	:tc=common:\
	:langmap=ABAP\:.abap:\
	:langmap=ANTLR\:.G.g:\
	:langmap=ActionScript3\:.as:\
	:langmap=Ada\:.adb.ads.ada:\
	:langmap=AppleScript\:.applescript:\
	:langmap=AspectJ\:.aj:\
	:langmap=Aspx-cs\:.aspx.asax.ascx.ashx.asmx.axd:\
	:langmap=Asymptote\:.asy:\
	:langmap=AutoIt\:.au3:\
	:langmap=Awk\:.awk.gawk.mawk:\
	:langmap=BUGS\:.bug:\
	:langmap=Bash\:.sh.ksh.bash.ebuild.eclass:\
	:langmap=Bat\:.bat.cmd:\
	:langmap=BlitzMax\:.bmx:\
	:langmap=Boo\:.boo:\
	:langmap=Bro\:.bro:\
	:langmap=C#\:.cs:\
	:langmap=C++\:.c++.cc.cp.cpp.cxx.h.h++.hh.hp.hpp.hxx.C.H:\
	:langmap=COBOLFree\:.cbl.CBL:\
	:langmap=COBOL\:.cob.COB.cpy.CPY:\
	:langmap=CUDA\:.cu.cuh:\
	:langmap=C\:.c.h:\
	:langmap=Ceylon\:.ceylon:\
	:langmap=Cfm\:.cfm.cfml.cfc:\
	:langmap=Clojure\:.clj.cljs.cljx:\
	:langmap=CoffeeScript\:.coffee:\
	:langmap=Common-Lisp\:.cl.lisp.el:\
	:langmap=Coq\:.v:\
	:langmap=Croc\:.croc:\
	:langmap=Csh\:.tcsh.csh:\
	:langmap=Cython\:.pyx.pxd.pxi:\
	:langmap=Dart\:.dart:\
	:langmap=Dg\:.dg:\
	:langmap=Duel\:.duel.jbst:\
	:langmap=Dylan\:.dylan.dyl.intr:\
	:langmap=ECL\:.ecl:\
	:langmap=EC\:.ec.eh:\
	:langmap=ERB\:.erb:\
	:langmap=Elixir\:.ex.exs:\
	:langmap=Erlang\:.erl.hrl.es.escript:\
	:langmap=Evoque\:.evoque:\
	:langmap=FSharp\:.fs.fsi:\
	:langmap=Factor\:.factor:\
	:langmap=Fancy\:.fy.fancypack:\
	:langmap=Fantom\:.fan:\
	:langmap=Felix\:.flx.flxh:\
	:langmap=Fortran\:.f.f90.F.F90:\
	:langmap=GAS\:.s.S:\
	:langmap=GLSL\:.vert.frag.geo:\
	:langmap=Genshi\:.kid:\
	:langmap=Gherkin\:.feature:\
	:langmap=Gnuplot\:.plot.plt:\
	:langmap=Go\:.go:\
	:langmap=GoodData-CL\:.gdc:\
	:langmap=Gosu\:.gs.gsx.gsp.vark:\
	:langmap=Groovy\:.groovy:\
	:langmap=Gst\:.gst:\
	:langmap=HaXe\:.hx:\
	:langmap=Haml\:.haml:\
	:langmap=Haskell\:.hs:\
	:langmap=Hxml\:.hxml:\
	:langmap=Hybris\:.hy.hyb:\
	:langmap=IDL\:.pro:\
	:langmap=Io\:.io:\
	:langmap=Ioke\:.ik:\
	:langmap=JAGS\:.jag.bug:\
	:langmap=Jade\:.jade:\
	:langmap=JavaScript\:.js:\
	:langmap=Java\:.java:\
	:langmap=Jsp\:.jsp:\
	:langmap=Julia\:.jl:\
	:langmap=Koka\:.kk.kki:\
	:langmap=Kotlin\:.kt:\
	:langmap=LLVM\:.ll:\
	:langmap=Lasso\:.lasso:\
	:langmap=Literate-Haskell\:.lhs:\
	:langmap=LiveScript\:.ls:\
	:langmap=Logos\:.x.xi.xm.xmi:\
	:langmap=Logtalk\:.lgt:\
	:langmap=Lua\:.lua.wlua:\
	:langmap=MOOCode\:.moo:\
	:langmap=MXML\:.mxml:\
	:langmap=Mako\:.mao:\
	:langmap=Mason\:.m.mhtml.mc.mi:\
	:langmap=Matlab\:.m:\
	:langmap=Modelica\:.mo:\
	:langmap=Modula2\:.mod:\
	:langmap=Monkey\:.monkey:\
	:langmap=MoonScript\:.moon:\
	:langmap=MuPAD\:.mu:\
	:langmap=Myghty\:.myt:\
	:langmap=NASM\:.asm.ASM:\
	:langmap=NSIS\:.nsi.nsh:\
	:langmap=Nemerle\:.n:\
	:langmap=NewLisp\:.lsp.nl:\
	:langmap=Newspeak\:.ns2:\
	:langmap=Nimrod\:.nim.nimrod:\
	:langmap=OCaml\:.ml.mli.mll.mly:\
	:langmap=Objective-C++\:.mm.hh:\
	:langmap=Objective-C\:.m.h:\
	:langmap=Objective-J\:.j:\
	:langmap=Octave\:.m:\
	:langmap=Ooc\:.ooc:\
	:langmap=Opa\:.opa:\
	:langmap=OpenEdge\:.p.cls:\
	:langmap=PHP\:.php.php3.phtml:\
	:langmap=Pascal\:.pas:\
	:langmap=Perl\:.pl.pm:\
	:langmap=PostScript\:.ps.eps:\
	:langmap=PowerShell\:.ps1:\
	:langmap=Prolog\:.prolog.pro.pl:\
	:langmap=Python\:.py.pyw.sc.tac.sage:\
	:langmap=QML\:.qml:\
	:langmap=REBOL\:.r.r3:\
	:langmap=RHTML\:.rhtml:\
	:langmap=Racket\:.rkt.rktl:\
	:langmap=Ragel\:.rl:\
	:langmap=Redcode\:.cw:\
	:langmap=RobotFramework\:.robot:\
	:langmap=Ruby\:.rb.rbw.rake.gemspec.rbx.duby:\
	:langmap=Rust\:.rs.rc:\
	:langmap=S\:.S.R:\
	:langmap=Scala\:.scala:\
	:langmap=Scaml\:.scaml:\
	:langmap=Scheme\:.scm.ss:\
	:langmap=Scilab\:.sci.sce.tst:\
	:langmap=Smalltalk\:.st:\
	:langmap=Smarty\:.tpl:\
	:langmap=Sml\:.sml.sig.fun:\
	:langmap=Snobol\:.snobol:\
	:langmap=SourcePawn\:.sp:\
	:langmap=Spitfire\:.spt:\
	:langmap=Ssp\:.ssp:\
	:langmap=Stan\:.stan:\
	:langmap=SystemVerilog\:.sv.svh:\
	:langmap=Tcl\:.tcl:\
	:langmap=TeX\:.tex.aux.toc:\
	:langmap=Tea\:.tea:\
	:langmap=Treetop\:.treetop.tt:\
	:langmap=TypeScript\:.ts:\
	:langmap=UrbiScript\:.u:\
	:langmap=VB.net\:.vb.bas:\
	:langmap=VGL\:.rpf:\
	:langmap=Vala\:.vala.vapi:\
	:langmap=Velocity\:.vm.fhtml:\
	:langmap=Verilog\:.v:\
	:langmap=Vhdl\:.vhdl.vhd:\
	:langmap=Vim\:.vim:\
	:langmap=XBase\:.PRG.prg:\
	:langmap=XQuery\:.xqy.xquery.xq.xql.xqm:\
	:langmap=XSLT\:.xsl.xslt.xpl:\
	:langmap=Xtend\:.xtend:\
	:gtags_parser=ABAP\:$globallib/pygments-parser.dll:\
	:gtags_parser=ANTLR\:$globallib/pygments-parser.dll:\
	:gtags_parser=ActionScript3\:$globallib/pygments-parser.dll:\
	:gtags_parser=Ada\:$globallib/pygments-parser.dll:\
	:gtags_parser=AppleScript\:$globallib/pygments-parser.dll:\
	:gtags_parser=AspectJ\:$globallib/pygments-parser.dll:\
	:gtags_parser=Aspx-cs\:$globallib/pygments-parser.dll:\
	:gtags_parser=Asymptote\:$globallib/pygments-parser.dll:\
	:gtags_parser=AutoIt\:$globallib/pygments-parser.dll:\
	:gtags_parser=Awk\:$globallib/pygments-parser.dll:\
	:gtags_parser=BUGS\:$globallib/pygments-parser.dll:\
	:gtags_parser=Bash\:$globallib/pygments-parser.dll:\
	:gtags_parser=Bat\:$globallib/pygments-parser.dll:\
	:gtags_parser=BlitzMax\:$globallib/pygments-parser.dll:\
	:gtags_parser=Boo\:$globallib/pygments-parser.dll:\
	:gtags_parser=Bro\:$globallib/pygments-parser.dll:\
	:gtags_parser=C#\:$globallib/pygments-parser.dll:\
	:gtags_parser=C++\:$globallib/pygments-parser.dll:\
	:gtags_parser=COBOLFree\:$globallib/pygments-parser.dll:\
	:gtags_parser=COBOL\:$globallib/pygments-parser.dll:\
	:gtags_parser=CUDA\:$globallib/pygments-parser.dll:\
	:gtags_parser=C\:$globallib/pygments-parser.dll:\
	:gtags_parser=Ceylon\:$globallib/pygments-parser.dll:\
	:gtags_parser=Cfm\:$globallib/pygments-parser.dll:\
	:gtags_parser=Clojure\:$globallib/pygments-parser.dll:\
	:gtags_parser=CoffeeScript\:$globallib/pygments-parser.dll:\
	:gtags_parser=Common-Lisp\:$globallib/pygments-parser.dll:\
	:gtags_parser=Coq\:$globallib/pygments-parser.dll:\
	:gtags_parser=Croc\:$globallib/pygments-parser.dll:\
	:gtags_parser=Csh\:$globallib/pygments-parser.dll:\
	:gtags_parser=Cython\:$globallib/pygments-parser.dll:\
	:gtags_parser=Dart\:$globallib/pygments-parser.dll:\
	:gtags_parser=Dg\:$globallib/pygments-parser.dll:\
	:gtags_parser=Duel\:$globallib/pygments-parser.dll:\
	:gtags_parser=Dylan\:$globallib/pygments-parser.dll:\
	:gtags_parser=ECL\:$globallib/pygments-parser.dll:\
	:gtags_parser=EC\:$globallib/pygments-parser.dll:\
	:gtags_parser=ERB\:$globallib/pygments-parser.dll:\
	:gtags_parser=Elixir\:$globallib/pygments-parser.dll:\
	:gtags_parser=Erlang\:$globallib/pygments-parser.dll:\
	:gtags_parser=Evoque\:$globallib/pygments-parser.dll:\
	:gtags_parser=FSharp\:$globallib/pygments-parser.dll:\
	:gtags_parser=Factor\:$globallib/pygments-parser.dll:\
	:gtags_parser=Fancy\:$globallib/pygments-parser.dll:\
	:gtags_parser=Fantom\:$globallib/pygments-parser.dll:\
	:gtags_parser=Felix\:$globallib/pygments-parser.dll:\
	:gtags_parser=Fortran\:$globallib/pygments-parser.dll:\
	:gtags_parser=GAS\:$globallib/pygments-parser.dll:\
	:gtags_parser=GLSL\:$globallib/pygments-parser.dll:\
	:gtags_parser=Genshi\:$globallib/pygments-parser.dll:\
	:gtags_parser=Gherkin\:$globallib/pygments-parser.dll:\
	:gtags_parser=Gnuplot\:$globallib/pygments-parser.dll:\
	:gtags_parser=Go\:$globallib/pygments-parser.dll:\
	:gtags_parser=GoodData-CL\:$globallib/pygments-parser.dll:\
	:gtags_parser=Gosu\:$globallib/pygments-parser.dll:\
	:gtags_parser=Groovy\:$globallib/pygments-parser.dll:\
	:gtags_parser=Gst\:$globallib/pygments-parser.dll:\
	:gtags_parser=HaXe\:$globallib/pygments-parser.dll:\
	:gtags_parser=Haml\:$globallib/pygments-parser.dll:\
	:gtags_parser=Haskell\:$globallib/pygments-parser.dll:\
	:gtags_parser=Hxml\:$globallib/pygments-parser.dll:\
	:gtags_parser=Hybris\:$globallib/pygments-parser.dll:\
	:gtags_parser=IDL\:$globallib/pygments-parser.dll:\
	:gtags_parser=Io\:$globallib/pygments-parser.dll:\
	:gtags_parser=Ioke\:$globallib/pygments-parser.dll:\
	:gtags_parser=JAGS\:$globallib/pygments-parser.dll:\
	:gtags_parser=Jade\:$globallib/pygments-parser.dll:\
	:gtags_parser=JavaScript\:$globallib/pygments-parser.dll:\
	:gtags_parser=Java\:$globallib/pygments-parser.dll:\
	:gtags_parser=Jsp\:$globallib/pygments-parser.dll:\
	:gtags_parser=Julia\:$globallib/pygments-parser.dll:\
	:gtags_parser=Koka\:$globallib/pygments-parser.dll:\
	:gtags_parser=Kotlin\:$globallib/pygments-parser.dll:\
	:gtags_parser=LLVM\:$globallib/pygments-parser.dll:\
	:gtags_parser=Lasso\:$globallib/pygments-parser.dll:\
	:gtags_parser=Literate-Haskell\:$globallib/pygments-parser.dll:\
	:gtags_parser=LiveScript\:$globallib/pygments-parser.dll:\
	:gtags_parser=Logos\:$globallib/pygments-parser.dll:\
	:gtags_parser=Logtalk\:$globallib/pygments-parser.dll:\
	:gtags_parser=Lua\:$globallib/pygments-parser.dll:\
	:gtags_parser=MAQL\:$globallib/pygments-parser.dll:\
	:gtags_parser=MOOCode\:$globallib/pygments-parser.dll:\
	:gtags_parser=MXML\:$globallib/pygments-parser.dll:\
	:gtags_parser=Mako\:$globallib/pygments-parser.dll:\
	:gtags_parser=Mason\:$globallib/pygments-parser.dll:\
	:gtags_parser=Matlab\:$globallib/pygments-parser.dll:\
	:gtags_parser=MiniD\:$globallib/pygments-parser.dll:\
	:gtags_parser=Modelica\:$globallib/pygments-parser.dll:\
	:gtags_parser=Modula2\:$globallib/pygments-parser.dll:\
	:gtags_parser=Monkey\:$globallib/pygments-parser.dll:\
	:gtags_parser=MoonScript\:$globallib/pygments-parser.dll:\
	:gtags_parser=MuPAD\:$globallib/pygments-parser.dll:\
	:gtags_parser=Myghty\:$globallib/pygments-parser.dll:\
	:gtags_parser=NASM\:$globallib/pygments-parser.dll:\
	:gtags_parser=NSIS\:$globallib/pygments-parser.dll:\
	:gtags_parser=Nemerle\:$globallib/pygments-parser.dll:\
	:gtags_parser=NewLisp\:$globallib/pygments-parser.dll:\
	:gtags_parser=Newspeak\:$globallib/pygments-parser.dll:\
	:gtags_parser=Nimrod\:$globallib/pygments-parser.dll:\
	:gtags_parser=OCaml\:$globallib/pygments-parser.dll:\
	:gtags_parser=Objective-C++\:$globallib/pygments-parser.dll:\
	:gtags_parser=Objective-C\:$globallib/pygments-parser.dll:\
	:gtags_parser=Objective-J\:$globallib/pygments-parser.dll:\
	:gtags_parser=Octave\:$globallib/pygments-parser.dll:\
	:gtags_parser=Ooc\:$globallib/pygments-parser.dll:\
	:gtags_parser=Opa\:$globallib/pygments-parser.dll:\
	:gtags_parser=OpenEdge\:$globallib/pygments-parser.dll:\
	:gtags_parser=PHP\:$globallib/pygments-parser.dll:\
	:gtags_parser=Pascal\:$globallib/pygments-parser.dll:\
	:gtags_parser=Perl\:$globallib/pygments-parser.dll:\
	:gtags_parser=PostScript\:$globallib/pygments-parser.dll:\
	:gtags_parser=PowerShell\:$globallib/pygments-parser.dll:\
	:gtags_parser=Prolog\:$globallib/pygments-parser.dll:\
	:gtags_parser=Python\:$globallib/pygments-parser.dll:\
	:gtags_parser=QML\:$globallib/pygments-parser.dll:\
	:gtags_parser=REBOL\:$globallib/pygments-parser.dll:\
	:gtags_parser=RHTML\:$globallib/pygments-parser.dll:\
	:gtags_parser=Racket\:$globallib/pygments-parser.dll:\
	:gtags_parser=Ragel\:$globallib/pygments-parser.dll:\
	:gtags_parser=Redcode\:$globallib/pygments-parser.dll:\
	:gtags_parser=RobotFramework\:$globallib/pygments-parser.dll:\
	:gtags_parser=Ruby\:$globallib/pygments-parser.dll:\
	:gtags_parser=Rust\:$globallib/pygments-parser.dll:\
	:gtags_parser=S\:$globallib/pygments-parser.dll:\
	:gtags_parser=Scala\:$globallib/pygments-parser.dll:\
	:gtags_parser=Scaml\:$globallib/pygments-parser.dll:\
	:gtags_parser=Scheme\:$globallib/pygments-parser.dll:\
	:gtags_parser=Scilab\:$globallib/pygments-parser.dll:\
	:gtags_parser=Smalltalk\:$globallib/pygments-parser.dll:\
	:gtags_parser=Smarty\:$globallib/pygments-parser.dll:\
	:gtags_parser=Sml\:$globallib/pygments-parser.dll:\
	:gtags_parser=Snobol\:$globallib/pygments-parser.dll:\
	:gtags_parser=SourcePawn\:$globallib/pygments-parser.dll:\
	:gtags_parser=Spitfire\:$globallib/pygments-parser.dll:\
	:gtags_parser=Ssp\:$globallib/pygments-parser.dll:\
	:gtags_parser=Stan\:$globallib/pygments-parser.dll:\
	:gtags_parser=SystemVerilog\:$globallib/pygments-parser.dll:\
	:gtags_parser=Tcl\:$globallib/pygments-parser.dll:\
	:gtags_parser=TeX\:$globallib/pygments-parser.dll:\
	:gtags_parser=Tea\:$globallib/pygments-parser.dll:\
	:gtags_parser=Treetop\:$globallib/pygments-parser.dll:\
	:gtags_parser=TypeScript\:$globallib/pygments-parser.dll:\
	:gtags_parser=UrbiScript\:$globallib/pygments-parser.dll:\
	:gtags_parser=VB.net\:$globallib/pygments-parser.dll:\
	:gtags_parser=VGL\:$globallib/pygments-parser.dll:\
	:gtags_parser=Vala\:$globallib/pygments-parser.dll:\
	:gtags_parser=Velocity\:$globallib/pygments-parser.dll:\
	:gtags_parser=Verilog\:$globallib/pygments-parser.dll:\
	:gtags_parser=Vhdl\:$globallib/pygments-parser.dll:\
	:gtags_parser=Vim\:$globallib/pygments-parser.dll:\
	:gtags_parser=XBase\:$globallib/pygments-parser.dll:\
	:gtags_parser=XQuery\:$globallib/pygments-parser.dll:\
	:gtags_parser=XSLT\:$globallib/pygments-parser.dll:\
	:gtags_parser=Xtend\:$globallib/pygments-parser.dll:
#
# Drupal configuration.
#
drupal|Drupal content management platform:\
	:tc=common:\
	:langmap=php\:.php.module.inc.profile.install.test:
#---------------------------------------------------------------------
# Configuration for htags(1)
#---------------------------------------------------------------------
htags:\
	::
"@ | Set-Content -Path "$name" -Force -Encoding Ascii

Write-Host "$name created."
}


main

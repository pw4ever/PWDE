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
$globallib=[System.IO.Path]::Combine($prefix, "global", "lib", "gtags").Replace("\", "/").Replace(":", "\:")

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
	:tc=native:tc=pygments-parser:
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
	:gtags_parser=c\:../lib/gtags/user-custom:
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
	:gtags_parser=Asm\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Asp\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Awk\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Basic\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=BETA\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=C\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=C++\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=C#\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Cobol\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=DosBatch\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Eiffel\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Erlang\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Flex\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Fortran\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=HTML\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Java\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=JavaScript\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Lisp\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Lua\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=MatLab\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=OCaml\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Pascal\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Perl\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=PHP\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Python\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=REXX\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Ruby\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Scheme\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Sh\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=SLang\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=SML\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=SQL\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Tcl\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Tex\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Vera\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Verilog\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=VHDL\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=Vim\:../lib/gtags/exuberant-ctags:\
	:gtags_parser=YACC\:../lib/gtags/exuberant-ctags:
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
	:langmap=Clojure\:.clj.cljs.cljc:\
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
	:gtags_parser=ABAP\:./lib/gtags/pygments-parser:\
	:gtags_parser=ANTLR\:./lib/gtags/pygments-parser:\
	:gtags_parser=ActionScript3\:./lib/gtags/pygments-parser:\
	:gtags_parser=Ada\:./lib/gtags/pygments-parser:\
	:gtags_parser=AppleScript\:./lib/gtags/pygments-parser:\
	:gtags_parser=AspectJ\:./lib/gtags/pygments-parser:\
	:gtags_parser=Aspx-cs\:./lib/gtags/pygments-parser:\
	:gtags_parser=Asymptote\:./lib/gtags/pygments-parser:\
	:gtags_parser=AutoIt\:./lib/gtags/pygments-parser:\
	:gtags_parser=Awk\:./lib/gtags/pygments-parser:\
	:gtags_parser=BUGS\:./lib/gtags/pygments-parser:\
	:gtags_parser=Bash\:./lib/gtags/pygments-parser:\
	:gtags_parser=Bat\:./lib/gtags/pygments-parser:\
	:gtags_parser=BlitzMax\:./lib/gtags/pygments-parser:\
	:gtags_parser=Boo\:./lib/gtags/pygments-parser:\
	:gtags_parser=Bro\:./lib/gtags/pygments-parser:\
	:gtags_parser=C#\:./lib/gtags/pygments-parser:\
	:gtags_parser=C++\:./lib/gtags/pygments-parser:\
	:gtags_parser=COBOLFree\:./lib/gtags/pygments-parser:\
	:gtags_parser=COBOL\:./lib/gtags/pygments-parser:\
	:gtags_parser=CUDA\:./lib/gtags/pygments-parser:\
	:gtags_parser=C\:./lib/gtags/pygments-parser:\
	:gtags_parser=Ceylon\:./lib/gtags/pygments-parser:\
	:gtags_parser=Cfm\:./lib/gtags/pygments-parser:\
	:gtags_parser=Clojure\:./lib/gtags/pygments-parser:\
	:gtags_parser=CoffeeScript\:./lib/gtags/pygments-parser:\
	:gtags_parser=Common-Lisp\:./lib/gtags/pygments-parser:\
	:gtags_parser=Coq\:./lib/gtags/pygments-parser:\
	:gtags_parser=Croc\:./lib/gtags/pygments-parser:\
	:gtags_parser=Csh\:./lib/gtags/pygments-parser:\
	:gtags_parser=Cython\:./lib/gtags/pygments-parser:\
	:gtags_parser=Dart\:./lib/gtags/pygments-parser:\
	:gtags_parser=Dg\:./lib/gtags/pygments-parser:\
	:gtags_parser=Duel\:./lib/gtags/pygments-parser:\
	:gtags_parser=Dylan\:./lib/gtags/pygments-parser:\
	:gtags_parser=ECL\:./lib/gtags/pygments-parser:\
	:gtags_parser=EC\:./lib/gtags/pygments-parser:\
	:gtags_parser=ERB\:./lib/gtags/pygments-parser:\
	:gtags_parser=Elixir\:./lib/gtags/pygments-parser:\
	:gtags_parser=Erlang\:./lib/gtags/pygments-parser:\
	:gtags_parser=Evoque\:./lib/gtags/pygments-parser:\
	:gtags_parser=FSharp\:./lib/gtags/pygments-parser:\
	:gtags_parser=Factor\:./lib/gtags/pygments-parser:\
	:gtags_parser=Fancy\:./lib/gtags/pygments-parser:\
	:gtags_parser=Fantom\:./lib/gtags/pygments-parser:\
	:gtags_parser=Felix\:./lib/gtags/pygments-parser:\
	:gtags_parser=Fortran\:./lib/gtags/pygments-parser:\
	:gtags_parser=GAS\:./lib/gtags/pygments-parser:\
	:gtags_parser=GLSL\:./lib/gtags/pygments-parser:\
	:gtags_parser=Genshi\:./lib/gtags/pygments-parser:\
	:gtags_parser=Gherkin\:./lib/gtags/pygments-parser:\
	:gtags_parser=Gnuplot\:./lib/gtags/pygments-parser:\
	:gtags_parser=Go\:./lib/gtags/pygments-parser:\
	:gtags_parser=GoodData-CL\:./lib/gtags/pygments-parser:\
	:gtags_parser=Gosu\:./lib/gtags/pygments-parser:\
	:gtags_parser=Groovy\:./lib/gtags/pygments-parser:\
	:gtags_parser=Gst\:./lib/gtags/pygments-parser:\
	:gtags_parser=HaXe\:./lib/gtags/pygments-parser:\
	:gtags_parser=Haml\:./lib/gtags/pygments-parser:\
	:gtags_parser=Haskell\:./lib/gtags/pygments-parser:\
	:gtags_parser=Hxml\:./lib/gtags/pygments-parser:\
	:gtags_parser=Hybris\:./lib/gtags/pygments-parser:\
	:gtags_parser=IDL\:./lib/gtags/pygments-parser:\
	:gtags_parser=Io\:./lib/gtags/pygments-parser:\
	:gtags_parser=Ioke\:./lib/gtags/pygments-parser:\
	:gtags_parser=JAGS\:./lib/gtags/pygments-parser:\
	:gtags_parser=Jade\:./lib/gtags/pygments-parser:\
	:gtags_parser=JavaScript\:./lib/gtags/pygments-parser:\
	:gtags_parser=Java\:./lib/gtags/pygments-parser:\
	:gtags_parser=Jsp\:./lib/gtags/pygments-parser:\
	:gtags_parser=Julia\:./lib/gtags/pygments-parser:\
	:gtags_parser=Koka\:./lib/gtags/pygments-parser:\
	:gtags_parser=Kotlin\:./lib/gtags/pygments-parser:\
	:gtags_parser=LLVM\:./lib/gtags/pygments-parser:\
	:gtags_parser=Lasso\:./lib/gtags/pygments-parser:\
	:gtags_parser=Literate-Haskell\:./lib/gtags/pygments-parser:\
	:gtags_parser=LiveScript\:./lib/gtags/pygments-parser:\
	:gtags_parser=Logos\:./lib/gtags/pygments-parser:\
	:gtags_parser=Logtalk\:./lib/gtags/pygments-parser:\
	:gtags_parser=Lua\:./lib/gtags/pygments-parser:\
	:gtags_parser=MAQL\:./lib/gtags/pygments-parser:\
	:gtags_parser=MOOCode\:./lib/gtags/pygments-parser:\
	:gtags_parser=MXML\:./lib/gtags/pygments-parser:\
	:gtags_parser=Mako\:./lib/gtags/pygments-parser:\
	:gtags_parser=Mason\:./lib/gtags/pygments-parser:\
	:gtags_parser=Matlab\:./lib/gtags/pygments-parser:\
	:gtags_parser=MiniD\:./lib/gtags/pygments-parser:\
	:gtags_parser=Modelica\:./lib/gtags/pygments-parser:\
	:gtags_parser=Modula2\:./lib/gtags/pygments-parser:\
	:gtags_parser=Monkey\:./lib/gtags/pygments-parser:\
	:gtags_parser=MoonScript\:./lib/gtags/pygments-parser:\
	:gtags_parser=MuPAD\:./lib/gtags/pygments-parser:\
	:gtags_parser=Myghty\:./lib/gtags/pygments-parser:\
	:gtags_parser=NASM\:./lib/gtags/pygments-parser:\
	:gtags_parser=NSIS\:./lib/gtags/pygments-parser:\
	:gtags_parser=Nemerle\:./lib/gtags/pygments-parser:\
	:gtags_parser=NewLisp\:./lib/gtags/pygments-parser:\
	:gtags_parser=Newspeak\:./lib/gtags/pygments-parser:\
	:gtags_parser=Nimrod\:./lib/gtags/pygments-parser:\
	:gtags_parser=OCaml\:./lib/gtags/pygments-parser:\
	:gtags_parser=Objective-C++\:./lib/gtags/pygments-parser:\
	:gtags_parser=Objective-C\:./lib/gtags/pygments-parser:\
	:gtags_parser=Objective-J\:./lib/gtags/pygments-parser:\
	:gtags_parser=Octave\:./lib/gtags/pygments-parser:\
	:gtags_parser=Ooc\:./lib/gtags/pygments-parser:\
	:gtags_parser=Opa\:./lib/gtags/pygments-parser:\
	:gtags_parser=OpenEdge\:./lib/gtags/pygments-parser:\
	:gtags_parser=PHP\:./lib/gtags/pygments-parser:\
	:gtags_parser=Pascal\:./lib/gtags/pygments-parser:\
	:gtags_parser=Perl\:./lib/gtags/pygments-parser:\
	:gtags_parser=PostScript\:./lib/gtags/pygments-parser:\
	:gtags_parser=PowerShell\:./lib/gtags/pygments-parser:\
	:gtags_parser=Prolog\:./lib/gtags/pygments-parser:\
	:gtags_parser=Python\:./lib/gtags/pygments-parser:\
	:gtags_parser=QML\:./lib/gtags/pygments-parser:\
	:gtags_parser=REBOL\:./lib/gtags/pygments-parser:\
	:gtags_parser=RHTML\:./lib/gtags/pygments-parser:\
	:gtags_parser=Racket\:./lib/gtags/pygments-parser:\
	:gtags_parser=Ragel\:./lib/gtags/pygments-parser:\
	:gtags_parser=Redcode\:./lib/gtags/pygments-parser:\
	:gtags_parser=RobotFramework\:./lib/gtags/pygments-parser:\
	:gtags_parser=Ruby\:./lib/gtags/pygments-parser:\
	:gtags_parser=Rust\:./lib/gtags/pygments-parser:\
	:gtags_parser=S\:./lib/gtags/pygments-parser:\
	:gtags_parser=Scala\:./lib/gtags/pygments-parser:\
	:gtags_parser=Scaml\:./lib/gtags/pygments-parser:\
	:gtags_parser=Scheme\:./lib/gtags/pygments-parser:\
	:gtags_parser=Scilab\:./lib/gtags/pygments-parser:\
	:gtags_parser=Smalltalk\:./lib/gtags/pygments-parser:\
	:gtags_parser=Smarty\:./lib/gtags/pygments-parser:\
	:gtags_parser=Sml\:./lib/gtags/pygments-parser:\
	:gtags_parser=Snobol\:./lib/gtags/pygments-parser:\
	:gtags_parser=SourcePawn\:./lib/gtags/pygments-parser:\
	:gtags_parser=Spitfire\:./lib/gtags/pygments-parser:\
	:gtags_parser=Ssp\:./lib/gtags/pygments-parser:\
	:gtags_parser=Stan\:./lib/gtags/pygments-parser:\
	:gtags_parser=SystemVerilog\:./lib/gtags/pygments-parser:\
	:gtags_parser=Tcl\:./lib/gtags/pygments-parser:\
	:gtags_parser=TeX\:./lib/gtags/pygments-parser:\
	:gtags_parser=Tea\:./lib/gtags/pygments-parser:\
	:gtags_parser=Treetop\:./lib/gtags/pygments-parser:\
	:gtags_parser=TypeScript\:./lib/gtags/pygments-parser:\
	:gtags_parser=UrbiScript\:./lib/gtags/pygments-parser:\
	:gtags_parser=VB.net\:./lib/gtags/pygments-parser:\
	:gtags_parser=VGL\:./lib/gtags/pygments-parser:\
	:gtags_parser=Vala\:./lib/gtags/pygments-parser:\
	:gtags_parser=Velocity\:./lib/gtags/pygments-parser:\
	:gtags_parser=Verilog\:./lib/gtags/pygments-parser:\
	:gtags_parser=Vhdl\:./lib/gtags/pygments-parser:\
	:gtags_parser=Vim\:./lib/gtags/pygments-parser:\
	:gtags_parser=XBase\:./lib/gtags/pygments-parser:\
	:gtags_parser=XQuery\:./lib/gtags/pygments-parser:\
	:gtags_parser=XSLT\:./lib/gtags/pygments-parser:\
	:gtags_parser=Xtend\:./lib/gtags/pygments-parser:
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

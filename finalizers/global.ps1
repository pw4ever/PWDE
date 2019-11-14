<#
.SYNOPSIS
  Portable Windows Development Environment (PWDE) finalizer.
.PARAMETER Destination
  Destination path.
#>

[CmdletBinding(
SupportsShouldProcess=$True,
PositionalBinding=$False
)]
param(
    [Parameter(
    HelpMessage="Destination path.",
    Mandatory=$True
    )]
    $Destination
)

function ensure-dir ($dir) {
    if (!$(Test-Path $dir)) {
        mkdir $dir -Force > $NULL
        Write-Verbose "$dir created."
    }
}

function main
{
    ensure-dir $Destination
    $Destination=$(Resolve-Path $Destination)

	work $Destination
}


function work ($prefix) {
$prefix=$(Resolve-Path "$prefix")

$name=[System.IO.Path]::Combine($prefix, ".globalrc")
$globallib=[System.IO.Path]::Combine($prefix, "global", "lib", "gtags").Replace("\", "/").Replace(":", "\:")

New-Item -Path "$name" -Force -ItemType File > $NULL

@'
#
# Copyright (c) 1998, 1999, 2000, 2001, 2002, 2003, 2010, 2011, 2013,
#	2015, 2016
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
# "$HOME/.globalrc" in your system then GLOBAL overwrite the default values
# with the values in the file.
#
# The format is similar to termcap(5). You can specify a target with
# GTAGSLABEL environment variable. Default target is 'default'.
#
# If you want to have a common record for yourself, it is recommended to
# use the following method:
#
# default:\
#	:tc=default@~/.globalrc:\	<= Load the default record from ~/.globalrc.
#	:tc=native:
#
default:\
	:tc=native:
native:\
	:tc=gtags:tc=htags:
user:\
	:tc=user-custom:tc=htags:
ctags:\
	:tc=exuberant-ctags:tc=htags:
new-ctags:\
	:tc=universal-ctags:tc=htags:
pygments:\
	:tc=pygments-parser:tc=htags:
#---------------------------------------------------------------------
# Configuration for gtags(1)
# See gtags(1).
#---------------------------------------------------------------------
common:\
	:skip=HTML/,HTML.pub/,tags,TAGS,ID,y.tab.c,y.tab.h,gtags.files,cscope.files,cscope.out,cscope.po.out,cscope.in.out,SCCS/,RCS/,CVS/,CVSROOT/,{arch}/,autom4te.cache/,*.orig,*.rej,*.bak,*~,#*#,*.swp,*.tmp,*_flymake.*,*_flymake,*.o,*.a,*.so,*.lo,*.zip,*.gz,*.bz2,*.xz,*.lzh,*.Z,*.tgz,*.min.js,*min.css:
#
# Built-in parsers.
#
gtags:\
	:tc=common:\
	:tc=builtin-parser:
builtin-parser:\
	:langmap=c\:.c.h.w,yacc\:.y,asm\:.s.S.asm.ASM,java\:.java,cpp\:.c++.cc.hh.cpp.cxx.hxx.hpp.C.H,php\:.php.php3.phtml:
#
# skeleton for user's custom parser.
#
user-custom|User custom plugin parser:\
	:tc=common:\
	:langmap=c\:.c.h:\
	:gtags_parser=c\:$libdir/gtags/user-custom.la:
#
# Plug-in parser to use Exuberant Ctags.
#
exuberant-ctags|plugin-example|setting to use Exuberant Ctags plug-in parser:\
	:tc=common:\
	:ctagscom=ctags:\
	:ctagslib=$libdir/gtags/exuberant-ctags.la:\
	:tc=common-ctags-maps:\
	:langmap=C++\:.c++.cc.cp.cpp.cxx.h.h++.hh.hp.hpp.hxx:\
	:langmap=Fortran\:.f.for.ftn.f77.f90.f95:\
	:langmap=OCaml\:.ml.mli:\
	:langmap=Perl\:.pl.pm.plx.perl:\
	:langmap=PHP\:.php.php3.phtml:\
	:langmap=Sh\:.sh.SH.bsh.bash.ksh.zsh:\
	:langmap=Vim\:.vim:
#
# A common map for both Exuberant Ctags and Universal Ctags.
# Don't include definitions of ctagscom and ctagslib in this entry.
#
common-ctags-maps:\
# Ant      *.build.xml				(out of support)
# Asm      *.[68][68][kKsSxX] *.[xX][68][68]	(out of support)
	:langmap=Asm\:.asm.ASM.s.S.A51.29k.29K:\
	:langmap=Asp\:.asp.asa:\
	:langmap=Awk\:.awk.gawk.mawk:\
	:langmap=Basic\:.bas.bi.bb.pb:\
	:langmap=BETA\:.bet:\
	:langmap=C\:.c:\
	:langmap=C#\:.cs:\
	:langmap=Cobol\:.cbl.cob.CBL.COB:\
	:langmap=DosBatch\:.bat.cmd:\
	:langmap=Eiffel\:.e:\
	:langmap=Erlang\:.erl.ERL.hrl.HRL:\
	:langmap=Flex\:.as.mxml:\
	:langmap=HTML\:.htm.html:\
	:langmap=Java\:.java:\
	:langmap=JavaScript\:.js:\
	:langmap=Lisp\:.cl.clisp.el.l.lisp.lsp:\
	:langmap=Lua\:.lua:\
# Make	[Mm]akefile GNUmakefile			(out of support)
	:langmap=Make\:.mak.mk:\
	:langmap=MatLab\:.m:\
	:langmap=Pascal\:.p.pas:\
	:langmap=Python\:.py.pyx.pxd.pxi.scons:\
	:langmap=REXX\:.cmd.rexx.rx:\
	:langmap=Ruby\:.rb.ruby:\
	:langmap=Scheme\:.SCM.SM.sch.scheme.scm.sm:\
	:langmap=SLang\:.sl:\
	:langmap=SML\:.sml.sig:\
	:langmap=SQL\:.sql:\
	:langmap=Tcl\:.tcl.tk.wish.itcl:\
	:langmap=Tex\:.tex:\
	:langmap=Vera\:.vr.vri.vrh:\
	:langmap=Verilog\:.v:\
	:langmap=VHDL\:.vhdl.vhd:\
	:langmap=YACC\:.y:\
	:gtags_parser=Asm\:$ctagslib:\
	:gtags_parser=Asp\:$ctagslib:\
	:gtags_parser=Awk\:$ctagslib:\
	:gtags_parser=Basic\:$ctagslib:\
	:gtags_parser=BETA\:$ctagslib:\
	:gtags_parser=C\:$ctagslib:\
	:gtags_parser=C++\:$ctagslib:\
	:gtags_parser=C#\:$ctagslib:\
	:gtags_parser=Cobol\:$ctagslib:\
	:gtags_parser=DosBatch\:$ctagslib:\
	:gtags_parser=Eiffel\:$ctagslib:\
	:gtags_parser=Erlang\:$ctagslib:\
	:gtags_parser=Flex\:$ctagslib:\
	:gtags_parser=Fortran\:$ctagslib:\
	:gtags_parser=HTML\:$ctagslib:\
	:gtags_parser=Java\:$ctagslib:\
	:gtags_parser=JavaScript\:$ctagslib:\
	:gtags_parser=Lisp\:$ctagslib:\
	:gtags_parser=Lua\:$ctagslib:\
	:gtags_parser=Make\:$ctagslib:\
	:gtags_parser=MatLab\:$ctagslib:\
	:gtags_parser=OCaml\:$ctagslib:\
	:gtags_parser=Pascal\:$ctagslib:\
	:gtags_parser=Perl\:$ctagslib:\
	:gtags_parser=PHP\:$ctagslib:\
	:gtags_parser=Python\:$ctagslib:\
	:gtags_parser=REXX\:$ctagslib:\
	:gtags_parser=Ruby\:$ctagslib:\
	:gtags_parser=Scheme\:$ctagslib:\
	:gtags_parser=Sh\:$ctagslib:\
	:gtags_parser=SLang\:$ctagslib:\
	:gtags_parser=SML\:$ctagslib:\
	:gtags_parser=SQL\:$ctagslib:\
	:gtags_parser=Tcl\:$ctagslib:\
	:gtags_parser=Tex\:$ctagslib:\
	:gtags_parser=Vera\:$ctagslib:\
	:gtags_parser=Verilog\:$ctagslib:\
	:gtags_parser=VHDL\:$ctagslib:\
	:gtags_parser=Vim\:$ctagslib:\
	:gtags_parser=YACC\:$ctagslib:
#
# Plug-in parser to use Universal Ctags.
#
universal-ctags|setting to use Universal Ctags plug-in parser:\
	:tc=common:\
	:ctagscom=ctags:\
	:ctagslib=$libdir/gtags/universal-ctags.la:\
	:tc=common-ctags-maps:\
	:langmap=Ada\:.adb.ads.Ada:\
	:langmap=Ant\:.ant:\
	:langmap=Clojure\:.clj:\
	:langmap=CoffeeScript\:.coffee:\
	:langmap=C++\:.c++.cc.cp.cpp.cxx.h.h++.hh.hp.hpp.hxx.inl:\
	:langmap=CSS\:.css:\
	:langmap=ctags\:.ctags:\
	:langmap=D\:.d.di:\
	:langmap=Diff\:.diff.patch:\
	:langmap=DTS\:.dts.dtsi:\
	:langmap=Falcon\:.fal.ftd:\
	:langmap=Fortran\:.f.for.ftn.f77.f90.f95.f03.f08.f15:\
# gdbinit .gdbinit				(out of support)
	:langmap=gdbinit\:.gdb:\
	:langmap=Go\:.go:\
	:langmap=JSON\:.json:\
	:langmap=m4\:.m4.spt:\
	:langmap=ObjectiveC\:.mm.m.h:\
	:langmap=OCaml\:.ml.mli.aug:\
	:langmap=Perl\:.pl.pm.plx.perl.ph:\
	:langmap=Perl6\:.p6.pm6.pm.pl6:\
	:langmap=PHP\:.php.php3.phtml.php4.php5.php7:\
	:langmap=R\:.r.R.s.q:\
	:langmap=reStructuredText\:.rest.reST.rst:\
	:langmap=Rust\:.rs:\
	:langmap=Sh\:.sh.SH.bsh.bash.ksh.zsh.ash:\
	:langmap=SystemVerilog\:.sv.svh.svi:\
# Vim	vimrc [._]vimrc gvimrc [._]gvimrc	(out of support)
	:langmap=Vim\:.vim.vba:\
	:langmap=WindRes\:.rc:\
	:langmap=Zephir\:.zep:\
#	:langmap=DBusIntrospect\:.xml:\
#	:langmap=Glade\:.glade:\
	:gtags_parser=Ada\:$ctagslib:\
	:gtags_parser=Ant\:$ctagslib:\
	:gtags_parser=Clojure\:$ctagslib:\
	:gtags_parser=CoffeeScript\:$ctagslib:\
	:gtags_parser=CSS\:$ctagslib:\
	:gtags_parser=ctags\:$ctagslib:\
	:gtags_parser=D\:$ctagslib:\
	:gtags_parser=Diff\:$ctagslib:\
	:gtags_parser=DTS\:$ctagslib:\
	:gtags_parser=Falcon\:$ctagslib:\
	:gtags_parser=gdbinit\:$ctagslib:\
	:gtags_parser=Go\:$ctagslib:\
	:gtags_parser=JSON\:$ctagslib:\
	:gtags_parser=m4\:$ctagslib:\
	:gtags_parser=ObjectiveC\:$ctagslib:\
	:gtags_parser=Perl6\:$ctagslib:\
	:gtags_parser=R\:$ctagslib:\
	:gtags_parser=reStructuredText\:$ctagslib:\
	:gtags_parser=Rust\:$ctagslib:\
	:gtags_parser=SystemVerilog\:$ctagslib:\
	:gtags_parser=WindRes\:$ctagslib:\
	:gtags_parser=Zephir\:$ctagslib:
#	:gtags_parser=DBusIntrospect\:$ctagslib:\
#	:gtags_parser=Glade\:$ctagslib:
#
# Plug-in parser to use Pygments.
#
pygments-parser|Pygments plug-in parser:\
	:ctagscom=ctags:\
	:pygmentslib=$libdir/gtags/pygments-parser.la:\
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
	:langmap=Clojure\:.clj.cljc.cljs:\
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
	:gtags_parser=ABAP\:$pygmentslib:\
	:gtags_parser=ANTLR\:$pygmentslib:\
	:gtags_parser=ActionScript3\:$pygmentslib:\
	:gtags_parser=Ada\:$pygmentslib:\
	:gtags_parser=AppleScript\:$pygmentslib:\
	:gtags_parser=AspectJ\:$pygmentslib:\
	:gtags_parser=Aspx-cs\:$pygmentslib:\
	:gtags_parser=Asymptote\:$pygmentslib:\
	:gtags_parser=AutoIt\:$pygmentslib:\
	:gtags_parser=Awk\:$pygmentslib:\
	:gtags_parser=BUGS\:$pygmentslib:\
	:gtags_parser=Bash\:$pygmentslib:\
	:gtags_parser=Bat\:$pygmentslib:\
	:gtags_parser=BlitzMax\:$pygmentslib:\
	:gtags_parser=Boo\:$pygmentslib:\
	:gtags_parser=Bro\:$pygmentslib:\
	:gtags_parser=C#\:$pygmentslib:\
	:gtags_parser=C++\:$pygmentslib:\
	:gtags_parser=COBOLFree\:$pygmentslib:\
	:gtags_parser=COBOL\:$pygmentslib:\
	:gtags_parser=CUDA\:$pygmentslib:\
	:gtags_parser=C\:$pygmentslib:\
	:gtags_parser=Ceylon\:$pygmentslib:\
	:gtags_parser=Cfm\:$pygmentslib:\
	:gtags_parser=Clojure\:$pygmentslib:\
	:gtags_parser=CoffeeScript\:$pygmentslib:\
	:gtags_parser=Common-Lisp\:$pygmentslib:\
	:gtags_parser=Coq\:$pygmentslib:\
	:gtags_parser=Croc\:$pygmentslib:\
	:gtags_parser=Csh\:$pygmentslib:\
	:gtags_parser=Cython\:$pygmentslib:\
	:gtags_parser=Dart\:$pygmentslib:\
	:gtags_parser=Dg\:$pygmentslib:\
	:gtags_parser=Duel\:$pygmentslib:\
	:gtags_parser=Dylan\:$pygmentslib:\
	:gtags_parser=ECL\:$pygmentslib:\
	:gtags_parser=EC\:$pygmentslib:\
	:gtags_parser=ERB\:$pygmentslib:\
	:gtags_parser=Elixir\:$pygmentslib:\
	:gtags_parser=Erlang\:$pygmentslib:\
	:gtags_parser=Evoque\:$pygmentslib:\
	:gtags_parser=FSharp\:$pygmentslib:\
	:gtags_parser=Factor\:$pygmentslib:\
	:gtags_parser=Fancy\:$pygmentslib:\
	:gtags_parser=Fantom\:$pygmentslib:\
	:gtags_parser=Felix\:$pygmentslib:\
	:gtags_parser=Fortran\:$pygmentslib:\
	:gtags_parser=GAS\:$pygmentslib:\
	:gtags_parser=GLSL\:$pygmentslib:\
	:gtags_parser=Genshi\:$pygmentslib:\
	:gtags_parser=Gherkin\:$pygmentslib:\
	:gtags_parser=Gnuplot\:$pygmentslib:\
	:gtags_parser=Go\:$pygmentslib:\
	:gtags_parser=GoodData-CL\:$pygmentslib:\
	:gtags_parser=Gosu\:$pygmentslib:\
	:gtags_parser=Groovy\:$pygmentslib:\
	:gtags_parser=Gst\:$pygmentslib:\
	:gtags_parser=HaXe\:$pygmentslib:\
	:gtags_parser=Haml\:$pygmentslib:\
	:gtags_parser=Haskell\:$pygmentslib:\
	:gtags_parser=Hxml\:$pygmentslib:\
	:gtags_parser=Hybris\:$pygmentslib:\
	:gtags_parser=IDL\:$pygmentslib:\
	:gtags_parser=Io\:$pygmentslib:\
	:gtags_parser=Ioke\:$pygmentslib:\
	:gtags_parser=JAGS\:$pygmentslib:\
	:gtags_parser=Jade\:$pygmentslib:\
	:gtags_parser=JavaScript\:$pygmentslib:\
	:gtags_parser=Java\:$pygmentslib:\
	:gtags_parser=Jsp\:$pygmentslib:\
	:gtags_parser=Julia\:$pygmentslib:\
	:gtags_parser=Koka\:$pygmentslib:\
	:gtags_parser=Kotlin\:$pygmentslib:\
	:gtags_parser=LLVM\:$pygmentslib:\
	:gtags_parser=Lasso\:$pygmentslib:\
	:gtags_parser=Literate-Haskell\:$pygmentslib:\
	:gtags_parser=LiveScript\:$pygmentslib:\
	:gtags_parser=Logos\:$pygmentslib:\
	:gtags_parser=Logtalk\:$pygmentslib:\
	:gtags_parser=Lua\:$pygmentslib:\
	:gtags_parser=MAQL\:$pygmentslib:\
	:gtags_parser=MOOCode\:$pygmentslib:\
	:gtags_parser=MXML\:$pygmentslib:\
	:gtags_parser=Mako\:$pygmentslib:\
	:gtags_parser=Mason\:$pygmentslib:\
	:gtags_parser=Matlab\:$pygmentslib:\
	:gtags_parser=MiniD\:$pygmentslib:\
	:gtags_parser=Modelica\:$pygmentslib:\
	:gtags_parser=Modula2\:$pygmentslib:\
	:gtags_parser=Monkey\:$pygmentslib:\
	:gtags_parser=MoonScript\:$pygmentslib:\
	:gtags_parser=MuPAD\:$pygmentslib:\
	:gtags_parser=Myghty\:$pygmentslib:\
	:gtags_parser=NASM\:$pygmentslib:\
	:gtags_parser=NSIS\:$pygmentslib:\
	:gtags_parser=Nemerle\:$pygmentslib:\
	:gtags_parser=NewLisp\:$pygmentslib:\
	:gtags_parser=Newspeak\:$pygmentslib:\
	:gtags_parser=Nimrod\:$pygmentslib:\
	:gtags_parser=OCaml\:$pygmentslib:\
	:gtags_parser=Objective-C++\:$pygmentslib:\
	:gtags_parser=Objective-C\:$pygmentslib:\
	:gtags_parser=Objective-J\:$pygmentslib:\
	:gtags_parser=Octave\:$pygmentslib:\
	:gtags_parser=Ooc\:$pygmentslib:\
	:gtags_parser=Opa\:$pygmentslib:\
	:gtags_parser=OpenEdge\:$pygmentslib:\
	:gtags_parser=PHP\:$pygmentslib:\
	:gtags_parser=Pascal\:$pygmentslib:\
	:gtags_parser=Perl\:$pygmentslib:\
	:gtags_parser=PostScript\:$pygmentslib:\
	:gtags_parser=PowerShell\:$pygmentslib:\
	:gtags_parser=Prolog\:$pygmentslib:\
	:gtags_parser=Python\:$pygmentslib:\
	:gtags_parser=QML\:$pygmentslib:\
	:gtags_parser=REBOL\:$pygmentslib:\
	:gtags_parser=RHTML\:$pygmentslib:\
	:gtags_parser=Racket\:$pygmentslib:\
	:gtags_parser=Ragel\:$pygmentslib:\
	:gtags_parser=Redcode\:$pygmentslib:\
	:gtags_parser=RobotFramework\:$pygmentslib:\
	:gtags_parser=Ruby\:$pygmentslib:\
	:gtags_parser=Rust\:$pygmentslib:\
	:gtags_parser=S\:$pygmentslib:\
	:gtags_parser=Scala\:$pygmentslib:\
	:gtags_parser=Scaml\:$pygmentslib:\
	:gtags_parser=Scheme\:$pygmentslib:\
	:gtags_parser=Scilab\:$pygmentslib:\
	:gtags_parser=Smalltalk\:$pygmentslib:\
	:gtags_parser=Smarty\:$pygmentslib:\
	:gtags_parser=Sml\:$pygmentslib:\
	:gtags_parser=Snobol\:$pygmentslib:\
	:gtags_parser=SourcePawn\:$pygmentslib:\
	:gtags_parser=Spitfire\:$pygmentslib:\
	:gtags_parser=Ssp\:$pygmentslib:\
	:gtags_parser=Stan\:$pygmentslib:\
	:gtags_parser=SystemVerilog\:$pygmentslib:\
	:gtags_parser=Tcl\:$pygmentslib:\
	:gtags_parser=TeX\:$pygmentslib:\
	:gtags_parser=Tea\:$pygmentslib:\
	:gtags_parser=Treetop\:$pygmentslib:\
	:gtags_parser=TypeScript\:$pygmentslib:\
	:gtags_parser=UrbiScript\:$pygmentslib:\
	:gtags_parser=VB.net\:$pygmentslib:\
	:gtags_parser=VGL\:$pygmentslib:\
	:gtags_parser=Vala\:$pygmentslib:\
	:gtags_parser=Velocity\:$pygmentslib:\
	:gtags_parser=Verilog\:$pygmentslib:\
	:gtags_parser=Vhdl\:$pygmentslib:\
	:gtags_parser=Vim\:$pygmentslib:\
	:gtags_parser=XBase\:$pygmentslib:\
	:gtags_parser=XQuery\:$pygmentslib:\
	:gtags_parser=XSLT\:$pygmentslib:\
	:gtags_parser=Xtend\:$pygmentslib:
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
'@ | Set-Content -Path "$name" -Force -Encoding Ascii

	Write-Verbose "$name created."
}


main
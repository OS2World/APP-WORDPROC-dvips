/*--------------------------------------------------------------------------*/
    README.EMX (OS/2 and DOS)				    November 19, 1998
/*--------------------------------------------------------------------------*/

This is dvips 5.83 that was compiled with emx/gcc 0.9c fix04 under OS/2 Warp
3.0.  For dvips usage, read the dvips user's manual (emtex\doc\dvips\dvips.ps).

The dvips 5.83 sources were patched for emTeX, based on Guido Sawade's patches
to dvips 5.58.	Minor changes and bug fixes were also made in addition to the
old patches.  All compliments for emTeX patches should go to Guido Sawade.

Included executables are OS/2+DOS bound executable, so they will also work
under DOS (VCPI) via EMX runtime library, as well as under Windows (DPMI) with
a RSX runtime libarary.

Under Windows 95/98, the long file names should be supported with RSX runtime
library.  The special option -RO (to emulate OS/2) is not required for this.

If you have installed the latest emTeX distribution, you already have both EMX
and RSX runtime libraries installed on your system.  (They are in emxrsx.zip
in emTeX distribution.)  Win95/98 or NT users may want RSXNT runtime package.
EMX or RSX/RSXNT runtime libraries are available from CTAN sites.

EMX:
    emxrt.zip	-- for DOS (VCPI) and OS/2
    (ftp://hobbes.nmsu.edu/pub/os2/dev/emx/v0.9c/emxrt.zip is the latest.)

RSX:
    rsx*.zip	-- for DOS (DPMI) (DOS box under Windows)
    rsxwin*.zip -- for DOS and Windows 3.1
    rsxn*r.zip	-- RSXNT runtime package for Win95/98 or NT

    Home: http://www.mathematik.uni-bielefeld.de/~rainer/
	  ftp://ftp.uni-bielefeld.de/pub/systems/msdos/misc/

This archive dvips583.zip contains the following files:

    README.EMX		    -- This file
    dvipsexe.zip (required) -- OS/2+DOS bound executables + support files
    contrib.zip  (optional) -- miscellaneous macros & support files for dvips
    patsrc.zip	 (optional) -- Patched source files for emTeX and emx/gcc


INSTALLATION:
------------

(1) If you are the first user of dvips, go to step (2).

    You may want to save your old configuration files in emtex\data\dvips\
    before unpacking.  Then, remove old dvips files from your system by using
    emremove.exe and emtex\remove\dvips*.rem files.  An example would be:

	D:\> emremove emtex\remove\dvips572.rem D:\

(2) Unpack dvipsexe.zip in the parent (usually a root) dir of emTeX tree.
    For example, if you have emtex in D:\emtex, then goto D:\ and unzip by

	D:\> unzip dvipsexe.zip

    I recommend you to use Info-Zip's unzip.  If you are prompted with a
    question of "Overwrite?", answer 'A'll.

(3) You need to update emtex\data\config.ps file for your system.
    If you have used a previous version of dvips, the old config.ps may work.
    Now dvips should work if your emTeX was configured in a standard way.
    For further information about configurations, refer to other documents that
    you can find in emtex\doc\dvips\ and emtex\doc\dvips\old\ (still useful).

(4) For automatic font generations, modify maketexp.{cmd|bat} according to
    the commented instrucions near the end of the batch files.


NOTE 1:  [Distributed executables]
    dvipsexe.zip will unpack dvips32.exe and dvihps32.exe into emtex\bin.
    These files are

	dvips32.exe	-- the regular dvips program without HyperPS feature
	dvihps32.exe	-- the same but with an additional capability of
			   Hyperdvi to HyperPostScript

    dvihps32.exe provides one more option (-z) for Hyperdvi to HyperPostScript,
    otherwise it should give the same output as dvips32.exe.  You may rename
    either one to dvips.exe.  If you don't use HyperTeX, then use dvips32.exe.

NOTE 2:  [OS/2 -- Supporting compressed/gzipped postscript files]
    This version supports gzipped EPS files (*.eps.gz) if they are on an
    OS/2 HPFS partition.  FAT partitions (of DOS or OS/2) are not supported.
    The EPS files (*.eps.Z) created by old unix "compress" should be supported
    as well.  (Extensions of *.ps.gz and *.ps.Z are all supported.)

    An OS/2 REXX script "psgzip.cmd" is provided to create *.eps.gz and
    *.eps.bb (BoundingBox) files to be used with LaTeX2e graphics package.
    (.bb files are necessary if figure sizes were not given in .tex document.)

    For latex graphics package, add the following line in graphics.cfg:

    \ExecuteOptions{dvips}

    And, in "dvips.def" file of graphics package, you may want to change:

    \@namedef{Gin@rule@.eps.Z}#1{{eps}{.eps.bb}{`gunzip -c #1}}
    \@namedef{Gin@rule@.ps.Z}#1{{eps}{.ps.bb}{`gunzip -c #1}}
    \@namedef{Gin@rule@.ps.gz}#1{{eps}{.ps.bb}{`gunzip -c #1}}
    \@namedef{Gin@rule@.eps.gz}#1{{eps}{.eps.bb}{`gunzip -c #1}}

    to:

    \@namedef{Gin@rule@.eps.Z}#1{{eps}{.eps.bb}{#1}}
    \@namedef{Gin@rule@.ps.Z}#1{{eps}{.ps.bb}{#1}}
    \@namedef{Gin@rule@.ps.gz}#1{{eps}{.ps.bb}{#1}}
    \@namedef{Gin@rule@.eps.gz}#1{{eps}{.eps.bb}{#1}}

    for dvips to _search_ and uncompress the compressed ps file.  Otherwise,
    you have to put an explicit path info of a compressed ps file in latex
    document unless the file is in the current dir.

NOTE 3:  [DOS (VCPI) -- If automatic font generation fails under DOS]
    DOS users who use emx runtime module may need to set -p emx option.
    Otherwise, automatic font generation by dvips may fail due to not enough
    DOS conventional free memory.  RSX runtime modules (i.e.  DOS boxes of
    Win3.x/95/98/NT) don't need this setting.  If you run dvips via emTeX's
    dvidrv (by "dvidrv dvips ..."), you may not need -p emx option.  If you
    directly run dvips without using dvidrv, and if you have a problem with
    automatic font generation by dvips (when maketexp bat is configured to run
    mfjob), set EMXOPT environmental variable by

	set EMXOPT=-p

    in your autoexec.bat.

NOTE 4:  [OS/2 & DOS/Win -- Saving dvips screen messages to a file]
    Under OS/2 CMD shell, dvips screen messages can be redirected to a file by

	dvips file.dvi > error.msg 2>&1

    If your command shell doesn't support stderr redirection, EMX or RSX users
    under DOS or Windows* can use -e option of EMX or RSX to redirect stderr to
    stdout, and then redirect stdout to a file.  For example,

	emx -e dvips file.dvi > error.msg
	rsx -e dvips file.dvi > error.msg

    Alternatively, all messages from dvips can be saved to a file by setting
    DVIPS_STDERR environmental variable.  (Do we really need this feature??)
    For this, the environmental variable DVIPS_STDERR should be set to a file
    name before running dvips.	That is, by setting

	set DVIPS_STDERR=error.msg

    all messages from dvips will be saved in the file "error.msg".


KNOWN BUGS/PROBLEMS/LIMITATIONS:
--------------------------------
    - Compressed (.gz) graphics files are not supported on DOS/Win95/98.
    - Problem with partial font downloading for some Chinese PS fonts.
    - Data corruption for binary EPS files if "%%BeginBinary: #" is missing.


CHANGES:
--------
    May 11, 1997
		- Initial release of dvips 5.72 for OS/2+DOS

    May 22, 1997
		- Fixed SIGTRAP by -RO option of RSX on Win95.
		- Long file name support on Win95/NT now doesn't need -RO
		  option of RSX. (Thanks to Ian Bruce and Allin Cottrell
		  for their testing dvips on Win95.)
		- Fixed partial ps fonts download (-j) bug.
		- Renamed epsgzip.cmd to psgzip.cmd.

    July 4, 1997
		- dvips 5.74 for OS2/DOS/emTeX
		- Patched document dvips.tex (dvips.ps) for OS/2 & DOS section
		- afm2tfm.exe was broken in dvips572.zip
		- Fixed append problem with mfjob file creation (-pj) on OS/2
		- patched sources (emdir.c, emdir.h) and makefile for djgpp by
		    Hartmut Schirmer (hsc@techfak.uni-kiel.de)
		- Ignore DVIWIN inverse search specials

    July 9, 1997
		- Removed Ctrl-Z when including gzipped EPS graphics (OS/2).
		- fixed popen() mode (OS/2)

    October 9, 1997
		- dvips 5.76 for OS2/DOS/emTeX

    October 18, 1997 (not released)
		- DVIPS_STDERR env to redirect stderr to a file.
		- Removed path info of dvips program in %DVIPSCommandLine:.
		- Fixed ':' problem in output device names. (':' may be added.)
		- New option 'F' (add Control-D) for configuration file.
		- Modified maketexp.{bat,cmd} for automatic font generation

    December 6, 1997 (not released)
		- fixed bug with binary sections (%%BeginBinary) of EPS files.
		  (new CR-LF codes)

    December 17, 1997
		- faster (> 10x) processing speed for DOS EPSF binary files.

    December 20, 1997 (not released)
		- fixed seek error of popen stream (gzipped DOS EPSF bin file)

    November 19, 1998
		- dvips 5.83

HOW TO REBUILD:
--------------

If you want to recompile, you need to get the original dvips package
(dvips583.tar.gz) from a CTAN site:

    ftp.cdrom.com, ftp.dante.de, ...:
	/pub/tex/dviware/dvips/dvips583.tar.gz
	/tex-archive/dviware/dvips/dvips583.tar.gz

(1) Unpack the original sources in a dir on a HPFS partition, as my makefiles
    are written for long file names.  I didn't care about FAT (8.3 names).

(2) Then unpack patsrc.zip in dvips583\ dir. (chdir dvips583 then unzip.)
    (All necessary patched/additional source files are now in dvips\patch\.)

(3) Now go into dvips\ dir and run "patch\update.cmd". (Sorry for DOS user.)
    This will rename the original source files and copy the patched and
    additional files from patch\*.

(4) Now it's ready to rebuild:  Using GNU make, do one of the following:

    make -f makefile.emx	      create the regular dvips32.exe

    make -f makefile.emx allhps       create dvihps32.exe with HyperPostScript

    ** Get RunFor from
	    ftp://hobbes.nmsu.edu/pub/os2/util/batch/runfor19.zip
	    ftp://ftp.cdrom.com/pub/os2/diskutil/runfor19.zip

    ** djgpp v2 users use makefile.dj2 instead, after copying it from patch\.
       (makefile.dj2 is due to Hartmut Schirmer (hsc@techfak.uni-kiel.de).)

    Make sure the source directory is cleaned before you rebuild again.
    You can clean the source directory by:    make -f makefile.emx clean

    Other make targets (e.g. install, installhps, zipexe, zipsrc, zipcontrib)
    are to create zip archives for distribution.

That's it!


/*----------------------------------------------------------------------*/
Wonkoo Kim (wkim+@pitt.edu)

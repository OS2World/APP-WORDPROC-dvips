@echo off
REM    This script files has been modified by Guido Sawade basing
REM    upon suggestions of lots of dvips users.
REM    Added comments for DOS users by Wonkoo Kim (wkim+@pitt.edu).
REM
REM    This script file makes a new TeX PK font, because one wasn't
REM    found.  Parameters are:
REM
REM    name dpi bdpi magnification [mode]
REM
REM    `name' is the name of the font, such as `cmr10'.  `dpi' is
REM    the resolution the font is needed at.  `bdpi' is the base
REM    resolution, useful for figuring out the mode to make the font
REM    in.  `magnification' is a string to pass to MF as the
REM    magnification.  `mode', if supplied, is the mode to use.
REM
REM    When you want to get tfm or log files of the fonts generated,
REM    see section 'donemode:'
REM
REM    Notes for DOS Users: (who use emx runtime module)
REM    If you are using EMX runtime module and have a problem with
REM    automatic font generation, set EMXOPT=-p (maybe in autoexec.bat)
REM    to leave some more DOS conventional memory.  Then, dvips will be
REM    able to directly call this batch file and hence mfjob.
REM    RSX runtime modules (under Win3.x/95/NT DOS) don't have this problem.
REM    If you run dvips by using emTeX's dvidrv (by "dvidrv dvips ..."), then
REM    this batch file will not be called, and -p emx option is not necessary.
REM    (If you want to run mfjob later, modify near the bottom of this file.)
REM    -- Wonkoo Kim (wkim+@pitt.edu), October 30, 1997
REM

REM NAME=%1 DPI=%2 BDPI=%3 MAG=%4 MODE=%5

if NOT '%4%' == '' goto nousage
echo USAGE: maketexp NAME DPI BDPI MAG [MODE]
echo !	see comments in /emtex/bin/maketexp.bat/.cmd  !
goto exit

:nousage
if exist dvips.mfj  goto :second
echo %% dvips.mfj - created by dvips > dvips.mfj
echo input [dvidrv]; >> dvips.mfj
echo Created dvips.mfj

:second
echo { >> dvips.mfj
echo base=plain; >> dvips.mfj
echo font=%1; >> dvips.mfj
echo mag=%4;  >> dvips.mfj

if "%5" == ""  goto :nomode
if "%5" == "imagen"  goto :hpmode
if "%5" == "laserjet"  goto :hpmode
if "%5" == "laserjetIV"  goto :hpIVmode
if "%5" == "deskjet"  goto :hpdjmode

:goodmode
echo mode=%5[%3]; >> dvips.mfj
echo output=pk[%DVIDRVFONTS%\%5\@Rrdpi\@f]; >> dvips.mfj
goto :donemode

:hpmode
echo mode=laserjet[%3]; >> dvips.mfj
echo output=pk[%DVIDRVFONTS%\pixel.lj\@Rrdpi\@f]; >> dvips.mfj
goto :donemode

:hpIVmode
echo mode=laserjetIV[%3]; >> dvips.mfj
echo output=pk[%DVIDRVFONTS%\pixel.ljh\@Rrdpi\@f]; >> dvips.mfj
goto :donemode

:hpdjmode
echo mode=deskjet[%3]; >> dvips.mfj
echo output=pk[%DVIDRVFONTS%\pixel.dj\@Rrdpi\@f]; >> dvips.mfj
goto :donemode

:nomode
echo unknownMode; >> dvips.mfj

:donemode
REM Uncomment one or both of the following if you want
REM to get additional files from the METAFONT run.
REM echo output=tfm[%DVIDRVFONTS%\tfm\@f]; >> dvips.mfj
REM echo output=log[%DVIDRVFONTS%\log\@f]; >> dvips.mfj
echo } >> dvips.mfj


REM Yes, this is really the bottom :)	  *************************************
REM
REM Comment out the following lines and uncomment the echo instruction
REM to keep the generated mfjob file and to run mfjob later.
mfjob dvips
del dvips.mfj
rem echo Run "mfjob dvips"

:exit

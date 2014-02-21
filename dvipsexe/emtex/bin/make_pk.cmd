/*    

Translated from Piet Tutelaar's Unix shell script 
into Rexx by Sebastian Rahtz, 15.8.92 (spqr@minster.york.ac.uk)

===================================================================================

A bit modified for matching the file arrangement of current emTeX
and corresponding dvips by Guido Sawade, 28.9.95 (sawade@physik.tu-berlin.de)

Whenever you have Problems, look into these sections, which are marked with
   ****  SENSIBLE SETUP VALUES  ****
where this script could become adopted for your purposes.
Attention must be taken, whenever this script uses environment values, containing
emtex's '!' modifier for pathes, this is NOT supported by this script !!!!!

Please, send any bugs or suggestions to <sawade@physik.tu-berlin.de>

===================================================================================

   This script file makes a new TeX PK font, because one wasn't
   found.  Parameters are:

   name dpi bdpi magnification [[mode] subdir]

   `name' is the name of the font, such as `cmr10'.  `dpi' is
   the resolution the font is needed at.  `bdpi' is the base
   resolution, useful for figuring out the mode to make the font
   in.  `magnification' is a string to pass to MF as the
   magnification.  `mode', if supplied, is the mode to use.

   Note that this file must execute MetaFont (and then gftopk) or
   ps2pk, and place the result in the correct location for the
   PostScript driver to find it subsequently.  If this doesn't work,
   it will be evident because the program will be invoked over and over again.

   If no METAFONT source is available for `name' and the fontname
   starts with a `r' or is available in $TEXCONFIG/adobe then the 
   program tries to find a type1 font. If such a font is located 
   ps2pk will be used to render the font.

   Of course, it needs to be set up for your site with regard to paths etc
*/


call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
os2env='OS2ENVIRONMENT'



/****  SENSIBLE SETUP VALUES  ****/

/* Which metafont you use? */
METAFONT='@mf386 ^&plain'

/* The emtex base directory default when EMTEXDIR is not set */
EMTEXDIR_DEFAULT='c:\emtex'

/* base path for emtex */
EMTEXDIR=value('EMTEXDIR','',os2env)
if EMTEXDIR='' then do
        EMTEXDIR=EMTEXDIR_DEFAULT
end

/* The MFINPUT default directories when MFINPUT is not set */
MI=EMTEXDIR'\mfinput'
MFINPUT_DEFAULT=MI'\cm;'MI'\dc;'MI'\emsy;'MI'\etc;'MI'\extracm;'MI'\latex'

/* The T1INPUTS default directories, when T1INPUTS is not set */
T1INPUTS_DEFAULT=value('DVIPSHEADERS',,os2env)';c:\psfonts'

/* The TEXCONFIG default directory, when TEXCONFIG is not set */
TEXCONFIG_DEFAULT='c:\emtex\data\dvips'

/* The DVIDRVFONTS default directory, when DVIDRVFONTS is not set */
DVIDRVFONTS_DEFAULT='c:\texfonts'


PARSE Arg all_args
argc=words(all_args)
if ( argc < 4  | argc > 5 ) then
do
   say "Usage: make_pk fontname dpi bdpi magnification [mode]"
   exit 1
end

/* Where we look for METAFONT sources */
MFINPUT=value('MFINPUT',,os2env)
if MFINPUT='' then
do
	MFINPUT=MFINPUT_DEFAULT
end
/* say 'MFINPUT='MFINPUT */


/* Where we look for Type1 fonts and AFM files */
T1INPUTS=value('T1INPUTS',,os2env)
if T1INPUTS='' then
do
	T1INPUTS=T1INPUTS_DEFAULT
end


/* Where we look for dvips stuff */
TEXCONFIG=value('TEXCONFIG',,os2env)
if TEXCONFIG='' then do
        TEXCONFIG=TEXCONFIG_DEFAULT
end
listoftype1files=TEXCONFIG'\psfonts.map'


/* What encoding scheme do we use for Type1 text fonts? */

/* DEF_TEXT_ENCODING="-eEC.enc"  (Extended Computer Modern!) */
DEF_TEXT_ENCODING=''


/* 
 TEMPDIR needs to be unique for each process because of the possibility
 of simultaneous processes running this script.
*/
TEMPDIR=SysTempFileName("d:/tmp/mtpk.???")

NAME=word(all_args,1)
DPI=word(all_args,2)
BDPI=word(all_args,3)
MAG=word(all_args,4)
if argc > 4 then 
	MODE=word(all_args,5)
else
   if BDPI = 300   then
      MODE='laserjet'
   else if BDPI = 1270   then
      MODE='linohi'
   else if BDPI = 2540   then
      MODE='linosuper'
   else
    do
      say 'I do not know the mode for ' BDPI
      say 'update this MakeTeXPK script'
      exit 1
    end

/* destination of pk files */
DVIDRVFONTS=value('DVIDRVFONTS',,os2env)
if DVIDRVFONTS = '' then
        DVIDRVFONTS=DVIDRVFONTS_DEFAULT
if  MODE='laserjet' then
        DESTDIR=DVIDRVFONTS'\pixel.lj'
else if MODE='deskjet' then
        DESTDIR=DVIDRVFONTS'\pixel.dj'
else if MODE='laserjetIV' then
        DESTDIR=DVIDRVFONTS'\pixel.ljh'


say 'making for ' MODE ' in ' DESTDIR
call sysfiletree DESTDIR ,'test', 'OD'
if test.0=0 then
      call SysMkDir DESTDIR
SUBDIR=DPI'dpi'
DESTDIR=DESTDIR'\'SUBDIR
call sysfiletree DESTDIR ,'test', 'OD'
if test.0=0 then
      call SysMkDir DESTDIR

PKNAME=NAME'.pk'
TFMNAME=NAME'.tfm'
destpk=DESTDIR'\'PKNAME
desttfm=DVIDRVFONTS'\tfm'

fname = stream(destpk , 'C', 'QUERY EXISTS')
if \ (fname ='') then
  do
     say DESTDIR'\'PKNAME 'already exists!'
    exit 0
  end

/* OK, try to make the font by some means */

/* first try Adobe Type1 fonts */

/* Strip off the possible starting `r' */
if substr(NAME,1,1)='r' then
	VNAME=substr(NAME,2)
else
	VNAME=NAME
file.0=0
call sysfilesearch VNAME' ', listoftype1files, 'FILE.', 'C'
/* if that succeeded, the variable FILE contains the
matching lines in the file describing the fonts */
if rc=3 then
do
   say 'You should install file ' listoftype1files
   exit 0
end
FULLNAME='!'
slant=""
if FILE.0>0 then 
   do i=1 to file.0
	if word(file.i,1)=VNAME then
		do
		FULLNAME=word(file.i,2)
		if words(file.i) > 2 then
			slant="-S "||word(file.i,3)
		leave
		end
/* Here we check also for the raw font ('r'VNAME) */
	if word(file.i,1)='r'VNAME then
		do
		FULLNAME=word(file.i,2)
		if words(file.i) > 2 then
			slant="-S "||word(file.i,3)
		leave
		end
   end
if FULLNAME='!' then  /* failed to locate a name in the list */
do
        say 'No entry for font' VNAME 'or' NAME 'in' listoftype1files

/*  Do we have a METAFONT source for this typeface? */
	if substr(NAME,1,3)='fmv' then 
			mfname=malvern(NAME)  /* Malvern font */ 
	else
	   mfname=syssearchpath('MFINPUT',NAME'.mf')
        say 'Result of MF search: 'mfname
        if mfname='' then
        do
	      say 'Sorry, no PostScript font or Metafont font found' 
	      exit 1
        end
/* 
really no need to use a temporary directory, I think, in this environment

   curdir=directory()
   call SysMkDir TEMPDIR
   newdir= directory(TEMPDIR)
*/

        job=METAFONT' \mode:='MODE'; mag:='MAG'; scrollmode; input 'name
        say job
        job
        if substr(NAME,1,3)='fmv' then  /* Malvern font */
	       x=sysfiledelete(NAME||'.mf')
        GFNAME=NAME'.'DPI
        if  (stream( GFNAME, 'C', 'QUERY EXISTS') = '') then 
        do
                GFNAME=GFNAME'gf'
                if  (stream( GFNAME, 'C', 'QUERY EXISTS') = '') then
                do
                        say 'Metafont failed for some reason on 'GFNAME
                        exit 1
                end
                job = '@gftopk' GFNAME destpk
                say job
                job
                'copy' TFMNAME desttfm
                x=sysfiledelete(GFNAME)
                x=sysfiledelete(PKNAME)
                x=sysfiledelete(NAME'.log')
                x=sysfiledelete(NAME'.tfm')
                exit 0
        end
        else
/*  we have a Type1 font (at any rate, its in the list!) */
        afmname=syssearchpath('T1INPUTS',VNAME'.afm')
        if afmname='' then
        do
                say 'Failed to find afm file for' VNAME ' in 'T1INPUTS
                exit 1
        end
/*  If we don't use default AFM encoding then we have to check
   if we can apply this encoding (text fonts only) 
*/
end

ENCODING=DEF_TEXT_ENCODING

   if \ (DEF_TEXT_ENCODING = '')   then
    do
    /* What is encoding scheme that the AFM file uses? */
    call sysfilesearch 'EncodingScheme',afmname, 'FILE.','C'      
	if file.0=0  then
        do
         say afmname': Invalid AFM file!'
         exit 0
        end
      EXT_ENC=word(file.1,2)
      select
      when substr(ext_end,1,6)='AdobeS' then ENCODING=DEF_TEXT_ENCODING
      when substr(ext_end,1,3)='ISO' then ENCODING=DEF_TEXT_ENCODING
      otherwise
	     ENCODING=''
      end
   end
   if substr(NAME,1,4)='rhlc' then 
	do
	ENCODING="-eEC.enc"
	say 'applying EC encoding'
	end
   pfbname=syssearchpath('T1INPUTS',VNAME'.pfa')
   if pfbname='' then
    do
      pfbname=syssearchpath('T1INPUTS',VNAME'.pfb')
      if pfbname='' then
        do
         say 'Source for font' vname 'not found on path 'T1INPUTS
         exit 1
        end
   end
   job='@ps2pk -X'DPI ENCODING SLANT filespec('name',pfbname) destpk 
   say job
   job
exit 0

malvern: procedure
arg fontname
/* Malvern generation
#
#  The font name is of the form
#
#    	fmvWVV##		Karl Berry's standard font names
#
#  where W   denotes a weight (one of t, i, l, k, r, d, b, x, c)
#        VV  denotes a "variation" (one of <empty>, rn, re, i, in, ie)
#	 ##  is the design size, in points
#
#  or
#	maXXx##			my nonstandard font names
#	
#  where XX is 2 digits giving a style in the tradition of Univers
#        x  is a suffix describing the character set of the font
#	 ## is the design size, in points (with p as decimal point)
#
#  Examples:
#
#    fmvr10	ma55a10		Malvern 55 10-pt
#    fmvd10	ma65a10		Malvern 65 demibold 10-pt
#    fmvbix18	ma74a18		Malvern 74 bold extended italic 18-pt
#    fmvric7	ma58a7		Malvern 58 condensed italic 7-pt
#
#  The fmv- fonts all use the Cork encoding.
#
*/
weights.=''
weights.1= 'weight = 1/4;'	/* ultra-light */
weights.2= 'weight = 1/2;'	/* extra-light */
weights.3= 'weight = 3/4;'	/* light */
weights.4= 'weight = 7/8;'	/* book */
weights.5= 'weight = 1;'	/* medium */
weights.6= 'weight = 1.5;'	/* demi  */
weights.7= 'weight = 2;'	/* bold  */
weights.8= 'weight = 3;'	/* extra */
weights.9= 'weight = 4;'	/* ultra */

weights.t= 'weight = 1/4;'	/* thin [ultra-light] */
weights.i= 'weight = 1/2;'	/* extra-lIght */
weights.l= 'weight = 3/4;'	/* Light */
weights.k= 'weight = 7/8;'	/* booK */
weights.r= 'weight = 1;'	/* Regular */
weights.d= 'weight = 1.5;' 	/* Demi */
weights.b= 'weight = 2;'	/* Bold */
weights.x= 'weight = 3;'	/* eXtra */
weights.u= 'weight = 4;'	/* Ultra */

styles.=''

styles.9='hratio = 0.3;'
styles.0='hratio = 0.3; slant := 1/8; italicness = 1;'
styles.7='hratio = 0.6;'
styles.8='hratio = 0.6; slant := 1/8; italicness = 1;'
styles.5='hratio = 1;'
styles.6='hratio = 1; slant := 1/8; italicness = 1;'
styles.3='hratio = 1.15;'
styles.4='hratio = 1.15; slant := 1/8; italicness = 1;'
styles.1='hratio = 1.30;'
styles.2='hratio = 1.30; slant := 1/8; italicness = 1;'

styles.i='italicness = 1; slant := 1/8;'	/* italic */
styles.u='italicness = 1;'	 	/* vertical italic */
styles.o='slant := 1/8;'			/* oblique */

/* Berry's system has expansion after variant rather than before: */
styles.o='hratio = 0.3;'	/* narrow (extra condensed) */
styles.c='hratio = 0.6;'	/* compressed */
styles.x='hratio = 1.15;'	/* expanded */
styles.w='hratio = 1.30;' 	/* wide (extra expanded) */

/* not used here
-J 's=encoding=0'	# Standard TeX text (like cmr)
-J 'x=encoding=-200'	# Cork (TUGboat 11#4)
-J 'mi=encoding=-1'	# maths (like cmmi)
-J 'sy=encoding=-2'	# symbol (like cmsy)
-J 'ps=encoding=-1000'	# the AdobeStandardEncoding encoding
-J 'so=encoding=-1010'	# the ISOLatin1Encoding encoding

#  Malvern encodings:
-J 'a=encoding=1'	# Malvern A (simple letters)
-J 'b=encoding=2'	# Malvern B (strange symbols)
-J 'c=encoding=3'	# Malvern C (composites)
*/
rf=reverse(fontname)
parse var rf n1 +1 n2 +1 .
if datatype(n2,'N')=1 then
  size=n2||n1
else
  size=n1
parse var fontname basename (size) .
parse var basename base +3 weight +1 style +1 expansion 
if style\=' ' then
  y=value(style)
else
  y=''
if expansion\=' ' then
  z=value(expansion)
else 
  z=''
x=value(weight)
fontfile=value(fontname)||'.mf'
call lineout fontfile,'font_size 'size'pt#; 'weights.x styles.y styles.z 'input maltex;bye.'
call lineout fontfile 
say 'generated Malvern file ' fontfile
return fontfile



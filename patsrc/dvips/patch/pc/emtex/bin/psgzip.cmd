/*----------------------------------------------------------------------*\
    psgzip.cmd  -- gzip (E)PS graphics files for latex

    Wonkoo Kim (wkim+@pitt.edu), May 20, 1997
\*----------------------------------------------------------------------*/

'@echo off'

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

parse arg args

overwrite = 0
cmdargs = ''
do i=1 to words(args)
    opt = word(args, i)

    select
    when left(opt, 2) = '-?' | left(opt, 2) = '-?' then
	leave i
    when left(opt, 2) = '-f' then
	overwrite = 1
    otherwise
	if cmdargs = '' then
	    cmdargs = opt
	else
	    cmdargs = cmdargs||' '||opt
    end
end

if cmdargs = '' | left(opt, 2) = '-?' then do
    say
    say 'psgzip -- Compress (E)PS files (on OS/2 HPFS partition) using gzip and'
    say '          create BoundingBox files (*.bb) for latex2e graphics package'
    say
    say 'Usage: psgzip [-option] [files]'
    say
    say 'Options:'
    say '   -? -h   This help screen'
    say '   -f      Force to overwrite old *.bb and/or *.gz files'
    say
    say 'Example:   psgzip *.eps       -- will create *.eps.bb and *.eps.gz'
    say '           psgzip *.eps.gz    -- will create *.eps.bb'
    say '           psgzip *.eps.Z     -- will create *.eps.bb'
    say
    say 'Wonkoo Kim (wkim+@pitt.edu), May 20, 1997'
    exit 1
end

fspec = SysSearchPath('PATH', 'gzip.exe')
if fspec = '' then do
    say "**ERROR: gzip.exe is not found in PATH. (Get Info-Zip's gzip.)"
    exit 1
end
fspec = SysSearchPath('PATH', 'grep.exe')
if fspec = '' then do
    say '**ERROR: grep is not found in PATH. (Get GNU grep.)'
    exit 1
end

curdir = directory()
lendir = length(curdir)
if lendir > 3 then lendir = lendir+1	/* add one more for non-root dir */

say 'psgzip.cmd  -- gzip (E)PS files for latex, Wonkoo Kim'
filecount = 0
do i=1 to words(cmdargs)
    filemask = word(cmdargs, i)
    call SysFileTree filemask, 'files', 'FO'    /* if file name had wildcard */
    if files.0 = 0 then
	SAY "**ERROR: File not found:" filemask
    else do
	if filesystem(filespec('drive', files.1)) = 'FAT' then do
	    f = word(cmdargs, i)
	    len = length(f)
	    if len < 15 then f = left(f, 15)
	    say '**ERROR:' f 'Files must be on a HPFS partition.'
	    iterate i
	end
	do j=1 to files.0
	    m = pos(curdir, files.j)
	    if (m = 0) then file = files.j
	    else file = substr(files.j, lendir+1)
	    fl = lowercase(file)
	    flen = length(file)
	    select
	    when right(fl,3) = '.gz' then do
		compressed = 1
		gzfile = file
		bbfile = overlay('.bb',file, flen-2)
		end
	    when right(fl,2) = '.z' then do
		compressed = 1
		gzfile = file
		bbfile = overlay('.bb',file, flen-1)
		end
	    otherwise
		compressed = 0
		gzfile = file||'.gz'
		bbfile = file||'.bb'
	    end
	    if (exists(bbfile) | (\compressed & exists(gzfile))) & \overwrite then
		if compressed then
		    say ' **SKIPPED:' file '-' bbfile 'exists!'
		else
		    say ' **SKIPPED:' file '-' bbfile 'and/or' gzfile 'exist!'
	    else do
		filecount = filecount + 1
		'@echo %%! >' bbfile
		if compressed then
		    '@gzip -dc' file '| grep %%%%BoundingBox >>' bbfile
		else do
		    '@grep %%%%BoundingBox' file '>>' bbfile
		    '@gzip -f' file
		end
	    end
	end
    end
end
say
if filecount > 0 then
    say 'Total' filecount '*.gz and *.bb file(s) are created.'
else
    say 'No files were compressed.'

exit 0

/*----------------------------------------------------------------------*/
exists: procedure
/*----------------------------------------------------------------------*/
/* check if a file exists. */
    arg fname
    return stream(fname, 'C', 'QUERY EXISTS') \= ''

/*----------------------------------------------------------------------*/
filesystem: procedure
/*----------------------------------------------------------------------*/
/* return the file system name (i.e. HPFS or FAT) */
    arg drive
    if SysTempFileName(drive||'$.$.???') = '' then
	return 'FAT'
    else
	return 'HPFS'

/*----------------------------------------------------------------------*/
lowercase: procedure
/*----------------------------------------------------------------------*/
/* change to lowercase */
    arg str
    return translate(str,xrange('a','z'),xrange('A','Z'))

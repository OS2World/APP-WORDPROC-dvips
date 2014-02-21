ren dospecial.c     dospecial.c~~
ren dvips.c	    dvips.c~~
ren emspecial.c     emspecial.c~~
ren finclude.c	    finclude.c~~
ren flib.c	    flib.c~~
ren header.c	    header.c~~
ren loadfont.c	    loadfont.c~~
ren makefont.c	    makefont.c~~
ren output.c	    output.c~~
ren resident.c	    resident.c~~
ren search.c	    search.c~~
ren tfmload.c	    tfmload.c~~
ren virtualfont.c   virtualfont.c~~
ren paths.h	    paths.h~~
ren t1part.h	    t1part.h~~
copy patch\*.c
copy patch\*.h
copy patch\emtex\*.c
copy patch\emtex\*.h
copy patch\makefile.emx
gnupatch -cl < patch\diff\dvips.tex.diff

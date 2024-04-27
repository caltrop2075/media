# media
media management

media.sh
--------------------------------------------------------------------------------
automated media copy
copies sorted so only need fatcat -c

NOTICE: file name issues see: videos.awk

videos.sh grew into this...
videos.awk is still used here

2023-02-07 fixed empty directory detect, fully functional now
2023-02-08 added drive stats, tweaked messaging
2023-02-20 tweaked display output
2023-03-02 fixed FAT character replacement
2023-03-14 added drive stat bargraph
2023-11-04 tweaked things, videos.awk: emoji removal & title case
2023-11-16 tweaked videos.awk again... had a trailing space...
2023-11-28 added movie date tagging
2023-12-07 more '$' fixing... plays havoc with things

replaces
    sd-new.sh
    sd-purge.sh
    videos.sh
    videos.awk     <<< used here >>>  video date tagger
scan flash drives: see end here doc
    looks for
       Movies
       Series
       Videos
       mini-Series
copies media from
    $HOME/Videos/Videos
    $MEDIA/BIG1-4           hard coded look back limit
options
    none  default copy
    -p    purge watched video -> text file
    -d    delete watched text file
    -h    help
program outline
    fx_help
    fx_purge          scans for Watched directory then purge/delete
    fx_copy
    fx_media       -> fx_copy
    fx_movies      -> fx_media
    fx_mini        -> fx_media
    fx_series      -> fx_media
    fx_videos      -> fx_copy
    main program   -> fx_help, fx_movies, fx_mini, fx_series, fx_videos, fx_purge
       tags & moves downloads
       scans media drives for select directories
       copies stuff sorted so fat-cat not totally necessary
       here doc drive listing replaced with data file for use with other prgms


videos.awk
--------------------------------------------------------------------------------

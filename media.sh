#!/usr/bin/bash
#------------------------------------------------------------------------------#
#                            Programmed By Liz                                 #
#------------------------------------------------------------------------------#
# automated media copy
# copies sorted so only need fatcat -c
#
# NOTICE: file name issues see: videos.awk
#
# videos.sh grew into this...
# videos.awk is still used here
#
# 2023-02-07 fixed empty directory detect, fully functional now
# 2023-02-08 added drive stats, tweaked messaging
# 2023-02-20 tweaked display output
# 2023-03-02 fixed FAT character replacement
# 2023-03-14 added drive stat bargraph
# 2023-11-04 tweaked things, videos.awk: emoji removal & title case
# 2023-11-16 tweaked videos.awk again... had a trailing space...
# 2023-11-28 added movie date tagging
# 2023-12-07 more '$' fixing... plays havoc with things
#
# replaces
#     sd-new.sh
#     sd-purge.sh
#     videos.sh
#     videos.awk     <<< used here >>>  video date tagger
# scan flash drives: see end here doc
#     looks for
#        Movies
#        Series
#        Videos
#        mini-Series
# copies media from
#     $HOME/Videos/Videos
#     $MEDIA/BIG1-4           hard coded look back limit
# options
#     none  default copy
#     -p    purge watched video -> text file
#     -d    delete watched text file
#     -h    help
# program outline
#     fx_help
#     fx_purge          scans for Watched directory then purge/delete
#     fx_copy
#     fx_media       -> fx_copy
#     fx_movies      -> fx_media
#     fx_mini        -> fx_media
#     fx_series      -> fx_media
#     fx_videos      -> fx_copy
#     main program   -> fx_help, fx_movies, fx_mini, fx_series, fx_videos, fx_purge
#        tags & moves downloads
#        scans media drives for select directories
#        copies stuff sorted so fat-cat not totally necessary
#        here doc drive listing replaced with data file for use with other prgms
#
#===================================================================== variables
source ~/data/global.dat
hr=30                                              # hours to look back
mn=$((hr*60))                                      # minutes to look back
ct=0                                               # drive count
dl=1                                               # sleep delay
txt="*.txt"                                        # media patterns
mkv="*.mkv"
mp4="*.mp4"
web="*.webm"
dwn="$HOME/Downloads/videos"                       # local directories
hom="$HOME/Videos/Videos"
d=$(date +"%Y-%m-%d")
#===================================================================== functions
#-------------------------------------------------------------------------- help
function fx_help
{
   echo "usage:"
   echo "   media.sh -[p d h]"
   echo "   default copy media"
   echo "   -p purge watched media -> text"
   echo "   -d delete watched text"
   echo "   -h help"
}
#------------------------------------------------------------------------- purge
function fx_purge
{
   if [[ $1 == "-d" ]] || [[ $1 == "-p" ]]
   then
      dir="$MEDIA/$lin"
      if [ -d "$dir" ]
      then
         find "$dir" -type d -name "Watched" | sort |
         while read tgt
         do
               echo -e "${Mag}${tgt/$MEDIA\/$lin\//}${nrm}"
            case $1 in
               "-d")                               # delete watched text
                  find "$tgt" -type f -name "$txt" | sort |
                  while read fil
                  do
                     echo -e "${Red}${fil##*/}${nrm}"
                     rm "$fil"
                  done
                  ;;
               "-p")                               # purge watched video -> text
                  find "$tgt" -type f -name "*.mp4" -o -name "*.webm" | sort |
                  while read fil
                  do
                     txt=${fil%.*}.txt
                     echo -e "${wht}${fil##*/}${nrm}"
                     rm "$fil"
                     echo "purged" > "$txt"
                  done
                  ;;
            esac
         done
      fi
   fi
}
#-------------------------------------------------------------------------- copy
function fx_copy
{
   fil=${src##*/}                                  # file name
   fat=${fil//:/_}                                 # remove invalid fat chr
   fat=${fat//\?/_}
   fat=${fat//|/_}
   des="$tgt/$fat"
   txt="$tgt/Watched/${fat%.*}.txt"
   vid="$tgt/Watched/$fat"
   if [ -f "$des" ] || [ -f "$txt" ] || [ -f "$vid" ]
   then                                            # file exists, no copy
      echo -e "   ${grn}${src##*/}${nrm}"          # file name, no dir
   else                                            # copy file
      # echo -e "   ${src##*/}"                      # file name, no dir
      echo -e "   ${des##*/}"                      # file name, no dir
      cp "$src" "$des"
   fi
}
#------------------------------------------------------------------------- media
function fx_media
{
   for drv in BIG1 BIG2 BIG3 BIG4                  # scan drives
   do
      dir="$MEDIA/$drv/$typ"
      if [ -d "$dir" ]
      then
         find $dir \
         \! \( -path "*/Downloads/*" -o -path "*/Music/*" -o -path "*/Shorts/*" -o -path "*/* SF/*" \) \
         -mmin -$mn -type f -name "*.mp4" -printf "%TF|%p\n" | sort |
         {
            num=0
            while IFS="|" read tim src
            do
               fx_copy
               ((num++))
            done
            if (( num > 0 ))
            then
               echo -e "   ${Mag}$drv media: $num${nrm}"
            fi
         }
      fi
   done
}
#------------------------------------------------------------------------ movies
function fx_movies
{
   tgt="$hdr/Movies"
   #title-80.sh -t line "..${tgt/$MEDIA/}"
   echo -e "${Mag}Movies${nrm}"
   sleep $dl
   typ="Movies"
   fx_media
}
#------------------------------------------------------------------------ series
function fx_series
{
   tgt="$hdr/Series"
   #title-80.sh -t line "..${tgt/$MEDIA/}"
   echo -e "${Mag}Series${nrm}"
   sleep $dl
   typ="Series"
   fx_media
}
#------------------------------------------------------------------- mini-series
function fx_mini
{
   tgt="$hdr/mini-Series"
   #title-80.sh -t line "..${tgt/$MEDIA/}"
   echo -e "${Mag}mini-Series${nrm}"
   sleep $dl
   typ="mini-Series"
   fx_media
}
#------------------------------------------------------------------------ videos
function fx_videos
{
   tgt="$hdr/Videos"
   #title-80.sh -t line "..${tgt/$MEDIA/}"
   echo -e "${Mag}Videos${nrm}"
   find $hom -type f | sort |
   {
      num=0
      while read src
      do
         fx_copy
         ((num++))
      done
      echo -e "   ${Mag}videos: $num${nrm}"
   }
}
#================================================================== main program
if [[ $1 == "-h" ]]
then
#-------------------------------------------------------------------------- help
   fx_help
   exit
fi
#------------------------------------------------------------------------- title
clear
title-80.sh -t double "Media - Flash Drive: copy, purge, & delete\neverything except Videos has a look back of $hr hours"
spc="        "
echo -e " ${Mag}message$spc${Grn}copy$spc${grn}no copy$spc${wht}-p media -> txt$spc${Red}-d delete txt${nrm}"
sleep $dl
#------------------------------------------------------------- process downloads
title-80.sh -t line "Processing Downloads"
# until I find a better way to test for empty directory
s="( -name "$mkv" -o -name "$mp4" -o -name "$web" )"
num=$(find "$dwn" -maxdepth 1 -type f $s | wc -l )
if (( $num > 0 ))                               # files ?
then                                            # process downloads
   echo -e "${Mag}moving videos${nrm}"
   find "$dwn" -type f $s | videos.awk -v d="$d"
   mv "$dwn/"* "$hom"
   echo -e "${Mag}downloads: $num${nrm}"
else                                            # nothing to do
   echo -e "${Mag}no download videos found${nrm}"
fi
# exit
mkplaylist.sh ~/Videos                          # always make playlist
#------------------------------------------------------ process drive list below
while read lin
do
   hdr="$MEDIA/$lin"
   if [ -d "$hdr" ]
   then
      ((ct++))

      title-80.sh -t line "$lin"
      fx_purge $1                               # purge/delete watched

      if [ -d "$hdr/Videos" ]                   # test destinations
      then
         fx_videos
      fi

      if [ -d "$hdr/Movies" ]
      then
         fx_movies
         if [[ $lin == SD64G-1 ]]               # movie date tagging
         then
            movie-tag.sh -n
         fi
      fi

      if [ -d "$hdr/Series" ]
      then
         fx_series
      fi

      if [ -d "$hdr/mini-Series" ]
      then
         fx_mini
      fi

      echo -e "$nrm$div_sl"                     # disk usage & bargraph
      df -H "$hdr" |
      {
         z=0                                    # line counter
         while read a b c d e f
         do
            ((z++))
            case $z in
               1)                               # header
                  printf "$Wht" ;;
               2)                               # bargraph data
                  x=${e%\%}
                  printf "$nrm" ;;
            esac
            printf "%-15s %-5s %-5s %-5s %-5s %s\n" "$a" "$b" "$c" "$d" "$e" "$f"
         done
         bargraph.sh $x 100 80
      }
   fi
done < ~/data/flash.dat                         # drive list
#-------------------------------------------------------------- drives processed
echo -e "$div_dl\ndrives: $ct"
#=========================================================================== end

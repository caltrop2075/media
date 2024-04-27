#!/usr/bin/awk -f
#------------------------------------------------------------------------------#
#                            Programmed By Liz                                 #
#------------------------------------------------------------------------------#
#===============================================================================
BEGIN {
   FS="/"
}
#===============================================================================
{
#-------------------------------------------------------------- directory & file
   dir=""                                       # directory
   for(i=1;i<NF;i++)
      dir=dir$i"/"
   n=match($NF,/\..*$/)                         # file & extension
   if(n)
   {
      fil=substr($NF,1,n-1)
      ext=substr($NF,n)
   }
   else
   {
      fil=$NF
      ext=""
   }
#----------------------------------------------------------------- strip garbage
   sub(/\$/,"\\$")                              # $ -> \$
   sub(/\$/,"\\$",fil)                          # $ -> \$
   gsub(/ \[.*\]/," ",fil)                      # [anything]
   # gsub(/ \(.*\)/," ",fil)                    # (anything)
   gsub(/_/," ",fil)                            # _ -> spc
   gsub(/[^!-~]/," ",fil)                       # non standard chr, emoji etc
   do                                           # remove dbl spc
      n=gsub(/  /," ",fil)
   while(n>0)
   sub(/ +$/,"",fil)                            # remove trailing space
#-------------------------------------------------------------------- title case
# preserves special characters removed with split()
# same as caja:case-t.sh
   s=tolower(fil)                               # all lower case
   l=length(fil)                                # string length
   f=1                                          # case flag
   fil=""                                       # reset file name
   for(i=1;i<=l;i++)                            # scan string
   {
      c=substr(s,i,1)
      if(f)
      {
         fil=fil toupper(c)
         f=0
      }
      else
         fil=fil c
      if(match(c,/[^0-9a-zA-Z']/))           #' # white space detect
         f=1
   }
#------------------------------------------------------------------------ rename
   des=dir d" "fil ext                          # destination filename
   if($0!=des)                                  # rename if different
   {
      printf("%s\n%s\n\n",$0,des)
      cmd="mv -n \""$0"\" \""des"\""
      # print cmd
      system(cmd)
   }
}
#===============================================================================
END {
}
#===============================================================================
# functions
#===============================================================================

#!/bin/bash
step=30 #Avoid OOM
SUFFIX="-lres" #suffix after compress
THD=7500 #Skipping while image are small enough
IN_PATH="/volume1/hsujim/Photos/A7R4"
OUT_PATH="/var/services/homes/hsujim/Photos/A7R4_thumbnail/"
EXT=".jpg" #Output extension
Q=60 #Quality
S=80 #resize (%)
cd $IN_PATH
for folder in *; do
        FILE_MISMATCH=$(ls -1 $folder/*.jpg| wc -l) #Default value
        [ ! -d $OUT_PATH$folder ] && echo New Folder: $f!! Converting $FILE_MISMATCH images... && mkdir $OUT_PATH$folder
        if [ -d $OUT_PATH$folder ]; then
                echo $folder exist!! Detecting Images...
                FILE_MISMATCH=0
                for file in $folder/*.jpg; do
                        IFS='.' read -ra NAME <<< "$file" #remove extension
                        NAME=$(echo $OUT_PATH$NAME$SUFFIX*) #find full name
                        [ ! -f "$NAME" ] && FILE_MISMATCH=$((FILE_MISMATCH + 1)) #detect file
                done
        fi
        [ $FILE_MISMATCH == 0 ] && echo ALL Image Name\(s\) Match! Skipping $f ... && continue
        echo Find $FILE_MISMATCH NEW Image\(s\), converting...
        SEL_IMG=""
        count=0
        for file in $folder/*.jpg; do #if images more than one step
                if [ $count == $step ];then
                        magick $SEL_IMG -set filename:fn %[basename]$SUFFIX -quality $Q -resize $S% $OUT_PATH$folder/%[filename:fn]$EXT
                        SEL_IMG=""
                        count=0
                fi
                IFS='.' read -ra NAME <<< "$file"
                NAME2=$(echo $OUT_PATH$NAME$SUFFIX*)
                SIZE=$(du -a $file | awk '{print $1}')
                if [ ! -f "$NAME2" ]; then
                        if [ $SIZE -le $THD ]; then
                                cp $file $OUT_PATH$NAME$SUFFIX$EXT
                        else
                                SEL_IMG=$(echo "$SEL_IMG $file") #add file to list
                                count=$(($count + 1))
                        fi
                fi
        done
        [ ! $count == 0 ] && magick $SEL_IMG -set filename:fn %[basename]$SUFFIX -quality $Q -resize $S% $OUT_PATH$folder/%[filename:fn]$EXT
done

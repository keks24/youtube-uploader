#!/bin/bash
#############################################################################
# Copyright 2011 Ramon Fischer                                              #
#                                                                           #
# Licensed under the Apache License, Version 2.0 (the "License");           #
# you may not use this file except in compliance with the License.          #
# You may obtain a copy of the License at                                   #
#                                                                           #
#     http://www.apache.org/licenses/LICENSE-2.0                            #
#                                                                           #
# Unless required by applicable law or agreed to in writing, software       #
# distributed under the License is distributed on an "AS IS" BASIS,         #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  #
# See the License for the specific language governing permissions and       #
# limitations under the License.                                            #
#############################################################################

clear
date=`date +%F`
time=`date +%R`
log_path="/var/log/custom/protocol.log"

youtube_email=""
youtube_password=""
youtube_title="title.txt"
youtube_description="description.txt"
youtube_folder_path="/media/BANANAPI/youtube"
youtube_tag_path="/media/BANANAPI/youtube/tags"
youtube_video_path="/media/BANANAPI/youtube/videos"
youtube_category="Games"
youtube_location="51.4783,7.5550"

echo "$date - $time: YouTube upload executed." >> $log_path
cd $youtube_folder_path
while(true)
do
	clear
	read -p "Enter the password for $youtube_email: " "password"

	if [ "$password" == "$youtube_password" ]
	then
		break

    else
		clear
		echo -e "\e[01;31mYou entered a wrong password!\e[0m"
		sleep 2
	fi
done
youtube_password="$password"

clear
echo -e "\e[01;33mName\e[0m the \e[01;33mtitle\e[0m of the video/s:"
sleep 2
vi "$youtube_title"
youtube_title="$(< "$youtube_title")"

clear
echo -e "\e[01;33mWrite\e[0m the \e[01;33mdescription:\e[0m"
sleep 2
vi "$youtube_description"
youtube_description="$(< "$youtube_description")"

clear
read -p "Do you want to edit the tag files? (y/n)" continue
if [ $continue == "y" ]
then
	cd $youtube_tag_path
	tag_edit_array=(*)
    while(true)
	do
		clear
		echo -e "\e[01;31mEdit\e[0m one of the following \e[01;31mtag files:\e[0m"
		ls --color=auto $youtube_tag_path
		read "youtube_edit_tags"

		for tag_edit in "${tag_edit_array[@]}"
		do
			if [ "$youtube_edit_tags" == "$tag_edit" ]
			then
				vi "$youtube_edit_tags"
				break
			fi
		done

		if [ "$youtube_edit_tags" == "$tag_edit" ]
		then
			break
		fi
	done
fi

cd $youtube_tag_path
tag_choose_array=(*)
while(true)
do
	clear
	echo -e "\e[01;33mChoose\e[0m one of the follwing \e[01;33mtag files:\e[0m"
	ls --color=auto $youtube_tag_path
	read "youtube_choose_tags"

	for tag_choose in "${tag_choose_array[@]}"
	do
		if [ "$youtube_choose_tags" == "$tag_choose" ]
		then
			youtube_tags="$(< "$youtube_choose_tags")"
			break
		fi
	done

	if [ "$youtube_choose_tags" == "$tag_choose" ]
	then
		break
	fi
done

clear
read -p "Do you want to select the video files manually? (y/n)" continue
if [ $continue = "y" ]
then
	cd $youtube_video_path
	video_list=`ls *.{mkv,mp4,m4p,m4v,avi,webm,flv,vob,ogv,ogg,wmv,mpg,mp2,mpeg,mpe,mpv,m2v,m4v,3gp,3g2}`
	video_choose_array=()
	file_array=(*)
	i=0
	count=1

    while(true)
	do
		clear
		echo -e "\e[01;33mEnter\e[0m the \e[01;33mvideo files\e[0m to be uploaded:"
		ls --color=auto *
		if ! [ "$video_list" ]
		then
			echo -e "\e[01;31mThere are no video files in directory: $youtube_video_path.\e[0m"
			exit 1
		
        else
            while(true)
			do
				read -p "File $count: " "video_choose_array[$i]"

				for video_files in "${file_array[@]}"
				do
					if [ "${video_choose_array[$i]}" == "$video_files" ]
					then
						read -p "Add another file? (y/n)" continue

						if [ $continue == "y" ]
						then
							(( i++ ))
							(( count++ ))
						
                        else
							(( i++ ))
							break
						fi
					fi
				done
				break
			done
		fi
		break
	done

else
	cd $youtube_video_path
	video_list=`ls *.{mkv,mp4,m4p,m4v,avi,webm,flv,vob,ogv,ogg,wmv,mpg,mp2,mpeg,mpe,mpv,m2v,m4v,3gp,3g2}`

    if ! [ "$video_list" ]
	then
		echo -e "\e[01;31mThere are no video files in directory: $youtube_video_path.\e[0m"
		exit 1

	else
		i=0
		video_array=(*)
		for video_files in "${video_array[@]}"
		do
			(( i++ ))
		done
	fi
fi

clear
echo -e "\e[01;33mWhen\e[0m do you want \e[01;33mto upload\e[0m the files? (hhmm)"
echo -e "\e[01;37mCurrent Time: `date +%R` \e[0m"
read set_time
while [ `date +%H%M` != $set_time ]
do
	sleep 55
done

j=1
clear
for video_files in "${video_array[@]}"
do
	youtube-upload --email="$youtube_email" --password="$youtube_password" --title="$youtube_title[$j/$i]" --description="$youtube_description" --category="$youtube_category" --keywords="$youtube_tags" --location="$youtube_location" "$video_files"
	(( j++ ))
done

date=`date +%F`
time=`date +%R`
echo "$date - $time: YouTube upload finished: $youtube_title" >> $log_path

shutdown -r now

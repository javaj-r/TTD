#! /bin/bash

declare -r IN_PROGRESS='In Progress'
declare -r REFUSED=Refused
declare -r DONE=Done

declare -r IN_PROGRESS_ICON=in-progress.png
declare -r REFUSED_ICON=refused.png
declare -r DONE_ICON=done.png

declare -r IN_PROGRESS_ALT='In Progress'
declare -r REFUSED_ALT=Refused
declare -r DONE_ALT=Done

declare -r DATA_FILE='data.sh'

declare -r BG_SKY_BLUE='\e[48;2;0;191;255m'
declare -r BG_CORAL='\e[48;2;255;127;80m'

declare -r FG_SKY_BLUE='\e[38;2;0;191;255m'
declare -r FG_CORAL='\e[38;2;255;127;80m'
declare -r FG_WHITE_BOLD='\e[38;2;250;250;250m\e[1m'
declare -r DEFAULT_COLOR='\e[0m'

declare -a id;
declare -i lastIndex=0;

declare -a titleList;
declare -a descriptionList;
declare -a dateList;
declare -a timeList;
declare -a statusList;


#!/bin/bash
#
# Script version 0.0.1
#
# This script receives 2 arguments: [branch name] , [number of days]
# The script will disply 3 outputs in the selected branch: [list of commits from last tag (optional:limited by days)] , [Auther of last commit] , [Amount of commits in the last 30 days]
#
#
# Made by Anna Mikhlin

underline='\e[4m'
red='\e[31m'
normal='\e[0m'

#function shows the the Author of the last commnit in the selected branch
function commit_author (){

author=$(git log -1 --pretty=format:'%an' origin/$branch_name)
}

#function checks amount of commits in selected branch since 30days
function commits_num (){

commits_num=$(git log --since=30.days --pretty=oneline origin/$branch_name | wc -l)

}

#function checks last tag name and numbers of commits from last tag in selected branch
function last_tag_commits (){

last_tag=$(git describe --abbrev=0 --tags origin/$branch_name)
#get number of commits from last tag in selected branch
last_commits_num=$(git describe --tags origin/$branch_name | awk -F $last_tag '{print $2}' | awk -F '-' '{print $2}')
if [ "$last_commits_num" == "" ]; then
	last_commits_num=0 #no commits
fi
echo "Last tag in this branch: $last_tag , number of commits from last tag: $last_commits_num"
	
}

#function prints list of commits from last tag in selected branch limited by selected days
function commits_list (){
last_tag_commits; #gets last commit in the selected branch and amount of commits from last branch
if [ "$last_commits_num" == 0 ]; then
	echo "No commits were added from last tag";
else
	if [ "$days_num" == "" ]; then 
		echo "***List of all commits from last tag:"

			git log -${last_commits_num} origin/$branch_name --pretty=format:'%C(yellow)%h %Cblue[%an]%Creset %ar | %Cgreen%s'
	else
		echo "***List of commits from last ${days_num} days:"
		command_list=$(git log -${last_commits_num} origin/$branch_name --pretty=format:'%C(yellow)%h %Cblue[%an]%Creset %ar | %Cgreen%s' --since=${days_num}.days)
		if [ "$command_list" == "" ]; then
			echo "No commits were added during selected period (${days_num} days)"
		else
			git log -${last_commits_num} origin/$branch_name --pretty=format:'%C(yellow)%h %Cblue[%an]%Creset %ar | %Cgreen%s' --since=${days_num}.days
		fi
	fi
fi
}

#Main

#Checks arguments provided to the script
if [ ! -z "$1" ] || [ ! -z "$2" ]; then
	if [ -n "$(git branch --list -a origin/$1)" ]; then
		branch_name=$1
	else
		echo -e "Selected branch: ${underline}${1}${normal} - ${red}not exist in GIT${normal} - please check your input and run again"
		exit 2
	fi

	if [[ $2 =~ ^[0-9]+$ ]] || [ "$2" == "" ]; then
		days_num=$2
	else
		echo -e "${underline}${2}${normal} - ${red}not valid input for days${normal} - please check your input and run again"
		exit 2
	fi
elif [ "$1" == "" ]; then
	branch_name="branch-4.5"
	echo -e "No argument has been provided for branch name - the default branch set to: ${underline}branch-4.5${normal}"
fi		

echo "========================================================="
echo "Selected branch is: $branch_name"
commits_list; #get commint from last tag
commit_author; echo "***Author of last commit in this branch: [$author]"
commits_num; echo "***Amount of commits in last 30 days in this branch: $commits_num"
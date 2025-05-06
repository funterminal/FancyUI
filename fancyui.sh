#!/bin/bash

reset="\033[0m"
bold="\033[1m"
underline="\033[4m"
italic="\033[3m"
strikethrough="\033[9m"

declare -A fg=(
  [black]="\033[30m" [red]="\033[31m" [green]="\033[32m"
  [yellow]="\033[33m" [blue]="\033[34m" [magenta]="\033[35m"
  [cyan]="\033[36m" [white]="\033[37m"
)

declare -A bg=(
  [black]="\033[40m" [red]="\033[41m" [green]="\033[42m"
  [yellow]="\033[43m" [blue]="\033[44m" [magenta]="\033[45m"
  [cyan]="\033[46m" [white]="\033[47m"
)

colorful_text() {
  echo -e "${bold}${bg[$4]}${fg[$3]}${2}${reset}"
}

format_markdown() {
  echo "$1" | perl -pe '
    s/\*\*(.*?)\*\*/\e[1m\e[36m$1\e[0m/g;
    s/\*(.*?)\*/\e[3m\e[32m$1\e[0m/g;
    s/~~(.*?)~~/\e[9m\e[33m$1\e[0m/g;
    s/^## (.*)/\e[1;37m\e[44m $1 \e[0m/g;
    s/^# (.*)/\e[1;44m\e[32m $1 \e[0m/g;
    s/(.*?)(.*?)/\e[4m\e[35m$1\e[0m (\e[36m$2\e[0m)/g;
    s/`([^`]*)`/\e[1m\e[33m$1\e[0m/g;
    s/```(.*?)```/\e[1m\e[34m$1\e[0m/g;
  '
}

create_fancy_header() {
  text="$1"
  border=$(printf '═%.0s' $(seq 1 ${#text}))
  echo -e "${bold}${fg[white]}╔$border╗${reset}"
  echo -e "${bold}${fg[cyan]}║$text║${reset}"
  echo -e "${bold}${fg[white]}╚$border╝${reset}"
}

create_gradient() {
  local text="$1"
  local colors=(${fg[red]} ${fg[yellow]} ${fg[green]} ${fg[blue]} ${fg[magenta]} ${fg[cyan]})
  local result=""
  for ((i=0; i<${#text}; i++)); do
    color=${colors[$((i % ${#colors[@]}))]}
    result+="${color}${bold}${text:$i:1}"
  done
  echo -e "$result$reset"
}

create_box() {
  local width=$1 height=$2 text="$3"
  local pad_text=$(printf "%-${width}s" " $text ")
  local top="┏$(printf '━%.0s' $(seq 1 $width))┓"
  local bot="┗$(printf '━%.0s' $(seq 1 $width))┛"
  local mid="┃$pad_text┃"

  echo -e "${fg[white]}$top${reset}"
  for _ in $(seq 1 $(( (height - 1) / 2 ))); do echo -e "${fg[cyan]}┃$(printf '%*s' $width)┃${reset}"; done
  echo -e "${fg[green]}$mid${reset}"
  for _ in $(seq 1 $(( height / 2 ))); do echo -e "${fg[cyan]}┃$(printf '%*s' $width)┃${reset}"; done
  echo -e "${fg[white]}$bot${reset}"
}

create_list() {
  echo -e "$(echo -e "\e[1;33m•\e[0m") $1"
  shift
  for item in "$@"; do
    echo -e "  \e[1;31m- $item${reset}"
  done
}

create_progress_bar() {
  total=$1 current=$2
  percent=$((current * 100 / total))
  filled=$((percent / 2))
  empty=$((50 - filled))
  printf "["
  printf "${fg[green]}%0.s█" $(seq 1 $filled)
  printf "${fg[black]}%0.s░" $(seq 1 $empty)
  printf "${reset}] ${percent}%%${reset}\n"
}

create_table() {
  local cols=$1
  shift
  local -a cells=("$@")
  local width=30
  local total_cells=${#cells[@]}
  local rows=$(( (total_cells + cols - 1) / cols ))
  local table=()
  for ((i=0; i<total_cells; i++)); do
    IFS=$'\n' read -rd '' -a lines <<< "$(echo -e "${cells[$i]}")"
    table[i,0]=${#lines[@]}
    for ((j=0; j<${#lines[@]}; j++)); do
      table[i,$((j+1))]="${lines[$j]}"
    done
  done

  echo -n "┏"
  for ((i=0; i<cols; i++)); do
    printf "%0.s━" $(seq 1 $width)
    echo -n $([[ $i -lt $((cols - 1)) ]] && echo "┳" || echo "┓")
  done
  echo

  for ((r=0; r<rows; r++)); do
    max_lines=1
    for ((c=0; c<cols; c++)); do
      idx=$((r * cols + c))
      (( idx < total_cells )) && (( ${table[$idx,0]} > max_lines )) && max_lines=${table[$idx,0]}
    done

    for ((l=1; l<=max_lines; l++)); do
      echo -n "┃"
      for ((c=0; c<cols; c++)); do
        idx=$((r * cols + c))
        if (( idx < total_cells )); then
          cell_line="${table[$idx,$l]}"
          printf " %-*s" $((width - 1)) "$cell_line"
        else
          printf " %-*s" $((width - 1)) ""
        fi
        echo -n "┃"
      done
      echo
    done

    if ((r < rows - 1)); then
      echo -n "┣"
      for ((i=0; i<cols; i++)); do
        printf "%0.s━" $(seq 1 $width)
        echo -n $([[ $i -lt $((cols - 1)) ]] && echo "╋" || echo "┫")
      done
      echo
    fi
  done

  echo -n "┗"
  for ((i=0; i<cols; i++)); do
    printf "%0.s━" $(seq 1 $width)
    echo -n $([[ $i -lt $((cols - 1)) ]] && echo "┻" || echo "┛")
  done
  echo
}

animated_spinner() {
  local msg="$1"
  local i=0
  local chars=('◐' '◓' '◑' '◒')
  while true; do
    printf "\r${fg[magenta]}${chars[i]} ${msg}${reset}"
    i=$(( (i + 1) % 4 ))
    sleep 0.2
  done
}

case "$1" in
  echo)
    colorful_text "$2" "$2" "$3" "$4"
    ;;
  format)
    format_markdown "$2"
    ;;
  table)
    shift
    create_table "$@"
    ;;
  box)
    create_box "$2" "$3" "$4"
    ;;
  list)
    shift
    create_list "$@"
    ;;
  progress)
    create_progress_bar "$2" "$3"
    ;;
  gradient)
    create_gradient "$2"
    ;;
  header)
    create_fancy_header "$2"
    ;;
  spinner)
    animated_spinner "$2"
    ;;
  *)
    echo -e "Usage: ./fancyui.sh [echo|format|table|box|list|progress|gradient|header|spinner] [args...]"
    ;;
esac

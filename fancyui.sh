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
  total=$1
  current=0
  percent=0
  elapsed_time=0
  remaining_time=$total
  progress_bar=""
  task="$2"

  while [ $current -le $total ]; do
    percent=$((current * 100 / total))
    filled=$((percent / 2))
    empty=$((50 - filled))

    elapsed_time=$((elapsed_time + 1))
    remaining_time=$((total - current))

    formatted_elapsed=$(printf "%02d:%02d:%02d" $((elapsed_time / 3600)) $(((elapsed_time % 3600) / 60)) $((elapsed_time % 60)))
    formatted_remaining=$(printf "%02d:%02d:%02d" $((remaining_time / 3600)) $(((remaining_time % 3600) / 60)) $((remaining_time % 60)))

    progress_bar=""
    for ((i=0; i<filled; i++)); do
      progress_bar+="${fg[red]}━"
    done
    for ((i=0; i<empty; i++)); do
      progress_bar+="${fg[blue]}━"
    done

    printf "\r${fg[yellow]}${bold}%s${reset} ${progress_bar} ${percent}%% ${formatted_elapsed} ${reset}" "$task"
    sleep 0.1
    current=$((current + 1))
  done

  echo -e "\n${fg[blue]}Task Completed!${reset}"
}

create_table() {
  BOLD_WHITE='\033[1;97m'
  RESET='\033[0m'

  structured=false
  rows=()

  while [[ "$1" =~ ^- ]]; do
      case "$1" in
          -s|--structured)
              structured=true
              ;;
          *) exit 1
              ;;
      esac
      shift
  done

  while [[ $# -gt 0 ]]; do
      rows+=("$1")
      shift
  done

  declare -a col_widths
  for row in "${rows[@]}"; do
      IFS=';' read -ra cols <<< "$row"
      for ((i = 0; i < ${#cols[@]}; i++)); do
          [[ -z "${col_widths[$i]}" ]] && col_widths[$i]=0
          (( ${#cols[$i]} > col_widths[$i] )) && col_widths[$i]=${#cols[$i]}
      done
  done

  draw_border() {
      printf "${BOLD_WHITE}|${RESET}"
      for w in "${col_widths[@]}"; do
          printf "${BOLD_WHITE}%s|${RESET}" "$(printf '%*s' "$((w + 2))" | tr ' ' '_')"
      done
      printf "\n"
  }

  print_row() {
      local IFS=';'
      read -ra cols <<< "$1"
      printf "${BOLD_WHITE}|${RESET}"
      for ((i = 0; i < ${#col_widths[@]}; i++)); do
          content="${cols[$i]}"
          printf " %-*s ${BOLD_WHITE}|${RESET}" "${col_widths[$i]}" "$content"
      done
      printf "\n"
  }

  draw_border
  print_row "${rows[0]}"
  draw_border

  for ((i = 1; i < ${#rows[@]}; i++)); do
      print_row "${rows[$i]}"
      $structured && draw_border
  done

  ! $structured && draw_border
}

animated_spinner() {
  local msg="$1"
  local duration="$2"
  local i=0
  local chars=('◐' '◓' '◑' '◒')
  local start_time=$(date +%s)

  while true; do
    printf "\r${fg[magenta]}${chars[i]} ${msg}${reset}"
    i=$(( (i + 1) % 4 ))
    sleep 0.2

    if [[ -n "$duration" ]]; then
      local now=$(date +%s)
      local elapsed=$((now - start_time))
      if (( elapsed >= duration )); then
        break
      fi
    fi
  done
  echo -e "\r${fg[green]}${msg} complete.${reset}"
}

forms() {
  IFS=',' read -ra raw_questions <<< "$1"

  for q in "${raw_questions[@]}"; do
    question=$(echo "$q" | sed 's/^ *"//; s/" *$//') 
    border=$(printf '─%.0s' $(seq 1 ${#question}))

    echo -e "${fg[white]}┌$border┐${reset}"
    echo -e "${fg[cyan]}│${bold}$question${reset}${fg[cyan]}│${reset}"
    echo -e "${fg[white]}└$border┘${reset}"

    read -p "$(echo -e "${fg[green]}> ${reset}")" input
    echo -e "${fg[yellow]}You entered:${reset} ${bold}${input}${reset}\n"
  done
}

pretty_json() {
  local json_input="$1"

  echo "$json_input" | jq -C '.' | perl -pe '
    s/"(.*?)":/${\e("[1;36m\"$1\"[0m"])}:/g;
    s/: "(.*?)"/: ${\e("[32m\"$1\"[0m"])}/g;
    s/: ([0-9\.\-eE]+)/: ${\e("[35m$1[0m"])}/g;
    s/: (true|false)/: ${\e("[33m$1[0m"])}/g;
    s/: null/: ${\e("[31mnull[0m"])}/g;
    sub e { "\033[" . shift() }
  '
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
    animated_spinner "$2" "$3"
    ;;
  forms)
    forms "$2"
    ;;
  json)
    pretty_json "$2"
    ;;
  *)
    echo -e "Usage: ./fancyui.sh [echo|format|table|box|list|progress|gradient|header|spinner|forms|json] [args...]"
    ;;
esac

#! /bin/bash

source "$(find ./ -name print.sh)"

getDate() {
  local reg='^[0-9]{4}-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])$'
  local resultDate inputDate

  while :; do
    read -rp '[yyyy-m-d or yyyy-mm-dd] Date : ' inputDate
    if ! [[ $inputDate =~ $reg ]]; then
      echo "error: Not a date" >&2
    else
      resultDate=$inputDate
      break
    fi
  done

  echo "$resultDate"
}

start() {
  declare -i i=0
  clear
  while :; do
    echo "
    0) Exit
    1) Create new todo
    2) Show todo list
    3) Generate html table
    4) Rearrange data in file and exit
    " >&2

    local msg='Please select from list: '
    local answer
    answer="$(getNumber "$msg")"

    case $answer in
    0)
      break
      ;;
    1)
      createTodo
      ;;
    2)
      showTodo
      ;;
    3)
      generateHtml
      ;;
    4)
      rearrangeData
      break
      ;;
    *)
      echo Invalid selection.
      ;;

    esac

  done

}

showTodo() {
  while :; do
    clear
    echo
    echo
    printTodoList

    local msg='Select -1 to return or id to delete todo: '
    local -i answer
    answer="$(getNumber "$msg")"

    if (("answer == -1")); then
      clear
      break
    elif (("answer >= 0")); then

      if [[ ${titleList[$answer]} ]]; then
        deleteRow answer
      else
        echo "$answer id not exists"
      fi

    else
      echo "Invalid choice!" >&2
    fi

  done

}

createTodo() {

  local newTitle newDescription
  read -rp "Title: " newTitle
  read -rp "Description: " newDescription
  local newDate="$(getDate)"
  local newTime="$(getTime)"
  local newStatus="$(getStatus)"

  titleList[$lastIndex]=$newTitle
  descriptionList[$lastIndex]=$newDescription
  dateList[$lastIndex]=$newDate
  timeList[$lastIndex]=$newTime
  statusList[$lastIndex]=$newStatus

  while :; do
    echo "Confirm:
      1) Save todo
      0) Cancel
    " >&2

    local msg='Select a status: '
    local -i answer
    answer="$(getNumber "$msg")"

    case $answer in
    0)
      deleteRow "$lastIndex"
      clear
      echo 'Creating todo canceled'
      break
      ;;
    1)
      writeData "$lastIndex" "$DATA_FILE"
      clear
      echo 'Todo saved successfully'
      break
      ;;
    *)
      echo Invalid selection.
      echo
      ;;
    esac

  done

}

deleteRow() {
  local -i index="$1"

  unset "titleList[$index]"
  unset "descriptionList[$index]"
  unset "dateList[$index]"
  unset "timeList[$index]"
  unset "statusList[$index]"

  if (("index < lastIndex")); then
    {
      echo
      echo "unset \"titleList[$index]\""
      echo "unset \"descriptionList[$index]\""
      echo "unset \"dateList[$index]\""
      echo "unset \"timeList[$index]\""
      echo "unset \"statusList[$index]\""
    } >>"$(find ./ -name "$DATA_FILE")"
  fi
}

writeData() {
  local -i index="$1"
  local fil="$2"
  {
    echo
    echo "titleList[$index]='${titleList[$index]}'"
    echo "descriptionList[$index]='${descriptionList[$index]}'"
    echo "dateList[$index]='${dateList[$index]}'"
    echo "timeList[$index]='${timeList[$index]}'"
    echo "statusList[$index]='${statusList[$index]}'"
  } >>"$(find ./ -name "$fil")"

  (("lastIndex++"))

  echo "lastIndex=$lastIndex" >>"$(find ./ -name "$fil")"
}

rearrangeData() {

  local -i newIndex=0
  local shebang='#!/bin/bash'
  local src='source $(find ./ -name static.sh)'

  local todoInitializations=$(
    for i in "${!titleList[@]}"; do

      printf '\n%s\n%s\n%s\n%s\n%s\n' \
        "titleList[$newIndex]='${titleList[$i]}'" \
        "descriptionList[$newIndex]='${descriptionList[$i]}'" \
        "dateList[$newIndex]='${dateList[$i]}'" \
        "timeList[$newIndex]='${timeList[$i]}'" \
        "statusList[$newIndex]='${statusList[$i]}'"

      (("newIndex++"))
    done
  )
  (("newIndex++"))
  clear
  echo Please wait
  echo "$shebang" >"$(find ./ -name data.sh)"
  {
    echo
    echo "$src"
    echo "$todoInitializations"
    echo
    echo "lastIndex=$newIndex"
  } >>"$(find ./ -name data.sh)"
}

getStatus() {
  local resultStatus

  while :; do
    echo "Status:
      1) In Progress
      2) Refused
      3) Done" >&2

    #     "Please select from list: "
    local msg='Select a status: '
    local -i answer
    answer="$(getNumber "$msg")"

    case $answer in
    1)
      resultStatus="$IN_PROGRESS"
      break
      ;;
    2)
      resultStatus="$REFUSED"
      break
      ;;
    3)
      resultStatus="$DONE"
      break
      ;;
    *)
      echo Invalid selection.
      ;;
    esac

  done

  echo "$resultStatus"
}

getTime() {
  local reg='^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$'
  local resultTime inputTime

  while :; do
    read -rp '[H:MM or HH:MM] Time: ' inputTime
    if ! [[ $inputTime =~ $reg ]]; then
      echo "error: Not a time" >&2
    else
      resultTime=$inputTime
      break
    fi
  done

  echo "$resultTime"
}

getNumber() {
  local message="$*${NC}"
  local -i resultNumber=0
  local reg='^-?[0-9]+$'
  local inputNumber

  while :; do
    read -rp "$message" inputNumber
    if ! [[ $inputNumber =~ $reg ]]; then
      echo "error: Not a number" >&2
    else
      resultNumber=$inputNumber
      break
    fi
  done

  echo "$resultNumber"
}

generateHtml() {
  local htmlHeader
  local htmlTableBody
  local htmlTableRow
  local htmlFooter
  local statusIcon
  local statusAlter

  htmlHeader=$(<"$(find ./ -name header)")
  htmlFooter=$(<"$(find ./ -name footer)")
  htmlTableRow=$(<"$(find ./ -name row)")

  htmlTableBody=$(for i in "${!titleList[@]}"; do

    case "${statusList[$i]}" in

    $IN_PROGRESS)
      statusIcon="$IN_PROGRESS_ICON"
      statusAlter="$IN_PROGRESS_ALT"
      ;;
    $REFUSED)
      statusIcon="$REFUSED_ICON"
      statusAlter="$REFUSED_ALT"
      ;;
    $DONE)
      statusIcon="$DONE_ICON"
      statusAlter="$DONE_ALT"
      ;;
    esac

    printf "\n$htmlTableRow\n" \
      "$i" "${titleList[$i]}" \
      "${descriptionList[$i]}" \
      "${dateList[$i]}" "${timeList[$i]}" \
      "$statusIcon" "$statusAlter" "$statusAlter"
  done)

  echo "$htmlHeader" >"$(find ./ -name todo.html)"
  {
    echo "$htmlTableBody"
    echo "$htmlFooter"
  } >>"$(find ./ -name todo.html)"

  if which xdg-open >/dev/null; then
    nohup xdg-open "$(find ./ -name todo.html)"
  elif which gnome-open >/dev/null; then
    nohup gnome-open "$(find ./ -name todo.html)"
  fi

  clear
}

start

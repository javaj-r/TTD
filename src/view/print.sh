#! /bin/bash

source $(find ./ -name data.sh)

printTodoList() {
  local rowColor
  local -i colorFlag=0
  local rowContent
  local emptyLineColor

  for i in "${!titleList[@]}"; do

    if (("colorFlag == 0")); then
      rowColor="$BG_SKY_BLUE$FG_WHITE_BOLD"
      emptyLineColor="$BG_SKY_BLUE$FG_SKY_BLUE"
      colorFlag=1
    else
      rowColor="$BG_CORAL$FG_WHITE_BOLD"
      emptyLineColor="$BG_CORAL$FG_CORAL"
      colorFlag=0
    fi

    rowContent=$(printf \
      '.\n\n\t[ %s ]    %s\n\n%s\n\n\t%s\t%s\t[%s]\n\n.' \
      "$i" "${titleList[$i]}" \
      "${descriptionList[$i]}" \
      "${dateList[$i]}" "${timeList[$i]}" \
      "${statusList[$i]}" |
      fmt -w 45 -u)

    while read -r line; do
      printf "$rowColor\t    %-50s $DEFAULT_COLOR\n" "$line"
    done < <(echo "$rowContent")
    echo

  done
}

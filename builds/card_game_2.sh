#!/bin/sh
echo -ne '\033c\033]0;card_game\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/card_game_2.x86_64" "$@"

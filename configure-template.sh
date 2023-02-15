#!/bin/bash
# 'return' when run as "source <script>" or ". <script>", 'exit' otherwise
[[ "$0" != "${BASH_SOURCE[0]}" ]] && safe_exit="return" || safe_exit="exit"

script_name=$(basename "$0")

ask_question() {
    # ask_question <question> <default>
    local ANSWER
    read -r -p "$1 ($2): " ANSWER
    echo "${ANSWER:-$2}"
}

confirm() {
    # confirm <question> (default = N)
    local ANSWER
    read -r -p "$1 (y/N): " -n 1 ANSWER
    echo " "
    [[ "$ANSWER" =~ ^[Yy]$ ]]
}

slugify() {
    # slugify <input> <separator>
    # Jack, Jill & Clémence LTD => jack-jill-clemence-ltd
    # inspiration: https://github.com/pforret/bashew/blob/master/template/normal.sh
    separator="$2"
    [[ -z "$separator" ]] && separator="-"
    # shellcheck disable=SC2020
    echo "$1" |
        tr '[:upper:]' '[:lower:]' |
        tr 'àáâäæãåāçćčèéêëēėęîïííīįìłñńôöòóœøōõßśšûüùúūÿžźż' 'aaaaaaaaccceeeeeeeiiiiiiilnnoooooooosssuuuuuyzzz' |
        awk '{
        gsub(/[\[\]@#$%^&*;,.:()<>!?\/+=_]/," ",$0);
        gsub(/^  */,"",$0);
        gsub(/  *$/,"",$0);
        gsub(/  */,"-",$0);
        gsub(/[^a-z0-9\-]/,"");
        print;
        }' |
        sed "s/-/$separator/g"
}

titlecase() {
    # titlecase <input> <separator>
    # Jack, Jill & Clémence LTD => JackJillClemenceLtd
    separator="${2:-}"
    echo "$1" |
        tr '[:upper:]' '[:lower:]' |
        tr 'àáâäæãåāçćčèéêëēėęîïííīįìłñńôöòóœøōõßśšûüùúūÿžźż' 'aaaaaaaaccceeeeeeeiiiiiiilnnoooooooosssuuuuuyzzz' |
        awk '{ gsub(/[\[\]@#$%^&*;,.:()<>!?\/+=_-]/," ",$0); print $0; }' |
        awk '{
        for (i=1; i<=NF; ++i) {
            $i = toupper(substr($i,1,1)) tolower(substr($i,2))
        };
        print $0;
        }' |
        sed "s/ /$separator/g"
}

package_name=$(ask_question "Package name" "Laravel Foo Bar Package")
package_slug=$(slugify "$package_name" "-")

package_key=$(ask_question "Config file name" "$package_slug")
package_key=$(slugify "$package_key" "-")

ClassName=$(titlecase "$package_name")
ClassName=$(ask_question "Class name" "$ClassName")

package_description=$(ask_question "Package description" "This is my package $ClassName")

echo -e "------"
echo -e "Author      : Pod Point Software Team <software@pod-point.com>"
echo -e "Vendor      : Pod Point (pod-point)"
echo -e "Package     : pod-point/$package_slug"
echo -e "Description : $package_description"
echo -e "Namespace   : PodPoint\\$ClassName"
echo -e "ClassName   : $ClassName"
echo -e "Config      : $package_key"
echo -e "------"

files=$(grep -E -r -l -i ":package|skeleton" --exclude-dir=vendor ./* ./.github/* | grep -v "$script_name")

echo "This script will replace the above values in all relevant files in the project directory."

if ! confirm "Modify files?"; then
    $safe_exit 1
fi

grep -E -r -l -i ":package|skeleton" --exclude-dir=vendor ./* ./.github/* \
| grep -v "$script_name" \
| while read -r file ; do
    new_file="$file"
    new_file="${new_file//Skeleton/$ClassName}"
    new_file="${new_file//skeleton/$package_key}"
    new_file="${new_file//laravel_/}"
    new_file="${new_file//laravel-/}"

    echo "adapting file $file -> $new_file"
        temp_file="$file.temp"
        < "$file" \
          sed "s#:package_name#$package_name#g" \
        | sed "s#:package_slug#$package_slug#g" \
        | sed "s#package_slug#$package_slug#g" \
        | sed "s#:package_key#$package_key#g" \
        | sed "s#skeleton#$package_slug#g" \
        | sed "s#Skeleton#$ClassName#g" \
        | sed "s#:package_description#$package_description#g" \
        | sed "#^\[\]\(delete\) #d" \
        > "$temp_file"
        rm -f "$file"
        mv "$temp_file" "$new_file"
done

if confirm "Execute composer install and phpunit test"; then
    composer install && ./vendor/bin/phpunit
fi

if confirm 'Let this script delete itself (since you only need it once)?'; then
    echo "Delete $0 !"
    sleep 1 && rm -- "$0"
fi

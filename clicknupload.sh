#!/bin/bash
# @Description: clicknupload.org file download script
# @Author: Juni Yadi
# @URL: https://github.com/JuniYadi/clicknupload
# @Version: 201811262126
# @Date: 2018-11-26
# @Usage: ./clicknupload.sh url

if [ -z "${1}" ]
then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one clicknupload.org url per line"
    exit
fi

function clicknuploaddownload()
{
    prefix="$( echo -n "${url}" | cut -d'/' -f4 )"
    cookiefile="/tmp/${prefix}-cookie.tmp"
    infofile="/tmp/${prefix}-info.tmp"
    infoverifyfile="/tmp/${prefix}-infoverify.tmp"
    infodlfile="/tmp/${prefix}-infodl.tmp"

    # loop that makes sure the script actually finds a filename
    filename=""
    retry=0
    while [ -z "${filename}" -a ${retry} -lt 10 ]
    do
        let retry+=1
        rm -f "${cookiefile}" 2> /dev/null
        rm -f "${infofile}" 2> /dev/null
        curl -s -c "${cookiefile}" -o "${infofile}" -L "${url}"

        filename=$( cat "${infofile}" | grep 'name="fname"' | cut -d'"' -f6)
    done

    if [ "${retry}" -ge 10 ]; then
        echo "could not download file"
        exit 1
    fi

    if [ -f "${infofile}" ]; then
        curl -s -b "${cookiefile}" -d "op=download1&usr_login=&id=${prefix}&fname=${filename}&referer=&method_free=Free+Download+%3E%3E" "${url}" -o "${infoverifyfile}"
        curl -s -X POST -b "cookie.txt" -d "op=download2&id=${prefix}&rand=&referer=${url}&method_free=Free+Download+%3E%3E&method_premium=&adblock_detected=1" "${url}" -o "${infodlfile}"

        getdl=$( cat "${infodlfile}" | grep 'downloadbtn' | cut -d'(' -f3 | cut -d')' -f1 | cut -d"'" -f2)

        if [ "$getdl" ]; then
            dl="${getdl}"
        else
            echo "url file not found"
            exit 1
        fi

    else
        echo "can't find info file for ${prefix}"
        exit 1
    fi

    # Set browser agent
    agent="Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"

    if [ -f "$filename" ]; then
        echo "[ERROR] File  Exist : $filename"
    else
        echo "[INFO] Download File : $filename"

        # Start download file
        wget -c -O "${filename}" "${dl}" \
        -q --show-progress \
        --user-agent="${agent}"
    fi

    rm -f "${cookiefile}" 2> /dev/null
    rm -f "${infofile}" 2> /dev/null 
    rm -f "${infoverifyfile}" 2> /dev/null
    rm -f "${infodlfile}" 2> /dev/null
}

if [ -f "${1}" ]
then
    for url in $( cat "${1}" | grep -i 'clicknupload.org' )
    do
        clicknuploaddownload "${url}"
    done
else
    url="${1}"
    clicknuploaddownload "${url}"
fi

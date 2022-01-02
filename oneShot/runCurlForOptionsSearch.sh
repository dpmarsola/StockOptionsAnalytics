#!/usr/bin/bash

getUpdatedSessionData(){

    FILE_ORIG_SESSION_DATA=$BASE_ARCH_DIR/files/inputs/oneShot.session.data

    if [ -f "$FILE_ORIG_SESSION_DATA" ]; then
        sed 's/\:/\n/g' $FILE_ORIG_SESSION_DATA | sed 's/\\//g' | grep -v "\-H " | sed 's/\n//g' > tmp && mv tmp $FILE_ORIG_SESSION_DATA
    else   
        echo "Please open Interactive Brokers and get NEW session data to store inside $FILE_ORIG_SESSION_DATA"
        return 1
    fi

}

setSessionDataForCurl(){

    FILE_CURL_TMP=$BASE_ARCH_DIR/temp/oneShot.curlForOptionsSearch.tmp.file
    FILE_CURL=$BASE_ARCH_DIR/files/outputs/oneShot.curlForOptionsSearch.final
    FILE_TEMPLATE=$BASE_ARCH_DIR/files/aux/oneShot.curlForOptionsSearch.template

    COOKIE_INFO=$(cat $FILE_ORIG_SESSION_DATA)
    
    if [ -f "$FILE_CURL" ]; then
        rm $FILE_CURL
    fi
    
    if [ -f "$FILE_TEMPLATE" ]; then
        strPart1=$(echo $(sed 's/VAR1/\n/g' $FILE_TEMPLATE | grep curl)$CONID"' \\")
        strPart2=$(echo $(grep -v curl $FILE_TEMPLATE | grep -v cookie | grep -v compressed))
        strPart3=$(echo $(sed 's/VAR2/\n/g' $FILE_TEMPLATE | grep cookie)$COOKIE_INFO"' \\" "--compressed")
        echo $strPart1 $strPart2 $strPart3 > $FILE_CURL_TMP
        sed 's/\\/\\\n/g' $FILE_CURL_TMP > $FILE_CURL
        rm $FILE_CURL_TMP
    else   
        echo "File $FILE_TEMPLATE missing. Cannot continue."
        return 1
    fi

}

runSearch(){

    jsonResponse=$(source $FILE_CURL 2> /dev/null) 
    echo $jsonResponse | python3 -c "import sys, json; print(json.load(sys.stdin)['secdef'][0]['hasOptions'])"
    rm $FILE_CURL
    
}

main(){

    source ../globalVariables.conf

    CONID=$1

    getUpdatedSessionData
    setSessionDataForCurl
    runSearch

}


main $1
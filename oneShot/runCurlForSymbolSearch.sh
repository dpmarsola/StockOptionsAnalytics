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

    FILE_CURL_TMP=$BASE_ARCH_DIR/temp/oneShot.curlForSymbolSearch.tmp.file
    FILE_CURL=$BASE_ARCH_DIR/files/outputs/oneShot.curlForSymbolSearch.final
    FILE_TEMPLATE=$BASE_ARCH_DIR/files/aux/oneShot.curlForSymbolSearch.template

    COOKIE_INFO=$(cat $FILE_ORIG_SESSION_DATA)
    
    if [ -f "$FILE_CURL" ]; then
        rm $FILE_CURL
    fi
    
    if [ -f "$FILE_TEMPLATE" ]; then
        strPart1=$(echo $(grep -v cookie $FILE_TEMPLATE | grep -v data-raw | grep -v compressed))
        strPart2=$(echo $(sed 's/VAR1/\n/g' $FILE_TEMPLATE | grep cookie)$COOKIE_INFO"' \\")
        strPart3=$(echo $(sed 's/VAR2/\n/g' $FILE_TEMPLATE | grep data-raw)$SYMBOL"\" ,\"pattern\":true,\"referrer\":\"symbol-lookup\"}'" \\ "--compressed")
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
    echo $jsonResponse | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['conid'])"
    rm $FILE_CURL

}

main(){

    source ../globalVariables.conf

    SYMBOL=$1

    getUpdatedSessionData
    setSessionDataForCurl
    runSearch

}


main $1
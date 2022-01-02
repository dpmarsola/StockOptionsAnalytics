#!/usr/bin/bash

separateSymbol(){

    symbol=$(echo $1 | cut -d',' -f1)

}

main(){

    source ../globalVariables.conf

    if [ -z "$1" ]
    then
        echo "Input file missing. Cannot continue."
        return 1
    fi

    ./cleanStocksSpecialChars.sh $1

    while read line
    do
        separateSymbol $line
        CONID=$(./runCurlForSymbolSearch.sh $symbol)
        HAS_OPTIONS=$(./runCurlForOptionsSearch.sh $CONID)
        echo $symbol,$CONID,$HAS_OPTIONS
        sleep 3
    done < $BASE_ARCH_DIR/files/inputs/stock.list.all
    

}

main $1
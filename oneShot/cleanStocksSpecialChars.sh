#!/usr/bin/bash

cleanStocksSpecialChars(){

    grep -v "[\^\\\/]" $1 > cleanStocksSpecialChars.tmp.file
    mv cleanStocksSpecialChars.tmp.file $BASE_ARCH_DIR/files/inputs/stock.list.all

}

main(){

    source ../globalVariables.conf

    if ! [ -s $BASE_ARCH_DIR/files/inputs/stock.list.all.bkp ]
    then
        cp $BASE_ARCH_DIR/files/inputs/stock.list.all $BASE_ARCH_DIR/files/inputs/stock.list.all.bkp
        chmod a+r $BASE_ARCH_DIR/files/inputs/stock.list.all.bkp
    fi

    cleanStocksSpecialChars $1

}

main $1

#!/bin/bash

[ ! -d "$1" ] && echo 'Usage: control-art.sh artifactoryDir' && exit 1

artHome=`ls -1 "$1" | grep -e "artifactory-pro" -e "artifactory-powerpack"`
[ -z "$artHome" ] && echo "Usage: No powerpack unzipped at $1" && exit 1

artHome=$1/${artHome:-1}
echo "Artifactory Home $artHome"

if [ ! -x $artHome/bin/artifactory.sh ]; then
    echo $artHome/bin/artifactory.sh must be executable
    exit 2
fi

logsDir="$artHome/logs"
artLog="$logsDir/artifactory.log"

exitError() {
    echo "$1"
    exit 1
}

waitServerStarts() {
    [ -z "$1" ] && exitError "Wait for server starts needs number of seconds to wait"
    local secsToWait=$1
    echo "INFO: Waiting for $artHome to initialize in less than $secsToWait seconds"
    local nbSeconds=0
    local printLog=true
    local doTouchLogback=true
    while [ $nbSeconds -lt $secsToWait ]; do
        sleep 2
        let "nbSeconds = $nbSeconds + 2"
        if [ ! -f "$artLog" ]; then
            echo "INFO: File $artLog still not created after $nbSeconds!"
            if [ $nbSeconds -gt 28 ] && $doTouchLogback; then
                local logbackFile="$artHome/etc/logback.xml"
                echo "INFO: Touching $logbackFile to refresh log"
                [ ! -f "$logbackFile" ] && exitError "File $artLog not created after $nbSeconds and $logbackFile doe not exists"
                touch $logbackFile
                doTouchLogback=false
            fi
            [ $nbSeconds -gt $secsToWait ] && exitError "File $artLog was not created after $nbSeconds!"
            continue;
        else
            $printLog && echo "INFO: Found $artLog file after $nbSeconds"
            printLog=false
        fi
        if [ "$doTouchLogback" == "false" ]; then
          local logbackMessage="`grep "Reloaded logback config from" $artLog`"
          if [ -n "$logbackMessage" ]; then
            echo "INFO: Found re log message in $artLog after $nbSeconds!"
            echo "INFO: $logbackMessage"
            echo "INFO: Waiting 2 seconds for jersey to finish"
            sleep 2
            return 0
          fi
        else
          local startMessage="`grep "Artifactory successfully started" $artLog`"
          if [ -n "$startMessage" ]; then
            echo "INFO: Found start message in $artLog after $nbSeconds!"
            echo "INFO: $startMessage"
            echo "INFO: Waiting 7 seconds for jersey to finish"
            sleep 7
            return 0
          fi
        fi
        echo -n "."
    done
    exitError "$artHome did not initialize after $nbSeconds!"
}

start() {
    [ -e $artLog ] && mv $artLog $artLog.$RANDOM
    uname|grep -q MING && rm -rf $artHome/tomcat/logs
    $artHome/bin/artifactory.sh start
    waitServerStarts 60
}

stop() {
    [ ! -e $artLog ] && echo "Not running" && return 0
    uname|grep -q MING && kill $(cat $artHome/run/*.pid) && rm $artHome/run/*.pid && exit 0
    $artHome/bin/artifactory.sh stop
}

if [ "x$2" == "xstop" ]; then
    stop
    exit $?
else
    start
    exit $?
fi

#!/bin/bash
#set -x
etcDir="$1"
localDir="$2"
artDir="$3"

if [ ! -d "$artDir" ]; then
    echo "Warn: Artifactory '$artDir' is not a directory, creating"
    mkdir "$artDir"
fi

if [ ! -d "$etcDir" ] || [ ! -d "$localDir" ] || [ ! -d "$artDir" ]; then
    echo "ERROR: The 3 needed folders ectDir=$etcDir and localDir=$localDir and artDir=$artDir do not exist!"
    exit 1
fi

proZip="$localDir/artifactory-pro.zip"
if [ ! -f "$proZip" ]; then
    echo "ERROR: The pro zip file $proZip do not exists!"
    exit 2
fi

cd "$artDir" || exit 4

ls -1 "$artDir" | grep -e "artifactory-pro" -e "artifactory-powerpack" > /tmp/allPowerPackDirs.txt
if [ `wc -l </tmp/allPowerPackDirs.txt` -gt 0 ]; then
    for artHome in `cat /tmp/allPowerPackDirs.txt`; do
        echo "WARN: Moving current Artifactory homes $artHome"
        mv $artHome "$artDir/art-old-$RANDOM" || exit 5
    done
fi

unzip -d "$artDir" "$proZip" || exit 6
artHome=`ls -1 "$artDir" | grep -e "artifactory-pro" -e "artifactory-powerpack"`

if [ ! -d "$artHome" ]; then
    echo "ERROR Artifactory home '$artHome' is not a directory"
    exit 7
fi

ln -fs "$artHome" "$artDir/artifactory"
mkdir -p "$artHome"/etc || ( echo "can't create etc dir $?" && exit 8)

# Now we have a Artifactory home dir and the default etc folder
# The following is configuring artifactory home correctly before its first execution.
# The following should be executed about the same way in the RPM install without the symlink.
# you need to provide your own license file!
cp -a $localDir/artifactory.lic "$artHome/etc" || ( echo "can't copy $etcDir/artifactory.lic to $artHome/etc" && exit 9)
cp -a $etcDir/artifactory.system.properties "$artHome/etc" || ( echo "can't copy $etcDir/artifactory.system.porperties to $artHome/etc" && exit 10)
echo 'export JAVA_OPTIONS="$JAVA_OPTIONS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5008"' >> "$artHome/bin/artifactory.default" || ( echo "can't add java options to artifactory.default" && exit 10)
# uncomment next line if you wish to copy an artifactory config or security descriptor mu
# cp -a $etcDir/{artifactory.config.import.xml,security.import.xml} "$artHome/etc" || ( echo "can't copy $etcDir to $artHome/etc" && exit 13)
# below server.xml resets the port to 8088 so it doesn't conflict with a 'standard' localhost install
cp -af $etcDir/server.xml "$artHome/tomcat/conf" || ( echo "can't copy $etcDir to $artHome/tomcat/conf" && exit 11)
# changes the control port for the tomcat server so it doesn't conflict if you have a 'standard' localhost install
sed -i -e "s/8015/8018/g;" "$artHome/bin/artifactory.sh"
[ -e $artHome/etc/plugins ] && (\rm -r $artHome/etc/plugins || ( echo "can't remove old plugins from $artHome/etc/plugins" && exit 12))
ln -s $etcDir/plugins $artHome/etc/plugins || ( echo "can't link $etcDir/plugins to $artHome/etc" && exit 14)

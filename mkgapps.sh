#!/usr/bin/env bash

# Copyright (C) 2017 BeansTown106
# Portions Copyright (C) 2016 MrBaNkS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo ".______...__...__..__...._.._______..__...__..___..._______."
echo "|......\.|..|.|..||..\..|.||..._...||..\_/..||...|.|...____|"
echo "|..__...||..|_|..||...\_|.||..| |..||.......||...|.|..|....."
echo "|.|. \..||.......||.......||..|_|..||.......||...|.|..|....."
echo "|.|__/..||_....._||.._....||.......||.......||...|.|..|....."
echo "|.......|..|...|..|.|.\...||..._...||.||_||.||...|.|..|____."
echo "|______/...|___|..|_|..\__||__|.|__||_|...|_||___|.|_______|"
echo "._______.._______.._______.._______.._______................"
echo "|.......||..._...||...._..||...._..||.......|..............."
echo "|....___||..| |..||...| |.||...| |.||.._____|..............."
echo "|...|.__.|..|_|..||...|_|.||...|_|.||.|_____................"
echo "|...||..||.......||....___||....___||_____..|..............."
echo "|...|_|.||..._...||...|....|...|....._____|.|..............."
echo "|_______||__|.|__||___|....|___|....|_______|..............."

# Define paths & variables
TARGETDIR=$(pwd)
GAPPSDIR="$TARGETDIR"/files
TOOLSDIR="$TARGETDIR"/tools
STAGINGDIR="$TARGETDIR"/staging
FINALDIR="$TARGETDIR"/out
ZIPNAME=Dynamic_Gapps-7.1.x-$(date +"%Y%m%d").zip
JAVAHEAP=3072m
SIGNAPK="$TOOLSDIR"/signapk.jar
MINSIGNAPK="$TOOLSDIR"/minsignapk.jar
TESTKEYPEM="$TOOLSDIR"/testkey.x509.pem
TESTKEYPK8="$TOOLSDIR"/testkey.pk8
APPDIRS="facelock/arm/app/FaceLock
         hangouts/arm/app/Hangouts
         hangouts/arm64/app/Hangouts
         prebuiltgmscore/arm/priv-app/PrebuiltGmsCore
         prebuiltgmscore/arm64/priv-app/PrebuiltGmsCore
         system/app/GoogleCalendarSyncAdapter
         system/app/GoogleContactsSyncAdapter
         system/app/GoogleTTS
         system/priv-app/ConfigUpdater
         system/priv-app/ConnMetrics
         system/priv-app/GmsCoreSetupPrebuilt
         system/priv-app/GoogleBackupTransport
         system/priv-app/GoogleFeedback
         system/priv-app/GoogleLoginService
         system/priv-app/GoogleOneTimeInitializer
         system/priv-app/GooglePartnerSetup
         system/priv-app/GoogleServicesFramework
         system/priv-app/Phonesky
         system/priv-app/SetupWizard
         velvet/arm/priv-app/Velvet
         velvet/arm64/priv-app/Velvet"

# Decompression function for apks
dcapk() {
  TARGETDIR=$(pwd)
  TARGETAPK="$TARGETDIR"/$(basename "$TARGETDIR").apk
  unzip -qo "$TARGETAPK" -d "$TARGETDIR" "lib/*"
  zip -qd "$TARGETAPK" "lib/*"
  cd "$TARGETDIR"
  zip -qrDZ store -b "$TARGETDIR" "$TARGETAPK" "lib/"
  rm -rf "${TARGETDIR:?}"/lib/
  mv -f "$TARGETAPK" "$TARGETAPK".orig
  zipalign -fp 4 "$TARGETAPK".orig "$TARGETAPK"
  rm -f "$TARGETAPK".orig
}

# Define beginning time
BEGIN=$(date +%s)

# Start making Gapps zip
export PATH="$TOOLSDIR":$PATH
cp -rf "$GAPPSDIR"/* "$STAGINGDIR"

for dirs in $APPDIRS; do
  cd "$STAGINGDIR/${dirs}";
  dcapk 1> /dev/null 2>&1;
done

cd "$STAGINGDIR"
zip -qr9 "$ZIPNAME" ./* -x "placeholder"
java -Xmx"$JAVAHEAP" -jar "$SIGNAPK" -w "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAME" "$ZIPNAME".signed
rm -f "$ZIPNAME"
zipadjust "$ZIPNAME".signed "$ZIPNAME".fixed 1> /dev/null 2>&1
rm -f "$ZIPNAME".signed
java -Xmx"$JAVAHEAP" -jar "$MINSIGNAPK" "$TESTKEYPEM" "$TESTKEYPK8" "$ZIPNAME".fixed "$ZIPNAME"
rm -f "$ZIPNAME".fixed
mv -f "$ZIPNAME" "$FINALDIR"
ls | grep -iv "placeholder" | xargs rm -rf

# Define ending time
END=$(date +"%s")

# Done
echo ""
echo "Gapps Zip Complete!!$"
echo "Total time elapsed: $( echo $(( ${END}-${BEGIN} )) | awk '{print int($1/60)"mins "int($1%60)"secs "}' )"
echo "Zip location: ${FINALDIR}"
echo "Zip size: $( du -h ${FINALDIR}/${ZIPNAME} | awk '{print $1}' )"

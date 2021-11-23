# iOS jenkins 环境搭建



1. 安装 jenkins. 

   ```
   brew install jenkins
   ```

2. 修改端口

   ```
   vi /usr/local/Cellar/jenkins-lts/2.289.1/
   
   cat homebrew.mxcl.jenkins-lts.plist
   
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
     <dict>
       <key>Label</key>
       <string>homebrew.mxcl.jenkins-lts</string>
       <key>ProgramArguments</key>
       <array>
         <string>/usr/local/opt/openjdk@11/bin/java</string>
         <string>-Dmail.smtp.starttls.enable=true</string>
         <string>-jar</string>
         <string>/usr/local/opt/jenkins-lts/libexec/jenkins.war</string>
         <string>--httpListenAddress=127.0.0.1</string>
         <string>--httpPort=8877</string>
       </array>
       <key>RunAtLoad</key>
       <true/>
     </dict>
   </plist>
   ```

   

3. 启动 jenkins

   ```
   brew services start jenkins-lts
   brew services restart jenkins-lts
   ```

   



## iOS 命令编译



通过 Xcode 编译打包项目会有记录，直接去记录里面找对应的命令就可以。

![截屏2021-10-30 11.02.57](/Users/wxf/WorkSpace/book/static/截屏2021-10-30 11.02.57.png)



因为已经创建了 Aggregate, 写好了脚本，所以直接运行 EaSeeSDK

```
xcodebuild build -scheme EaSeeSDK 
```



```
REVEAL_XCFRAMEWORK_IN_FINDER=true

FREAMEWORK_NAME="${PROJECT_NAME}"
FREAMEWORK_OUTPUT_DIR="${PROJECT_DIR}/Output"
ARCHIVE_PATH_IOS_DEVICE="./Build/ios_device.xcarchive"
ARCHIVE_PATH_IOS_SIMULATOR="./Build/ios_simulator.xcarchive"
DSYM_PATH="dSYMs"
# ARCHIVE_PATH_MACOS="./build/macos.xcarchive"

function archiveOnePlatform {
    echo "▸ Starts archiving the scheme: ${1} for destination: ${2};\n▸ Archive path: ${3}"

    xcodebuild archive \
        -scheme "${1}" \
        -destination "${2}" \
        -archivePath "${3}" \
        VALID_ARCHS="${4}" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    # sudo gem install -n /usr/local/bin xcpretty
    # xcpretty makes xcode compile information much more readable.
}

function archiveAllPlatforms {

    # https://www.mokacoding.com/blog/xcodebuild-destination-options/

    # Platform                 Destination
    # iOS                      generic/platform=iOS
    # iOS Simulator            generic/platform=iOS Simulator
    # iPadOS                   generic/platform=iPadOS
    # iPadOS Simulator         generic/platform=iPadOS Simulator
    # macOS                    generic/platform=macOS
    # tvOS                     generic/platform=tvOS
    # watchOS                  generic/platform=watchOS
    # watchOS Simulator        generic/platform=watchOS Simulator
    # carPlayOS                generic/platform=carPlayOS
    # carPlayOS Simulator      generic/platform=carPlayOS Simulator

    SCHEME=${1}

    archiveOnePlatform $SCHEME "generic/platform=iOS Simulator" ${ARCHIVE_PATH_IOS_SIMULATOR} "arm64 i386 x86_64"
    archiveOnePlatform $SCHEME "generic/platform=iOS" ${ARCHIVE_PATH_IOS_DEVICE} "armv7 arm64"
    # archiveOnePlatform $SCHEME "generic/platform=macOS" ${ARCHIVE_PATH_MACOS}
}

function makeXCFramework {
    
    # 暂时不清楚为什么有时候是 Products/@rpath ，有时候是 Products/Library/Frameworks
    FRAMEWORK_RELATIVE_PATH="Products/@rpath"
    if [[ ! -d "${ARCHIVE_PATH_IOS_DEVICE}/${FRAMEWORK_RELATIVE_PATH}" ]]; then
        FRAMEWORK_RELATIVE_PATH="Products/Library/Frameworks"
    fi
    
    OUTPUT_DIR="${FREAMEWORK_OUTPUT_DIR}"

    mkdir -p "${OUTPUT_DIR}"

    xcodebuild -create-xcframework \
        -framework "${ARCHIVE_PATH_IOS_DEVICE}/${FRAMEWORK_RELATIVE_PATH}/${FREAMEWORK_NAME}.framework" \
        -framework "${ARCHIVE_PATH_IOS_SIMULATOR}/${FRAMEWORK_RELATIVE_PATH}/${FREAMEWORK_NAME}.framework" \
        -output "${OUTPUT_DIR}/${FREAMEWORK_NAME}.xcframework"

    # save dSYM
    cp -r "${ARCHIVE_PATH_IOS_DEVICE}/${DSYM_PATH}/${FREAMEWORK_NAME}.framework.dSYM" "${OUTPUT_DIR}/${FREAMEWORK_NAME}_DEVICE.dSYM"
    cp -r "${ARCHIVE_PATH_IOS_SIMULATOR}/${DSYM_PATH}/${FREAMEWORK_NAME}.framework.dSYM" "${OUTPUT_DIR}/${FREAMEWORK_NAME}_SIMULATOR.dSYM"
}

echo "#####################"
echo "▸ Cleaning XCFramework output dir: ${FREAMEWORK_OUTPUT_DIR}"
rm -rf $FREAMEWORK_OUTPUT_DIR

#### Make XCFramework

echo "▸ Archive framework: ${FREAMEWORK_NAME}"
archiveAllPlatforms $FREAMEWORK_NAME

echo "▸ Make framework: ${FREAMEWORK_NAME}.xcframework"
makeXCFramework

# Clean Build
rm -rf "./Build"

if [ ${REVEAL_XCFRAMEWORK_IN_FINDER} = true ]; then
    open "${FREAMEWORK_OUTPUT_DIR}/"
fi
```


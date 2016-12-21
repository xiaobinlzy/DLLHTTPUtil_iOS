LOCAL_DIR=`pwd`

#POD名称
POD_NAME="DLLHTTPRequest"
#库文件名称
LIBRARY_NAME="lib${POD_NAME}.a"
#工程名称
PROJECT_FILE="${LOCAL_DIR}/Example/Pods/Pods.xcodeproj"

#构建目录
BUILD_DIR="${LOCAL_DIR}/build"
#配置
CONFIGURATION="Release"
#模拟器库文件目录
SIMULATOR_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${POD_NAME}"
#设备库文件目录
DEVICE_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-iphoneos/${POD_NAME}"
#最终生成的库文件目录
TARGET_BUILD_FILE="${LOCAL_DIR}/${LIBRARY_NAME}"

#删除旧目录和文件
rm -rf ${BUILD_DIR}
rm -rf ${TARGET_BUILD_FILE}

#创建构建目录
mkdir ${BUILD_DIR}

pushd Example
pod install
popd

#构建模拟器和设备的库
echo "正在构建模拟器库..."
xcodebuild -project ${PROJECT_FILE} -sdk iphonesimulator -target ${POD_NAME} -configuration ${CONFIGURATION} clean build BUILD_DIR="${BUILD_DIR}" | echo
echo "正在构建设备库..."
xcodebuild -project ${PROJECT_FILE} -sdk iphoneos -target ${POD_NAME} -configuration ${CONFIGURATION} clean build BUILD_DIR="${BUILD_DIR}" | echo


#合成一个库文件
lipo "${SIMULATOR_LIBRARY_DIR}/${LIBRARY_NAME}" "${DEVICE_LIBRARY_DIR}/${LIBRARY_NAME}" -create -output "${TARGET_BUILD_FILE}"

rm -rf ${BUILD_DIR}
rm -rf ${LOCAL_DIR}/Example/build

echo "构建完成"

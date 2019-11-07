# Delete the old stuff
rm -Rf Frameworks
# Make the target directories
mkdir -p Frameworks/iOS/fat
mkdir -p Frameworks/iOS/release
mkdir -p Frameworks/iOS/simulator

cd MUXSDKStatsJWPlayer

# Build iOS release SDK
xcodebuild -workspace 'MUXSDKStatsJWPlayer.xcworkspace' -configuration Release archive -scheme 'MUXSDKStatsJWPlayer' -sdk iphoneos SYMROOT=$PWD/ios
# Build iOS simulator SDK
xcodebuild -workspace 'MUXSDKStatsJWPlayer.xcworkspace' -configuration Release -scheme 'MUXSDKStatsJWPlayer' -destination 'platform=iOS Simulator,name=iPhone 8' SYMROOT=$PWD/ios

# Prepare the release .framework
cp -R -L ios/Release-iphoneos/MUXSDKStatsJWPlayer.framework ios/MUXSDKStatsJWPlayer.framework
cp -R ios/Release-iphoneos/MUXSDKStatsJWPlayer.framework.dSYM ios/MUXSDKStatsJWPlayer.framework.dSYM
TARGET_IOS_BINARY=$PWD/ios/MUXSDKStatsJWPlayer.framework/MUXSDKStatsJWPlayer
rm $TARGET_IOS_BINARY

# Make the iOS fat binary
lipo -create ios/Release-iphoneos/MUXSDKStatsJWPlayer.framework/MUXSDKStatsJWPlayer ios/Release-iphonesimulator/MUXSDKStatsJWPlayer.framework/MUXSDKStatsJWPlayer -output $TARGET_IOS_BINARY

cd ..

# Copy over iOS frameworks
cp -R MUXSDKStatsJWPlayer/ios/Release-iphonesimulator/MUXSDKStatsJWPlayer.framework Frameworks/iOS/simulator/MUXSDKStatsJWPlayer.framework
cp -R MUXSDKStatsJWPlayer/ios/Release-iphonesimulator/MUXSDKStatsJWPlayer.framework.dSYM Frameworks/iOS/simulator/MUXSDKStatsJWPlayer.framework.dSYM
cp -R -L MUXSDKStatsJWPlayer/ios/Release-iphoneos/MUXSDKStatsJWPlayer.framework Frameworks/iOS/release/MUXSDKStatsJWPlayer.framework
cp -R MUXSDKStatsJWPlayer/ios/Release-iphoneos/MUXSDKStatsJWPlayer.framework.dSYM Frameworks/iOS/release/MUXSDKStatsJWPlayer.framework.dSYM
cp -R MUXSDKStatsJWPlayer/ios/MUXSDKStatsJWPlayer.framework Frameworks/iOS/fat/MUXSDKStatsJWPlayer.framework
cp -R MUXSDKStatsJWPlayer/ios/MUXSDKStatsJWPlayer.framework.dSYM Frameworks/iOS/fat/MUXSDKStatsJWPlayer.framework.dSYM


# Clean up
rm -Rf MUXSDKStatsJWPlayer/tv
rm -Rf MUXSDKStatsJWPlayer/ios

echo Enter version number
read version

echo '(1/6) Updating repositories...'

cd D:/Repos/modmonster/
git pull

cd D:/HTML/modmonstergithub/ModMonster.github.io/
git pull

cd D:/Programming/Flutter/Projects/chicken_thoughts_notifications/

echo '(2/6) Building for Android...'
flutter build apk --split-per-abi


echo '(3/6) Building for the Web...'
flutter build web

cd build

echo '(4/6) Cleaning up...'

# WEB
rm -r D:/HTML/modmonstergithub/ModMonster.github.io/chicken_thoughts/* # clear out web build on repository
cp -r web/* D:/HTML/modmonstergithub/ModMonster.github.io/chicken_thoughts # copy new web build to repository

# ANDROID
rm D:/Repos/modmonster/android-apps/chicken-thoughts/apks/* # clear out android build on repository

mkdir D:/Programming/Flutter/Builds/chicken_thoughts/$version/ # make new folder in local build archive directory

# copy apks to archive folder
cp app/outputs/flutter-apk/app-x86_64-release.apk D:/Programming/Flutter/Builds/chicken_thoughts/$version/app-x86_64-release.apk
cp app/outputs/flutter-apk/app-arm64-v8a-release.apk D:/Programming/Flutter/Builds/chicken_thoughts/$version/app-arm64-v8a-release.apk
cp app/outputs/flutter-apk/app-armeabi-v7a-release.apk D:/Programming/Flutter/Builds/chicken_thoughts/$version/app-armeabi-v7a-release.apk

# copy apks to repository
cp app/outputs/flutter-apk/app-x86_64-release.apk D:/Repos/modmonster/android-apps/chicken-thoughts/apks/x86_64.apk
cp app/outputs/flutter-apk/app-arm64-v8a-release.apk D:/Repos/modmonster/android-apps/chicken-thoughts/apks/arm64.apk
cp app/outputs/flutter-apk/app-armeabi-v7a-release.apk D:/Repos/modmonster/android-apps/chicken-thoughts/apks/arm.apk

# change app version in 'info.txt'
sed -i "3s/.*/$version/" D:/Repos/modmonster/android-apps/chicken-thoughts/info.txt


echo '(5/6) Pushing Android version to GitHub...'

cd D:/Repos/modmonster/
git add .
git commit -m "Update Chicken Thoughts apk to $version"
git push


echo '(6/6) Pushing Web version to GitHub...'

cd D:/HTML/modmonstergithub/ModMonster.github.io/
git add .
git commit -m "Update Chicken Thoughts web to $version"
git push

echo 'Done!'
echo '(Press enter to exit)'
read
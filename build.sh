# first, build the code
swift build --swift-sdk arm64-apple-ios -c release

mkdir -p .build/Payload/Sample.app

# then, convert xml to bplist and copy to the package directory
plistutil -i assets/Info.plist -o .build/Payload/Sample.app/Info.plist
cp assets/*.png .build/Payload/Sample.app
cp .build/release/sample .build/Payload/Sample.app

# finally, create the .ipa file
cd .build
zip -r sample.ipa Payload
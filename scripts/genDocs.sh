
# generates the documentation that can be viewed at github.com
# https://avnerbarr.github.io/FlockKit/documentation/flockkit/
# documentation here https://swiftlang.github.io/swift-docc-plugin/documentation/swiftdoccplugin/publishing-to-github-pages
swift package --allow-writing-to-directory docs generate-documentation --target FlockKit --disable-indexing --transform-for-static-hosting --hosting-base-path FlockKit --output-path docs

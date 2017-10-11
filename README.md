# Stocks
This is my first iOS app, it’s a clone of the Stocks app by Apple. It’s just a learning project.

<a href="Readme_Assets/example1.png"><img src="Readme_Assets/example1-thumb.png" alt="Screenshot" height="300"></a>
<a href="Readme_Assets/example2.png"><img src="Readme_Assets/example2-thumb.png" alt="Screenshot" height="300"></a>
<a href="Readme_Assets/example3.png"><img src="Readme_Assets/example3-thumb.png" alt="Screenshot" height="300"></a>
<a href="Readme_Assets/example4.png"><img src="Readme_Assets/example4-thumb.png" alt="Screenshot" height="300"></a>

## Improvement ideas

- Add testing using XCTest.
- Add today widget.
- Support landscape orientation and iPads (using size classes).
- Add charts.

## Requirements
- iOS 10.0+
- Xcode 9.0+

## ApiKeys.plist
To get the news fetching working you need to create a ApiKeys.plist file in the root of the project with a data structure like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NYTIMES_API_KEY</key>
	<string>?</string>
</dict>
</plist>
```

[Get a New York Times API Key here.](https://developer.nytimes.com/)

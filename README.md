# RadarrExtension
> iOS extension share sheet that takes a movie url from IMDb app or website and sends it to Radarr server.

[![Swift Version][swift-image]][swift-url] [![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)

Ever wish you could send a movie to Radarr straight from an IMDb movie page? Well now you can! No more re-searching for a movie you already found in yet another interface.

![](header.png)

## Notes
As this is work in progress, there are a few things to be aware of:

- Hard coded to use HTTP, not HTTPS
- Quality Profile hard coded to HD-1080p
- "Search Now" option turns on monitoring and triggers an immediate search. "Later" is the opposite
- Min Availability hard coded to "Physical / Web"

## Features

- [x] Set whether to search immediately or later
- [x] Set monitored status
- [ ] Set quality profile
- [ ] Set min availability
- [x] Set path

## Requirements

- iOS 13.0+
- Xcode 11+

## SPM Dependencies

- [AwaitKit 5.2+](https://github.com/yannickl/AwaitKit)
- [KeychainAccess 4.2+](https://github.com/kishikawakatsumi/KeychainAccess)
- [PromiseKit 6.13.3+](https://github.com/mxcl/PromiseKit)
- [Zephyr 3.6+](https://github.com/ArtSabintsev/Zephyr)

## Credits

- String Extension from [Hacking With Swift](https://www.hackingwithswift.com/example-code/strings/how-to-convert-a-string-to-a-safe-format-for-url-slugs-and-filenames)
- Rounded buttons by [Adam Fils](https://medium.com/@filswino/easiest-implementation-of-rounded-buttons-in-xcode-6627efe39f84)
- Text Field Extension by [Amos Joshua](https://stackoverflow.com/questions/1347779/how-to-navigate-through-textfields-next-done-buttons)

## Acknowledgements / Disclaimer / Copyright / Attribution
- [TMDb API](https://developers.themoviedb.org/3)
- [IMDb API](https://developer.imdb.com)
- [Radarr Logo](https://github.com/Radarr/Radarr)
- Unofficial / Not affiated with Radarr

[swift-image]:https://img.shields.io/badge/swift-5.1-yellow.svg
[swift-url]: https://swift.org/

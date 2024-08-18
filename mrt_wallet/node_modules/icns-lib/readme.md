# icns-lib [![Build Status](https://travis-ci.org/ManRueda/icns-lib.svg?branch=master)](https://travis-ci.org/ManRueda/icns-lib)

> Read and creare [Apple Icon Image format](https://en.wikipedia.org/wiki/Apple_Icon_Image_format) files

Parse a buffer into a useful structure with each icon type and its data and convert that structure into a buffer to save it back to a valid .icns.


## Install

Ensure you have [Node.js](https://nodejs.org) 8 or later installed. Then run the following:

```
$ npm install icns-lib
```


## Usage

```javascript
const fs = require('sf');
const icns = require('icns-lib');

const buffer = fs.readFileSync('icons.icns')

// Parse the buffer into a map where the key is the Icon type (icp4, icp5, etc) and the value is a buffer with the data.
const icons = icns.parse(buffer);

Object.keys(icons).forEach(type => {
	// Remove all items that are not an image type icon
	if (!icns.isImageType(type)) {
		delete icons;
	}
})

// Save the icon set without all the non-image icons
fs.writeFileSync('icons.icns', icns.format(icons))

```

## License

MIT © [Manuel Rueda](https://manrueda.com)

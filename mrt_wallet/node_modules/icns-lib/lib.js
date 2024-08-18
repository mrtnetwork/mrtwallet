const iconsTypes = ['ICON', 'ICN#', 'icm#', 'icm4', 'icm8', 'ics#', 'ics4', 'ics8', 'is32', 's8mk', 'icl4', 'icl8', 'il32', 'l8mk', 'ich#', 'ich4', 'ich8', 'ih32', 'h8mk', 'it32', 't8mk'];
const imagesTypes = ['icp4', 'icp5', 'icp6', 'ic07', 'ic08', 'ic09', 'ic10', 'ic11', 'ic12', 'ic13', 'ic14'];
const otherTypes = ['TOC ', 'icnV', 'name', 'info'];

module.exports.parse = function (buffer) {
	buffer = Buffer.from(buffer);
	const header = buffer.slice(0, 8);
	let body = buffer.slice(8);
	if (header.slice(0, 4).toString('ascii') !== 'icns') {
		throw new Error('The file is not a valid Apple Icon Image file');
	}

	const icons = {};
	while (body.length > 8) {
		const osType = body.slice(0, 4);
		const size = body.slice(4, 8).readUInt32BE();
		const imageBody = body.slice(8, size);
		body = body.slice(size);
		icons[osType.toString('ascii')] = imageBody;
	}

	if (body.length > 0) {
		throw new Error('unknown data left in the read buffer');
	}

	return icons;
};

function validateIcnsStructure(type) {
	if (Buffer.from(type, 'ascii').length > 4) {
		throw new Error('Icon type must a 4bytes string');
	}
}

module.exports.isImageType = function (type) {
	return imagesTypes.includes(type);
};

module.exports.isIconType = function (type) {
	return iconsTypes.includes(type);
};

module.exports.isOtherType = function (type) {
	return otherTypes.includes(type);
};

module.exports.format = function (icons) {
	Object.keys(icons).forEach(validateIcnsStructure);

	const totalSize = Object.values(icons).reduce((out, icon) => out + icon.length + 8, 8);
	const file = Buffer.alloc(totalSize);
	let currentPointer = file.write('icns', 0, 4, 'ascii');
	currentPointer = file.writeUInt32BE(totalSize, currentPointer);

	for (const [type, icon] of Object.entries(icons)) {
		currentPointer += file.write(type, currentPointer);
		currentPointer = file.writeUInt32BE(icon.length + 8, currentPointer);
		currentPointer += icon.copy(file, currentPointer);
	}

	return file;
};

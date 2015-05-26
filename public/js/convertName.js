function convert(qName) {
	var charCode = ['h','g','f','e','d','c','b','a'];	
	var degrees = qName.slice(0,qName.length-2);
	var inCode = qName.toString().slice(qName.length-2)
	var outCode;
	switch (true) {
		//State/GNIS code
		case /^[a-hA-H][0-9]$/.test(inCode):
			var outIdx = charCode.indexOf(inCode.slice(0,1).toLowerCase());
			var numCode = ((8 * outIdx) + 9 - (parseInt(inCode.slice(-1))));
			outCode = degrees + (numCode < 10 ? "0" + numCode.toString() :  numCode.toString());
			break;
		//Quad code
		case /^[0-6][0-9]$/.test(inCode):
			// Could use var chr = String.fromCharCode(104 - (Math.floor(inCode/8)));
			// not sure which would be faster
			chr = charCode[(Math.floor((inCode-1)/8))];
			var remCode = (8-((inCode - 1) % 8));
			outCode = degrees + chr + remCode.toString();
			break;
		//leave as is? or output error message?
		default:
			// outCode = inCode;
			outCode = "Conversion Error";
			break;
	}
	return outCode;
}
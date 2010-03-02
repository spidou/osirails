// return the string of the float rounded with the specified precision, keeping zeros according to the precision
// x = 109.4687
// roundNumber(x, 1) => 109.5
//
// x = 109.6
// roundNumber(x, 3) => 109.600
function roundNumber(number, precision) {
  precision = parseInt(precision)
	var result = Math.round(parseFloat(number) * Math.pow(10, precision)) / Math.pow(10, precision)
	var str_result = result.toString()
	delimiter = str_result.indexOf(".")
	if (delimiter > 0) {
	  var integer = str_result.substring(0, delimiter)
	  var decimals = str_result.substring(delimiter + 1, str_result.length)
	  if (decimals.length < precision) {
	    for (i = decimals.length; i < precision; i++) {
	      decimals += "0"
	    }
	  }
	  str_result = integer + "." + decimals
	} else {
	  str_result += ".00"
	}
	return str_result
}

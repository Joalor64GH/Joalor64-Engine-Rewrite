Your custom gameplay changers go here!

The file name of the text file becomes the name of the gamechanger.
Supported types: "int, float, percent, string"

Please write it in a text file:
int, float, percent:
	 type,  tag, 		defaultValue, scrollSpeed, minValue, maxValue, changeValue, displayFormat, decimals
Example:"float, healthDecrease, 1,	      1, 	   0.1,      2,	       0.1,	    %vX,	   1	   "

string:
	 type,   tag,  choices
Example:"string, test, test1, test2, test3, bruh"

bool:	 type, tag,	    defaultValue
Example:"bool, dadReduceHP, false	"
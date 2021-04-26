extends Node

func _ready():
	pass # Replace with function body.
	
func getOnlyNumsFromTeText(inputText):
	inputText = str(inputText)
	if(!inputText.is_valid_integer()):
		var chars = ""
		for character in inputText.length():
			if(str(inputText[character]).is_valid_integer()):
				chars = chars + inputText[character]
		return chars
	else:
		return inputText
	



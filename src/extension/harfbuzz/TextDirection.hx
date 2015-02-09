package extension.harfbuzz;

@:enum abstract TextDirection(Int) to (Int) {

	var Invalid = 0;
	var LeftToRight = 4;
	var RightToLeft = 5;
	var TopToBottom = 6;
	var BottomToTop = 7;

}

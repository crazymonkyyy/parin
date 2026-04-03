#!opend -run app.d

/// This example serves as a classic hello world program, introducing the structure of a Parin program.

import parin;
import hotloadlib;
import std;
//import hotload;
mixin hotloadImport!"hotload";
import data;
// Called once when the game starts.
void ready() {
	lockResolution(320, 180);
}

// Called every frame while the game is running.
// If true is returned, then the game will stop running.
bool update(float dt) {
	static int i;
	static string s;
	if(isfilled){
		Circ(f(i++),size).drawCirc(color);
	} else {
		Circ(f(i++),size).drawHollowCirc(3,color);
	}
	drawDebugText(s,Vec2(0,0));
	if(Keyboard.f3.isPressed){
		s=readln;
		repl!(["parin","std"])(s);
	}
	if(Keyboard.f5.isPressed){
		writeln(&color);
		color.writeln;
		size.writeln;
		isfilled.writeln;
	}
	if(Keyboard.f6.isPressed){
		size=10;
	}
	//if(i==99){repl!(["parin"])("isfilled.writeln;");}
	return false;
}

// Called once when the game ends.
void finish() {}

// Creates a main function that calls the given functions.
mixin runGame!(ready, update, finish);

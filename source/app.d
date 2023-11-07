import std.stdio;
import pluto;

void main(){
	int a = 1, b = 2, c = 3;
	render!(a, b, c)(File("test.pluto", "r"));
}

module pluto;

import std.stdio,
			 std.string,
			 std.uni,
			 std.meta,
			 std.array,
			 std.algorithm,
			 std.conv;

import utils.ds;

private static immutable dstring[] TAGS =[
	"if", "ifnot", "else", "elif", "elifnot", "for"
];

pragma(inline, true);
bool render(V...)(File file){
	static foreach (sym; V)
		writefln!"%s -> %s"(__traits(identifier, sym), sym);
	return true;
}

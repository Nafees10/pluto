import std.stdio,
			 std.algorithm,
			 std.path,
			 std.file,
			 std.string;

import consts;

int main(string[] args){
	if (args.length < 2){
		stderr.writeln(HELP_TEXT);
		return 1;
	}

	if (["-h", "--help"].canFind(args[1])){
		writeln(HELP_TEXT);
		return 0;
	}

	if (["-v", "--version"].canFind(args[1])){
		writeln(VERSION_INFO);
		return 0;
	}

	string filename = args[1];
	string outFilename = filename.chomp(".pluto") ~ ".plt";
	if (args.length > 2)
		outFilename = args[2];
	return 0;
}

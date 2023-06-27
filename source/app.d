import std.stdio,
			 std.algorithm,
			 std.file,
			 std.path,
			 std.string,
			 std.uni,
			 std.conv;

import consts,
			 parser,
			 plter;

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

	if (!exists(filename) || !isFile(filename)){
		stderr.writefln!"File %s does not exist or is not a file"(filename);
		return 1;
	}

	string fcontent = filename.readText;
	debug writeln(fcontent);
	auto units = parse(fcontent);
	debug writeln(units);

	string pltCode = toPltFunction(genFuncName(filename), units);
	try{
		std.file.write(outFilename, pltCode);
	}catch (FileException e){
		stderr.writeln("Failed to write to output file:\n", e.msg);
		return 1;
	}
	return 0;
}

string genFuncName(string filename){
	char[] base;
	// remove all non alphanumeric
	foreach (c; baseName(stripExtension(filename))){
		if (isAlphaNum(c))
			base ~= c;
	}
	if (base.length == 0)
		return "render";
	base[0] = cast(char)base[0].toUpper;
	return cast(string)("render" ~ base);
}

module consts;

import std.conv : to;

public enum VERSION = "1.0.0";

public enum VERSION_INFO = `pluto version ` ~ VERSION ~ `
Compiled with ` ~ __VENDOR__ ~ ` ` ~ __VERSION__.to!string ~ `
Compiled on ` ~ __DATE__;

public enum HELP_TEXT = `pluto - Template engine for plutonium langauge
Usage:
	pluto file.pluto [output.plt]	Generate plt code from template
	pluto --version	Show version information
	pluto --help	Show this text`;

public enum FILE_EXT = ".pluto";

public static immutable dstring[] TAGS = ["if", "else", "elif", "for", "pluto"];

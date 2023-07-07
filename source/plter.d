module plter;

import std.stdio,
			 std.string,
			 std.array,
			 std.uni,
			 std.algorithm,
			 std.conv;

import parser : Unit;

public string toPltFunction(string name, Unit[] units){
	return "function " ~ name ~ "(var map)" ~ toPltBlock(units);
}

// escapes double quotes and backslashes
private string escapeStr(string str){
	string ret;
	foreach (c; str){
		if (c == '\r')
			continue; // no one likes your stupid newlines microsoft!
		if (c == '\n'){
			ret ~= "\\n";
			continue;
		}
		if (['"', '\\'].canFind(c))
			ret ~= '\\';
		ret ~= c;
	}
	return ret;
}

private string toPltBlock(Unit[] units, string[] definitions = null,
		uint indent = 0){
	const string indentStr = "\t".replicate(indent);
	string code = "{\n";
	foreach (unit; units){
		switch (unit.type){
			case Unit.Type.Static:
				code ~= staticToPlt(unit, indent + 1);
				break;
			case Unit.Type.Interpolate:
				code ~= interpolateToPlt(unit, definitions, indent + 1);
				break;
			case Unit.Type.If:
				code ~= ifToPlt(unit, definitions, indent + 1);
				break;
			case Unit.Type.Else:
				code ~= elseToPlt(unit, definitions, indent + 1);
				break;
			case Unit.Type.ElseIf:
				code ~= elifToPlt(unit, definitions, indent + 1);
				break;
			case Unit.Type.For:
				code ~= forToPlt(unit, definitions, indent + 1);
				break;
			default:
				throw new Exception("invalid unit type");
		}
	}
	return code ~ indentStr ~ "}\n";
}

private string staticToPlt(Unit unit, uint indent = 0){
	return "\t".replicate(indent) ~ "print(\"" ~ escapeStr(unit.val) ~ "\")\n";
}

private string interpolateToPlt(Unit unit, string[] definitions,
		uint indent = 0){
	if (definitions.canFind(unit.val))
		return "\t".replicate(indent) ~ "print(" ~ unit.val ~ ")\n";
	return  "\t".replicate(indent) ~ "print(map[\"" ~ unit.val ~ "\"])\n";
}

private string ifToPlt(Unit unit, string[] definitions, uint indent = 0){
	return "\t".replicate(indent) ~ "if (map.hasKey(\"" ~ unit.val ~ "\"))" ~
		toPltBlock(unit.subUnits, definitions, indent + 1);
}

private string elseToPlt(Unit unit, string[] definitions, uint indent = 0){
	return "\t".replicate(indent) ~ "else" ~
		toPltBlock(unit.subUnits, definitions, indent + 1);
}

private string elifToPlt(Unit unit, string[] definitions, uint indent = 0){
	return "\t".replicate(indent) ~ "else if (map.hasKey(\"" ~ unit.val ~ "\"))"
		~ toPltBlock(unit.subUnits, definitions, indent + 1);
}

private string forToPlt(Unit unit, string[] definitions, uint indent = 0){
	if (definitions.canFind(unit.container))
		return "\t".replicate(indent) ~ "foreach (var " ~ unit.iterator ~ " : " ~
				unit.container ~ ")" ~ toPltBlock(unit.subUnits,
					definitions ~ unit.iterator, indent + 1);
	return "\t".replicate(indent) ~ "foreach (var " ~ unit.iterator ~
		" : map[\"" ~ unit.container ~ "\"])" ~
		toPltBlock(unit.subUnits, definitions ~ unit.iterator, indent + 1);
}

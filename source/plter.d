module plter;

import std.stdio,
			 std.string,
			 std.uni,
			 std.algorithm,
			 std.conv;

import parser : Unit;

public string toPltFunction(string name, Unit[] units){
	return "function " ~ name ~ "(map)" ~ toPltBlock(units);
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

private string toPltBlock(Unit[] units, string[] definitions = null){
	string code = "{\n";
	foreach (unit; units){
		switch (unit.type){
			case Unit.Type.Static:
				code ~= staticToPlt(unit);
				break;
			case Unit.Type.Interpolate:
				code ~= interpolateToPlt(unit, definitions);
				break;
			case Unit.Type.If:
				code ~= ifToPlt(unit, definitions);
				break;
			case Unit.Type.Else:
				code ~= elseToPlt(unit, definitions);
				break;
			case Unit.Type.ElseIf:
				code ~= elifToPlt(unit, definitions);
				break;
			case Unit.Type.For:
				code ~= forToPlt(unit, definitions);
				break;
			default:
				throw new Exception("invalid unit type");
		}
	}
	return code ~ "}\n";
}

private string staticToPlt(Unit unit){
	return "print(\"" ~ escapeStr(unit.val) ~ "\")\n";
}

private string interpolateToPlt(Unit unit, string[] definitions){
	if (definitions.canFind(unit.val))
		return "print(" ~ unit.val ~ ")";
	return  "print(map[\"" ~ unit.val ~ "\"])\n";
}

private string ifToPlt(Unit unit, string[] definitions){
	return "if (map.hasKey(\"" ~ unit.val ~ "\"))" ~
		toPltBlock(unit.subUnits, definitions);
}

private string elseToPlt(Unit unit, string[] definitions){
	return "else" ~ toPltBlock(unit.subUnits, definitions);
}

private string elifToPlt(Unit unit, string[] definitions){
	return "else if (map.hasKey(\"" ~ unit.val ~ "\"))" ~
		toPltBlock(unit.subUnits, definitions);
}

private string forToPlt(Unit unit, string[] definitions){
	if (definitions.canFind(unit.container))
		return "foreach (" ~ unit.iterator ~ " : " ~ unit.container ~ ")" ~
			toPltBlock(unit.subUnits, definitions ~ unit.iterator);
	return "foreach (" ~ unit.iterator ~ " : map[\"" ~ unit.container ~ "\"])" ~
		toPltBlock(unit.subUnits, definitions ~ unit.iterator);
}

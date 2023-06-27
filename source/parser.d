module parser;

import std.stdio,
			 std.string,
			 std.uni,
			 std.array,
			 std.algorithm,
			 std.conv,
			 std.json;

import consts;

import utils.ds;

/// A sinlge contiguous unit in the template
private struct Unit{
	enum Type{
		Static,
		Interpolate,
		If,
		Else,
		ElseIf,
		For
	}

	private Type _type;
	private struct For{
		dstring iterator, container;
	}
	private union{
		dstring _staticText;
		For _for;
	}

	Unit[] subUnits;

	JSONValue toJSON() const {
		JSONValue ret;
		ret["type"] = _type.to!string;
		if (_type == Type.For){
			ret["iterator"] = _for.iterator.to!string;
			ret["container"] = _for.container.to!string;
		}else if ([Type.Static, Type.Interpolate, Type.If, Type.ElseIf].
				canFind(_type)){
			ret["str"] = _staticText.to!string;
		}
		JSONValue[] arr;
		arr.length = subUnits.length;
		foreach (i, sub; subUnits)
			arr[i] = sub.toJSON;
		if (arr.length)
			ret["subUnits"] = JSONValue(arr);
		return ret;
	}

	string toString() const{
		return toJSON.toPrettyString;
	}

	/// Which type of unit is this
	@property Type type() const pure {
		return _type;
	}

	/// Static text, or value to interpolate, or if/elif's condition
	@property dstring val() const pure {
		return _staticText;
	}

	/// For loop iterator name
	@property dstring iterator() const pure{
		return _for.iterator;
	}
	/// For loop container name
	@property dstring container() const pure{
		return _for.container;
	}

	static Unit createStatic(dstring text){
		Unit ret;
		ret._type = Type.Static;
		ret._staticText = text;
		return ret;
	}

	static Unit createInterpolate(dstring name){
		Unit ret;
		ret._type = Type.Interpolate;
		ret._staticText = name;
		return ret;
	}

	static Unit createIf(dstring condition){
		Unit ret;
		ret._type = Type.If;
		ret._staticText = condition;
		return ret;
	}

	static Unit createElse(){
		Unit ret;
		ret._type = Type.Else;
		return ret;
	}

	static Unit createElif(dstring condition){
		Unit ret;
		ret._type = Type.ElseIf;
		ret._staticText = condition;
		return ret;
	}

	static Unit createFor(dstring iterator, dstring container){
		Unit ret;
		ret._type = Type.For;
		ret._for.iterator = iterator;
		ret._for.container = container;
		return ret;
	}
}

Unit[] parse(dstring str){
	uint i;
	return parseUnits(str, i);
}

Unit[] parseUnits(dstring str, ref uint i){
	Unit[] ret;
	uint start = i;
	for (; i < str.length; i ++){
		const dchar ch = str[i];
		if (ch == '<'){
			if (_skipComment(str, i))
				continue;
			bool ending = false;
			const auto ind = i;
			if (i + 1 < str.length && str[i + 1] == '/'){
				ending = true;
				i ++;
			}
			auto tagName = _parseTagName(str, i);
			if (TAGS.canFind(tagName.asLowerCase.array)){
				// end this unit here
				ret ~= Unit.createStatic(str[start .. ind]);
				if (ending){
					// skip to >
					while (i < str.length && str[i] != '>') i ++;
					i ++;
					return ret;
				}
				ret ~= _parseApprTag(str, tagName, i);
				start = i;
				i --; continue;
			}
		}else if (ch == '\''){
			// just skip to end
			for (; i < str.length && str[i] != '\''; i ++){
				if (str[i] == '\\'){
					i ++; continue;
				}
			}
		}else if (ch == '{'){
			const auto ind = i;
			dstring interp = _isInterpolation(str, i);
			if (interp is null){
				i --; continue;
			}
			// end this unit
			ret ~= Unit.createStatic(str[start .. ind]);
			ret ~= Unit.createInterpolate(interp);
			start = i;
			i --; continue;
		}
	}
	if (start + 1 < str.length)
		ret ~= Unit.createStatic(str[start .. $]);

	return ret;
}

/// Checks if an interpolation is, well, an interpolation, by checking if
/// characters inside are alphanumeric
///
/// Returns: name, or null
dstring _isInterpolation(dstring str, ref uint i){
	if (str[i] != '{' || i + 2 >= str.length || str[i + 1] == '}')
		return null;
	i ++;
	const uint start = i;
	while (i < str.length && str[i].isAlphaNum) ++i;
	if (i >= str.length || str[i] != '}')
		return null;
	i ++;
	return str[start .. i - 1];
}

/// Returns: tag name, given dstring starting with opening angle bracket
dstring _parseTagName(dstring str, ref uint i){
	if (str[i] != '<' && (
				i == 0 || str[i - 1 .. i + 1] != "</"
				))
		return null;
	i ++;
	// skip whitespace
	while (i < str.length && str[i].isWhite)
		i ++;
	for (uint start = i; i < str.length; i ++){
		if (str[i].isWhite || str[i] == '>')
			return str[start .. i];
	}
	i = cast(uint)str.length;
	return str;
}

/// Checks if current tag is a comment, if so, skips it
bool _skipComment(dstring str, ref uint i){
	if (i + 3 <= str.length || str[i .. i + 4] != "<!--")
		return false;
	i += 4; // skip opening
	while (i + 3 < str.length && str[i .. i + 3] != "-->")
		i ++;
	i += 3;
	return true;
}

/// Reads a Pluto appopriate tag. Index i must be pointing to after the tagName
Unit _parseApprTag(dstring str, dstring tagName, ref uint i){
	switch (tagName){
		case "for":
			return _parseForTag(str, i);
		case "if":
			return _parseIfTag(str, i);
		case "else":
			return _parseElseTag(str, i);
		case "elif":
			return _parseElifTag(str, i);
		default:
			throw new Exception("Not an appropriate tag");
	}
}

/// Reads a for tag. index i must be at character after `<for`
Unit _parseForTag(dstring str, ref uint i){
	dstring iterator, container;
	// skip till non whitespace
	while (i < str.length && str[i].isWhite) ++i;
	uint start = i;
	while (i < str.length && !str[i].isWhite) ++i;
	iterator = str[start .. i];

	while (i < str.length && str[i].isWhite && str[i] != '>') ++i;
	start = i;
	while (i < str.length && !str[i].isWhite && str[i] != '>') ++i;
	container = str[start .. i];

	// skip till >
	while (i < str.length && str[i] != '>') ++i;
	i ++;
	if (iterator is null || container is null || i == str.length)
		throw new Exception("Invalid for tag");

	auto ret = Unit.createFor(iterator, container);
	ret.subUnits = parseUnits(str, i);
	return ret;
}

/// Reads an if tag
Unit _parseIfTag(dstring str, ref uint i){
	dstring condition;
	while (i < str.length && str[i].isWhite) ++i;
	uint start = i;
	while (i < str.length && !str[i].isWhite && str[i] != '>') ++i;
	condition = str[start .. i];

	// skip till >
	while (i < str.length && str[i] != '>') ++i;
	i ++;
	if (condition is null || i == str.length)
		throw new Exception("Invalid if tag");

	auto ret = Unit.createIf(condition);
	ret.subUnits = parseUnits(str, i);
	return ret;
}

/// Reads an else tag
Unit _parseElseTag(dstring str, ref uint i){
	// skip till >
	while (i < str.length && str[i] != '>') ++i;
	i ++;
	if (i == str.length)
		throw new Exception("Invalid else tag");

	auto ret = Unit.createElse();
	ret.subUnits = parseUnits(str, i);
	return ret;
}

/// Reads an elif tag
Unit _parseElifTag(dstring str, ref uint i){
	dstring condition;
	while (i < str.length && str[i].isWhite) ++i;
	uint start = i;
	while (i < str.length && !str[i].isWhite && str[i] != '>') ++i;
	condition = str[start .. i];

	// skip till >
	while (i < str.length && str[i] != '>') ++i;
	i ++;
	if (condition is null || i == str.length)
		throw new Exception("Invalid elif tag");

	auto ret = Unit.createElif(condition);
	ret.subUnits = parseUnits(str, i);
	return ret;
}

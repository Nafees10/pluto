module pluto;

import std.stdio,
			 std.file,
			 std.string,
			 std.utf,
			 std.uni,
			 std.array,
			 std.algorithm;

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

	static Unit createElseIf(dstring condition){
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

/// Returns: tag name, given dstring starting with opening angle bracket
dstring tagName(dstring str){
	if (str[0] != '<')
		return null;
	foreach (i, ch; str){
		if (ch.isWhite)
			return str[0 .. i];
	}
	return str;
}

/// Reads text until a pluto appropriate substring is found
/// Pluto appropriate substring would be:
/// * start of a pluto appropriate tag
/// * interpolation {}
/// * end of a pluto appropriate tag
///
/// Returns: string slice till before appropriate substring, or null if at start
Unit[] readTillAppropriate(dstring str, ref uint i){
	Unit[] ret;
	for (; i < str.length; i ++){
		const dchar c = str[i];
		if (c == '<'){
			bool ending = i + 1 < str.length && str[i + 1] == '/';
			if (ending)
				i ++;
			dstring tagName = str.tagName.asLowerCase.array;
			bool isAppropriate = TAGS.canFind(tagName);
			if (!isAppropriate)
				continue;
			i += tagName.length;
			if (ending){
				// TODO continue from here
			}else{
				if (isAppropriate)
					ret ~= Unit.createStatic(str[0 .. i]);
				ret ~= readTag(str, tagName, i);
				i --;
			}
		}
	}

	return ret;
}

/// Reads a Pluto appopriate tag
Unit readTag(dstring str, dstring tagName, uint i){
	if (!TAGS.canFind(tagName))
		throw new Exception("Not an appropriate tag");
	switch (tagName){

	}
}

/// Reads a for tag

/// Reads an if tag

/// Parser
public struct Parser{
private:
	dstring _source;
	uint _seek;
	bool _unitValid;
	Unit _unit;

	Unit _parse(){
		Unit ret;
		for (uint i = _seek; i < _source.length; i ++){

		}
		return ret;
	}

public:
	this(dstring source){
		_source = source;
		_unitValid = false;
	}

	bool empty() const pure {
		return _seek >= _source.length;
	}

	Unit front(){
		if (!_unitValid && !empty){
			_unitValid = true;
			_parse;
		}
		return _unit;
	}

	void popFront(){
		_unitValid = false;
	}
}

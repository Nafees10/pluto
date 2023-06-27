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

/// Parser
public struct Parser{
private:
	dstring _source;
	uint _seek;
	bool _unitValid;
	Unit _unit;

	Unit[] _parse(ref uint i){
		Unit[] ret;
		for (; i < _source.length; i ++){
			// TODO
		}
		return ret;
	}

	/// Returns: tag name, given dstring starting with opening angle bracket
	dstring _parseTagName(dstring str, uint i){
		if (str[0] != '<')
			return null;
		// skip whitespace
		for (; i < str.length; i ++){
			const dchar ch = str[i];
			if (ch.isWhite)
				return str[0 .. i];
		}
		i = cast(uint)str.length;
		return str;
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

		while (i < str.length && str[i].isWhite) ++i;
		start = i;
		while (i < str.length && !str[i].isWhite) ++i;
		container = str[start .. i];

		// skip till >
		while (i < str.length && str[i] != '>') ++i;
		if (iterator is null || container is null || i == str.length)
			throw new Exception("Invalid for tag");

		auto ret = Unit.createFor(iterator, container);
		ret.subUnits = _parse(i);
		return ret;
	}

	/// Reads an if tag
	Unit _parseIfTag(dstring str, ref uint i){
		dstring condition;
		while (i < str.length && str[i].isWhite) ++i;
		uint start = i;
		while (i < str.length && !str[i].isWhite) ++i;
		condition = str[start .. i];

		// skip till >
		while (i < str.length && str[i] != '>') ++i;
		if (condition is null || i == str.length)
			throw new Exception("Invalid if tag");

		auto ret = Unit.createIf(condition);
		ret.subUnits = _parse(i);
		return ret;
	}

	/// Reads an else tag
	Unit _parseElseTag(dstring str, ref uint i){
		// skip till >
		while (i < str.length && str[i] != '>') ++i;
		if (i == str.length)
			throw new Exception("Invalid else tag");

		auto ret = Unit.createElse();
		ret.subUnits = _parse(i);
		return ret;
	}

	/// Reads an elif tag
	Unit _parseElifTag(dstring str, ref uint i){
		dstring condition;
		while (i < str.length && str[i].isWhite) ++i;
		uint start = i;
		while (i < str.length && !str[i].isWhite) ++i;
		condition = str[start .. i];

		// skip till >
		while (i < str.length && str[i] != '>') ++i;
		if (condition is null || i == str.length)
			throw new Exception("Invalid elif tag");

		auto ret = Unit.createElif(condition);
		ret.subUnits = _parse(i);
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
			_parse(_seek);
		}
		return _unit;
	}

	void popFront(){
		_unitValid = false;
	}
}

# Pluto

A simple template engine for the
[plutonium language](https://github.com/shehryar49/plutonium-lang)

## Getting Started

Take a look at `docs/spec.md` for the specification.

## Building Pluto

You will need the following tools for building Pluto:

* git
* dub - installed alongside [DMD](https://dlang.org/download.html)

Run the following to build Pluto:

```bash
git clone https://github.com/Nafees10/pluto.git
cd pluto
dub build -b=release # ignore -b=release to enable debug messages
```

This will build the executable `pluto` or `pluto.exe` which you can move to
any directory in your `$PATH` like:

```bash
sudo cp pluto /usr/bin # on linux
```

## Using Pluto

Pluto works by taking template files, and generating plutonium code files that
contain a render function.

The render function will take a plutonium dictionary as a parameter and populate
the template with data from the dictionary.

To generate plutonium code from a template file:

```bash
pluto homePage.pluto
```

The above command will generate a file named `homePage.plt` which will contain
the `renderHomePage` function.

To specify output file:

```bash
pluto homePage.pluto template.plt
```

The function name will be `renderHomePage` in either case.

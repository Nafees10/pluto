# Pluto Specification

Pluto Templates are written as regular html files:

```html
<if loggedIn>
	<div class="message"> You are logged in </div>
</if><elif banned>
	<div class="warning"> You are banned </div>
</elif><else>
	<div class="warning"> I dont know </div>
</else>
<table>
	<tr>
		<th> Username </th>
		<th> Name </th>
		<th> Action </th>
	</tr>
	<for name in names and username in usernames>
		<tr>
			<td> {username} </td>
			<td> {name} </td>
			<td>
				<a href="/view/{username}"> View </a>
			</td>
		<tr>
	</for>
</table>
```

## Interpolation:

`{}` and `{{}}` are used for interpolation.

Interpolation will not occur inside single quotes, `'{x}'` will output `'{x}'`

Only alphanumeric characters are allowed inside `{..}`. It is an error if there
are non alphanumeric characters inside `{..}`

`{{}}` will interpolate as-it-is, while `{}` will replace `<` and `>`.

## If tags

the `<if>` tag can be used to write conditional code that appears if something
is defined, and it does not evaluate to false. This does not mean the key has
to be a boolean type, any non-boolean type will skip the is-not-false check.

The if tag can be extended by the `<else>` and the `<elif>` tags:

```html
<if SOMETHING>
	<p> SOMETHING is defined, and not false </p>
</if>
<elif SOMETHINGELSE>
	<p> SOMETHINGESLE is defined </p>
</elif>
<else>
	<p> nothing was defined </p>
</else>
```

These are the available if tags:

* `<if X> .. </if>` - only if X is defined, and if X is `bool`, only if X is
	`true`
* `<else> .. </else>` - only if last of any of the if-tags did not output
* `<elif X> .. </elif>`
* `<ifnot X> .. </if>` - only if X is not defined, and if X is `bool`, only if
	X is `false`
* `<elifnot X> .. </elifnot>`

## For tag

the `<for>` tag will iterate over an/multiple iteratable value(s).

Simple for:
```html
<if list>
	<ol>
		<for item in list>
			<li> {item} </li>
		</for>
	</ol>
</if>
```

Multiple iteratable values:
```html
<table>
	<tr>
		<th> Name </th>
		<th> Type </th>
	</tr>
	<for name in names and type in types>
		<tr>
			<td> {name} </td>
			<td> {type} </td>
		</tr>
	</for>
</table>
```

Nested for:
```html
<table>
	<for course in courses>
		<for section in course>
			<tr><td>{section}</td></tr>
		</for>
	</for>
</table>
```

## Import tag
The `import` tag can be used to extend/inherit a pluto template in another
template:

`foo.pluto`:
```html
<html>
	<head> <title> {title} </title> </head>
	<body>
		{{header}}
		{{content}}
	</body>
</html>
```

`bar.pluto`:
```html
<import foo>
	<title> Sample Title </title>

	<header>
		<h1> Website Name </h1>
	</header>

	<content>
		<p> Website Content </p>
	</content>
</import>
```

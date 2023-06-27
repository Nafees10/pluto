# Pluto Specification

Pluto Templates are written as regular html files:

```html
<if loggedIn> <!-- if loggedIn is defined in dictionary -->
	<div class="message"> You are logged in </div>
</if><elif banned>
	<div class="warning"> You are banned </div>
</elif><else>
	<div class="warning"> I dont know </div>
</else>
<table>
	<tr>
		<th> Name </th>
		<th> Action </th>
	</tr>
	<for name names> <!-- translates to a foreach loop -->
		<tr>
			<td> {name} </td> <!-- interpolation -->
			<td>
				<!-- interpolation also works inside '' -->
				<a href='view/{name}'> View </a> 
				<!-- interpolation will not happen inside double quotes: "{name}" -->
			</td>
		<tr>
	</for> <!-- needs to be closed like a regular tag -->
</table>
```

## Interpolation:

`{}` is used for interpolation.

Interpolation will not occur inside single quotes.

Only alphanumeric characters are allowed inside `{..}`. If this condition is
not met, it is treated as part of the html.

## If tag

the `<if>` tag can be used to write conditional code that appears only if
a key is defined in the values dictionary.

`<if NAME>` will check if "NAME" is present in the values dictionary.

The if tag can be extended by the `<else>` and the `<elif>` tags:

```html
<if SOMETHING>
	<p> SOMETHING is defined </p>
</if>
<elif SOMETHINGELSE>
	<p> SOMETHINGESLE is defined </p>
</elif>
<else>
	<p> nothing was defined </p>
</else>
```

## For tag

the `<for>` tag will iterate over an array value in the values dictionary.

Nested for is also possible:
```html
<table>
	<for course courses>
		<for section course>
			<tr><td>{section}</td></tr>
		</for>
	</for>
</table>
```

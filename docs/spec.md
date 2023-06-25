# Pluto Specification

Pluto Templates are written as regular html files:

```html
<if loggedIn> <!-- if loggedIn is defined -->
	<div class="message"> You are logged in </div>
</if> <!-- no support for else -->
<table>
	<tr>
		<th> Name </th>
		<th> Action </th>
	</tr>
	<for name : names> <!-- translates to a foreach loop -->
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

`{}` is used for interpolation. Interpolation is only supported on strings.

It is allowed to write regular plutonium code inside `{}` that evaluates to
strings.

Interpolation will occur inside double quotes.

## If tag

the `<if>` tag can be used to write conditional code that appears only if
a key is defined in the values dictionary.

`<if NAME>` will check if "NAME" is present in the values dictionary.

The if tag can be extended by the `<else>` and the `<elseif>` tags:

```html
<if SOMETHING>
	<p> SOMETHING is defined </p>
</if>
<elseif SOMETHINGELSE>
	<p> SOMETHINGESLE is defined </p>
</elseif>
<else>
	<p> nothing was defined </p>
</else>
```

## For tag

the `<for>` tag will iterate over an array value in the values dictionary.
See example at top.


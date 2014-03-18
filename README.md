flash-message
=============

## Setup ##

include in package.json
```
git+ssh://git@github.com:mediastream/flash-message.git#master
```

call flash-message in express configuration after sessions and before routing
```
...
app.use express.session
app.use require('flash-message')(options)
app.use app.router
...
```

## Options ##

| Nombre        | Required | Descripción                                                             |
| ------------- | -------- | ----------------------------------------------------------------------- |
| template      | false    | underscore template to be used                                          |
| source        | false    | source for string replacement, can be function (like i18n.__) or object |
| defaultType   | false    | if no type is set in req.flash, default will be used (default: null)    |

## Usage ##

call flash in any controller (route)
```
app.get '/', (req, res) ->
  req.flash 'message', type
```
and then call @flash() on any view (optional type)
```
@flash(type)
```

* If needed, default type for this request can be set with ```req.flash.use(type)```
* When validating if bad things happened, ```req.flash.has(type)``` can be used.

type can be any string. It's advised to use success, danger, warning or info for default template based on bootstrap

## TODO ##

* think how to improve this :D
_ = require 'underscore'

class flashMessage
  options:
    # Template accepts: message, type
    template: '<div class="alert alert-<%=type%> alert-dismissable"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button><p><%=message%></p></div>'
    # any object or function (like i18n.__)
    source: (text) -> text
    # calls to req.flash without any given type will use default
    defaultType: null

  init: (options) ->
    # Process options
    _.extend @options, options
    # Set express methods
    (req, res, next) =>
      if !req.session?
        return throw new Error 'flash-message requires session'
      req.session.flash = {} if !req.session.flash?
      req.flash = @set req
      req.flash.has = @has req
      req.flash.use = @use req
      res.locals.flash = @get req

      next()

  get: (req) ->
    # Function to process data
    if typeof @options.source is 'function'
      get_msg = @options.source
    else
      get_msg = (text) =>
        @options.source[text] ? text
    # res.locals.flash
    (type) =>
      response = []
      for key, val of req.session?.flash or []
        if !type? or key is type
          for text in req.session.flash[key]
            response.push _.template(@options.template, { message: get_msg(text), type: key })
          delete req.session.flash[key]
      response.join ''

  set: (request) ->
    # req.flash
    (message, type) =>
      type = type ? @options.defaultType
      if type? and message? and request.session?
        request.session.flash[type] = [] if !request.session.flash[type]?
        request.session.flash[type].push message

  has: (request) ->
    # req.flash.has
    (type) =>
      type = type ? @options.type
      if type?
        return request.session?.flash?[type]?.length > 0
      else
        return request.session?.flash?.length > 0

  use: (request) ->
    # req.flash.use
    (type) =>
      if type? and type isnt ''
        @options.defaultType = type

flash_message = new flashMessage
module.exports = (req, res, next) -> flash_message.init req, res, next

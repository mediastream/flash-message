_ = require 'underscore'

class flashMessage
  options:
    #Template accepts: message, type
    template: '<div class="alert alert-<%=type%> alert-dismissable"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button><p><%=message%></p></div>'
    # any object or function (like i18n.__)
    source: (text) -> text

  init: (options) ->
    # Process options
    _.extend @options, options
    # Set express methods
    (req, res, next) =>
      if !req.session?
        return throw new Error 'flash-message requires session'
      req.flash = @set req
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
      for key, val of req.session.flash
        if !type? or key is type
          for text in req.session.flash[key]
            response.push _.template(@options.template, { message: get_msg(text), type: key })
          delete req.session.flash[key]
      response.join ''

  set: (request) ->
    # req.flash
    func = (message, type) =>
      if type? and message?
        request.session.flash = {} if !request.session.flash?
        request.session.flash[type] = [] if !request.session.flash[type]?
        request.session.flash[type].push message
    func.has = @has(request)
    func
    
  has: (request) ->
    # req.flash.has
    (type) =>
      if type?
        return request.session.flash[type]?.length > 0
      else
        return request.session.flash.length > 0

flash_message = new flashMessage
module.exports = (req, res, next) -> flash_message.init req, res, next
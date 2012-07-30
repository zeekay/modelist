mongoose = require 'mongoose'

module.exports = (name, schema = {}) ->
  lower = name.toLowerCase()
  upper = name.charAt(0).toUpperCase() + lower.substr 1

  # pluralize lowerCase
  plural = lower
  if plural.charAt(plural.length-1) != 's'
    plural += 's'

  _Model = new mongoose.Schema schema

  Model = mongoose.model upper, _Model
  Model.routes = ->
    # Generate Restful API

    # Create
    @post "/api/#{plural}", ->
      instance = @body
      new Model(model).save (err) =>
        if not err
          @json model, 201

    # List
    @get "/api/#{plural}", ->
      Model.find {}, (err, model) =>
        @json model

    # Get individual
    @get "/api/#{plural}/:id", (id) ->
      Model.findOne {id: id}, (err, model) =>
        @json model

    # Update
    @put "/api/#{plural}/:id", (id) ->
      model = @body
      Model.update {id: id}, model, {}, (err, num) =>
        @json (if err then 404 else 200)

    # Delete
    @del "/api/#{plural}/:id", (id) ->
      Model.findOne {id: id}, (err, model) =>
        if not err
          model.remove()
        @json (if err then 404 else 204)

  Model

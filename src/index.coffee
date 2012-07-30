mongoose = require 'mongoose'

# Generate routes for a mongoose model
createRoutes = (Model) ->
  # pluralize lowerCase
  plural = Model.modelName.toLowerCase()
  if plural.charAt(plural.length-1) != 's'
    plural += 's'

  ->
    # Create
    @post "/api/#{plural}", ->
      doc = new Model(@body).save (err) =>
        if not err
          @json doc, 201

    # List
    @get "/api/#{plural}", ->
      Model.find {}, (err, docs) =>
        @json docs

    # Get individual
    @get "/api/#{plural}/:id", (id) ->
      id ?= req.params.id
      Model.findOne {_id: id}, (err, doc) =>
        @json doc

    # Update
    @put "/api/#{plural}/:id", (id) ->
      id ?= req.params.id
      Model.update {_id: id}, @body, {}, (err, num) =>
        @json (if err then 404 else 200)

    # Delete
    @del "/api/#{plural}/:id", (id) ->
      id ?= req.params.id
      Model.findOne {_id: id}, (err, doc) =>
        if not err
          doc.remove()
        @json (if err then 404 else 204)

createModel = (name, schema = {}, schemaOpts = {}) ->
  lower = name.toLowerCase()
  upper = name.charAt(0).toUpperCase() + lower.substr 1

  Schema = new mongoose.Schema schema, schemaOpts
  Model = mongoose.model upper, Schema
  Model.routes = createRoutes Model
  Model

wrapper = createModel
wrapper.createRoutes = createRoutes
wrapper.connect = -> mongoose.connect.apply mongoose, arguments
wrapper.model = -> mongoose.model.apply mongoose, arguments
wrapper.Schema = mongoose.Schema
wrapper.ObjectId = mongoose.Schema.ObjectId

module.exports = wrapper

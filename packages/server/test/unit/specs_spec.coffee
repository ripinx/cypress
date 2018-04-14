require("../spec_helper")

R = require("ramda")
path = require("path")
files = require("#{root}lib/files")
config = require("#{root}lib/config")
specs = require("#{root}lib/util/specs")
FixturesHelper = require("#{root}/test/support/helpers/fixtures")

describe "lib/util/specs", ->
  beforeEach ->
    FixturesHelper.scaffold()

    @todosPath = FixturesHelper.projectPath("todos")

    config.get(@todosPath)
    .then (cfg) =>
      @config = cfg

  afterEach ->
    FixturesHelper.remove()

  context ".find", ->
    checkFoundSpec = (foundSpec) ->
      if not path.isAbsolute(foundSpec.absolute)
        throw new Error("path to found spec should be absolute #{JSON.stringify(foundSpec)}")

    it "returns absolute filenames", ->
      specs
      .find(@config)
      .then (R.prop("integration"))
      .then (R.forEach(checkFoundSpec))

    it "handles fixturesFolder being false", ->
      @config.fixturesFolder = false

      fn = => specs.find(@config)

      expect(fn).not.to.throw()

    it "by default, returns all files as long as they have a name and extension", ->
      config.get(FixturesHelper.projectPath("various-file-types"))
      .then (cfg) ->
        specs.find(cfg)
      .then (files) ->
        expect(files.integration.length).to.equal(3)
        expect(files.integration[0].name).to.equal("coffee_spec.coffee")
        expect(files.integration[1].name).to.equal("js_spec.js")
        expect(files.integration[2].name).to.equal("ts_spec.ts")

    it "returns files matching config.testFiles", ->
      config.get(FixturesHelper.projectPath("various-file-types"))
      .then (cfg) ->
        cfg.testFiles = "**/*.coffee"
        specs.find(cfg)
      .then (files) ->
        expect(files.integration.length).to.equal(1)
        expect(files.integration[0].name).to.equal("coffee_spec.coffee")

    it "filters using specPattern", ->
      config.get(FixturesHelper.projectPath("various-file-types"))
      .then (cfg) ->
        specs.find(cfg, [
          path.join(cfg.projectRoot, "cypress", "integration", "js_spec.js")
        ])
      .then (files) ->
        expect(files.integration.length).to.equal(1)
        expect(files.integration[0].name).to.equal("js_spec.js")

    it "filters using specPattern as array of glob patterns", ->
      config.get(FixturesHelper.projectPath("various-file-types"))
      .then (cfg) ->
        specs.find(cfg, [
          path.join(cfg.projectRoot, "cypress", "integration", "js_spec.js")
          path.join(cfg.projectRoot, "cypress", "integration", "ts*")
        ])
      .then (files) ->
        expect(files.integration.length).to.equal(2)
        expect(files.integration[0].name).to.equal("js_spec.js")
        expect(files.integration[1].name).to.equal("ts_spec.ts")
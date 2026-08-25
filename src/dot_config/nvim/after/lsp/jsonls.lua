return {
	settings = {
		json = {
			-- SchemaStore associations (package.json, tsconfig.json, ...) like VSCode.
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
}

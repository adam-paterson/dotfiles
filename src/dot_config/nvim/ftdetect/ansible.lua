-- Keep inventory, variable files, and unrelated YAML as ordinary YAML.
vim.filetype.add({
	pattern = {
		[".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
		[".*/roles/[^/]+/tasks/.*%.ya?ml"] = "yaml.ansible",
		[".*/roles/[^/]+/handlers/.*%.ya?ml"] = "yaml.ansible",
	},
})

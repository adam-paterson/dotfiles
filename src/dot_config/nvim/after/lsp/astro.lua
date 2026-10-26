-- Astro needs the JavaScript TypeScript SDK, which native TypeScript 7 no
-- longer ships. Keep the editor SDK independent of the project's compiler.
return {
	init_options = {
		typescript = {
			tsdk = vim.fn.stdpath("config") .. "/tools/node_modules/typescript/lib",
		},
	},
}

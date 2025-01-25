// Configuration file for ESLint (https://eslint.org/)

import tsparser from "@typescript-eslint/parser";
import regexp from "eslint-plugin-regexp";
import markdown from "@eslint/markdown";

export default [
	...markdown.configs.processor,

	{
		languageOptions: {
			parserOptions: {
				ecmaFeatures: {
					jsx: true,
				},
			},
			ecmaVersion: "latest",
			sourceType: "module",
		},
	},
	{
		files: ["**/*.{js,jsx,cjs,mjs,ts,cts,mts,md}"],
		plugins: {
			regexp,
		},
		rules: {
			"regexp/no-super-linear-backtracking": [
				"error",
				{
					report: "certain",
				},
			],
			"regexp/no-super-linear-move": [
				"error",
				{
					ignorePartial: false,
					ignoreSticky: false,
					report: "certain",
				},
			],
		},
	},
	{
		files: ["**/*.{,c,m}ts", "**/*.md/*.{,c,m}ts"],
		languageOptions: {
			parser: tsparser,
		},
	},
	{
		ignores: [
			// Cache/temp directories
			".cache/",
			".npm/",
			".parcel-cache/",
			".rpt2_cache/",
			".rts2_cache_cjs/",
			".rts2_cache_es/",
			".rts2_cache_umd/",
			".temp/",
			".yarn/cache/",
			".yarn/unplugged/",

			// Dependency directories
			"bower_components/",
			"jspm_packages/",
			"node_modules/",
			"vendor/",
			"web_modules/",

			// IDE directories
			".idea/",
			".vscode/",

			// Output directories
			".docusaurus/",
			".fusebox/",
			".dynamodb/",
			".grunt/",
			".next/",
			".nuxt/",
			".nyc_output/",
			".serverless/",
			".vuepress/dist/",
			"coverage/",
			"dist/",
			"lib-cov/",
			"out/",

			// Test directories & files
			"**/__mocks__/",
			"**/__tests__/",
			"**/__specs__/",
			"e2e/",
			"spec/",
			"specs/",
			"test/",
			"tests/",
			"**/*.spec.*",
			"**/*.test.*",
		],
	},
];

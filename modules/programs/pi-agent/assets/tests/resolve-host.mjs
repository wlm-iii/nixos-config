import { existsSync } from "node:fs";
import { createRequire, registerHooks } from "node:module";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

if (!process.env.PI_PACKAGE_DIR) throw new Error("Set PI_PACKAGE_DIR to the installed pi-coding-agent package directory");
const hostRequire = createRequire(resolve(process.env.PI_PACKAGE_DIR, "package.json"));
const bundledIndex = resolve(process.env.PI_PACKAGE_DIR, "dist/bundle/index.js");
const hostIndex = existsSync(bundledIndex) ? bundledIndex : resolve(process.env.PI_PACKAGE_DIR, "dist/index.js");
const modules = new Map([
	["@earendil-works/pi-tui", pathToFileURL(hostRequire.resolve("@earendil-works/pi-tui")).href],
	["@earendil-works/pi-coding-agent", pathToFileURL(hostIndex).href],
]);
registerHooks({
	resolve(specifier, context, nextResolve) {
		const url = modules.get(specifier);
		if (url) return { url, shortCircuit: true };
		return nextResolve(specifier, context);
	},
});

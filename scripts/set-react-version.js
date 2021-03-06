#!/usr/bin/env node
//
// Copyright (c) Microsoft Corporation
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//
// @ts-check

const profiles = {
  "0.60": {
    react: "16.8.6",
    "react-native": "0.60.6",
    "react-native-macos": "0.60.0-microsoft.79",
    "react-native-windows": undefined,
  },
  0.61: {
    react: "16.9.0",
    "react-native": "0.61.5",
    "react-native-macos": "0.61.65",
    "react-native-windows": undefined,
  },
  0.62: {
    react: "16.11.0",
    "react-native": "0.62.2",
    "react-native-macos": "0.62.16",
    "react-native-windows": "0.62.17",
  },
  0.63: {
    react: "16.13.1",
    "react-native": "0.63.4",
    "react-native-macos": "0.63.3",
    "react-native-windows": "0.63.14",
  },
  master: {
    react: "17.0.1",
    "react-native": "facebook/react-native#master",
    "react-native-codegen": "^0.0.6",
    "react-native-macos": undefined,
    "react-native-windows": undefined,
  },
};

/**
 * Coerces string value to version literal.
 * @param {string} v
 * @return {v is keyof profiles}
 */
function isValidVersion(v) {
  return Boolean(Object.prototype.hasOwnProperty.call(profiles, v));
}

const path = require("path");

const { [1]: scriptPath, [2]: version } = process.argv;
if (!isValidVersion(version)) {
  const script = path.basename(scriptPath);
  console.log(`Usage: ${script} [${Object.keys(profiles).join(" | ")}]`);
  process.exit();
}

const profile = profiles[version];

const fs = require("fs");
const { EOL } = require("os");

["package.json", "example/package.json"].forEach((manifestPath) => {
  const content = fs.readFileSync(manifestPath, { encoding: "utf-8" });
  const manifest = JSON.parse(content);
  Object.keys(profile).forEach((packageName) => {
    manifest["devDependencies"][packageName] = profile[packageName];
  });

  const tmpFile = `${manifestPath}.tmp`;
  fs.writeFile(tmpFile, JSON.stringify(manifest, undefined, 2) + EOL, (err) => {
    if (err) {
      throw err;
    }

    fs.rename(tmpFile, manifestPath, (err) => {
      if (err) {
        throw err;
      }
    });
  });
});

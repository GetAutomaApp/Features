import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const requiredSwift = readFileSync(join(root, ".swift-version"), "utf8").trim();
const requiredSwiftLint = "0.63.2";
const requiredSwiftFormat = "0.61.0";

function commandOutput(command, args = []) {
  return execFileSync(command, args, {
    cwd: root,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

function fail(message) {
  console.error(message);
  process.exitCode = 1;
}

function requireCommand(command, args, expected, installHint) {
  let output;

  try {
    output = commandOutput(command, args);
  } catch {
    fail(`${command} is not available. ${installHint}`);
    return;
  }

  if (!output.includes(expected)) {
    fail(`${command} must be ${expected}. Current output: ${output}`);
  }
}

requireCommand(
  "swift",
  ["--version"],
  `Swift version ${requiredSwift}`,
  `Install it with: swiftly install ${requiredSwift}`
);

requireCommand(
  "swiftlint",
  ["version"],
  requiredSwiftLint,
  `Install ${requiredSwiftLint} with your system package manager.`
);

requireCommand(
  "swiftformat",
  ["--version"],
  requiredSwiftFormat,
  `Install ${requiredSwiftFormat} with your system package manager.`
);

if (process.exitCode) {
  process.exit();
}

console.log(`Features setup OK: Swift ${requiredSwift}, SwiftLint ${requiredSwiftLint}, SwiftFormat ${requiredSwiftFormat}`);

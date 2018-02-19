const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

console.log(__dirname);

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const twoUpPath = path.resolve(__dirname, 'contracts', 'TwoUp.sol');
console.log(twoUpPath);
const source = fs.readFileSync(twoUpPath, 'utf8');
const output = solc.compile(source, 1).contracts;

fs.ensureDirSync(buildPath);

for (let contract in output) {
  console.log(contract);
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(':', '') + '.json'),
    output[contract]
  );
}

module.exports = {
                   twoUpContract: output[":Twoup"],
                   twoUpFactoryContract: output[":TwoupFactory"]
                 };

console.log("Compiled Sol Files");
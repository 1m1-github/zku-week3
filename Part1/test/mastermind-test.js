//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected

const {assert, describe } = require("chai");

const wasm_tester = require("circom_tester").wasm;

describe("MastermindVariation", function () {
    this.timeout(100000000);

    it("first test", async function () {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");

        const INPUT = {
            "n": 2,
            "pubGuess": [[0,1,2,3], [0,1,2,4]],
            "pubPoints": [5, 6],
            "pubSolnHash": "",
            "privSoln": [0,1,3,4],
            "privSalt": "a"
        }

        const witness = await circuit.calculateWitness(INPUT, true);

        console.log(witness);

        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));

    });
});
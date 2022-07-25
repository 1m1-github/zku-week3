//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected

const { assert } = require("chai");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

describe("MastermindVariation", function () {
    this.timeout(100000000);

    it("normal case", async function () {

        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        
        const INPUT = {
            "pubGuess": [[0,1,2,3], [0,1,2,4]],
            "pubPoints": [5, 6],
            "pubSolnHash": 21321042523921699663708924496043802621039204115273409537209625359104061724298n,
            "privSoln": [0,1,3,4],
            "privSalt": "1"
        }
        
        const witness = await circuit.calculateWitness(INPUT, true);

        // console.log(witness);

        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
    });

    it("both zero", async function () {

        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        
        const INPUT = {
            "pubGuess": [[0,1,2,3], [0,1,2,4]],
            "pubPoints": [0, 0],
            "pubSolnHash": 1277149130936616608671614792208552181232499806493465210892108998744382167348n,
            "privSoln": [9,8,7,6],
            "privSalt": "1"
        }
        
        const witness = await circuit.calculateWitness(INPUT, true);

        // console.log(witness);

        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
    });

    it("bad input", async function () {

        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        
        const INPUT = {
            "pubGuess": [[0,1,2,3], [0,1,2,-4]],
            "pubPoints": [0, 0],
            "pubSolnHash": 1277149130936616608671614792208552181232499806493465210892108998744382167348n,
            "privSoln": [9,8,7,6],
            "privSalt": "1"
        }
        
        try {
            const witness = await circuit.calculateWitness(INPUT, true);
            assert.fail();
        }
        catch {
            assert(1);    
        }
    });
});
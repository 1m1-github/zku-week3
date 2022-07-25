pragma circom 2.0.0;

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit

template MastermindVariation(n) {

    // Public inputs
    signal input pubGuess[n][4];
    signal input pubPoints[n];
    signal input pubSolnHash;

    // Private inputs
    signal input privSoln[4];
    signal input privSalt;

    // Output
    signal output solnHashOut;

    var i = 0;
    var j = 0;
    var k = 0;
    component lessThan[n][8];
    component equalGuess[n][6];
    component equalSoln[n][6];
    
    // Create a constraint that the solution and guess digits are all less than 10.
    for (i=0; i<n; i++) {
      var equalIdx = 0;
      for (j=0; j<4; j++) {
          lessThan[i][j] = LessThan(4);
          lessThan[i][j].in[0] <== pubGuess[i][j];
          lessThan[i][j].in[1] <== 10;
          lessThan[i][j].out === 1;
          lessThan[i][j+4] = LessThan(4);
          lessThan[i][j+4].in[0] <== privSoln[j];
          lessThan[i][j+4].in[1] <== 10;
          lessThan[i][j+4].out === 1;
          for (k=j+1; k<4; k++) {
              // Create a constraint that the solution and guess digits are unique. no duplication.
              equalGuess[i][equalIdx] = IsEqual();
              equalGuess[i][equalIdx].in[0] <== pubGuess[i][j];
              equalGuess[i][equalIdx].in[1] <== pubGuess[i][k];
              equalGuess[i][equalIdx].out === 0;
              equalSoln[i][equalIdx] = IsEqual();
              equalSoln[i][equalIdx].in[0] <== privSoln[j];
              equalSoln[i][equalIdx].in[1] <== privSoln[k];
              equalSoln[i][equalIdx].out === 0;
              equalIdx += 1;
          }
      }
    }

    // Count points
    // https://boardgamegeek.com/boardgame/21506/new-mastermind
    // 1 point for right color, wrong spot
    // 2 points for right color, right spot
    // 10 points for cracking the code
    var points[n];
    component equalHB[n][16];

    for (i=0; i<n; i++) {
      points[i] = 0;
      for (j=0; j<4; j++) {
          for (k=0; k<4; k++) {
              equalHB[i][4*j+k] = IsEqual();
              equalHB[i][4*j+k].in[0] <== privSoln[j];
              equalHB[i][4*j+k].in[1] <== pubGuess[i][k];
              points[i] += equalHB[4*j+k].out;
              if (j == k) {
                  points[i] += equalHB[4*j+k].out;
              }
          }
      }
      // 10 points for cracking the code
      if (points[i] == 8) {
        points[i] += 2;
      }
    }

    // Create a constraint around the number of hit
    component equalPoints[n];
    for (i=0; i<n; i++) {
      equalPoints[i] = IsEqual();
      equalPoints[i].in[0] <== pubPoints;
      equalPoints[i].in[1] <== points[i];
      equalPoints[i].out === 1;
    }
    
    // Verify that the hash of the private solution matches pubSolnHash
    component poseidon = Poseidon(5);
    poseidon.inputs[0] <== privSalt;
    poseidon.inputs[1] <== privSoln[0];
    poseidon.inputs[2] <== privSoln[1];
    poseidon.inputs[3] <== privSoln[2];
    poseidon.inputs[4] <== privSoln[3];

    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;

}

component main = MastermindVariation();
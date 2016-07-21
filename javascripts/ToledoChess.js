//(c)2010 Oscar Toledo G.

// Chessboard structure (array "board"):
//      0  1  2  3  4  5  6  7  8  9
//  00 -- -- -- -- -- -- -- -- -- --
//  10 -- -- -- -- -- -- -- -- -- --
//  20 -- A8 B8 C8 D8 E8 F8 G8 H8 --
//  30 -- A7 B7 C7 D7 E7 F7 G7 H7 --
//  40 -- A6 B6 C6 D6 E6 F6 G6 H6 --
//  50 -- A5 B5 C5 D5 E5 F5 G5 H5 --
//  60 -- A4 B4 C4 D4 E4 F4 G4 H4 --
//  70 -- A3 B3 C3 D3 E3 F3 G3 H3 --
//  80 -- A2 B2 C2 D2 E2 F2 G2 H2 --
//  90 -- A1 B1 C1 D1 E1 F1 G1 H1 --
// 100 -- -- -- -- -- -- -- -- -- --
// 110 -- -- -- -- -- -- -- -- -- --
//
// Piece codes:
//   1 - pawn      4 - bishop
//   2 - king      5 - rook
//   3 - knight    6 - queen
//
// White pieces or'ed with 0x08, pieces that wasn't moved or'ed with 0x10.
// So, for example, white king has code 0x1A and after it's first move becomes 0x0A.
// Area outside of the chessboard filled with 0x07, empty cells contain 0x00.

define([], function() {

  var moveFrom, // source position of the move
    curPieceCode, // current piece code
    curPlayer, // current player: 0 - white, 8 - black
    pawn2SquareMove, // position of pawn after two-square move, 0 after any other move
    moveTo, // target position of the move
    I = [],
    board = [], // chessboard (12 rows x 10 columns, see wiki for more info)
    promotePawnTo = 6,
    C120 = 120,
    C10 = 10, // just ten ;)
    C15 = 15, // just fifteen ;)
    C10000 = 10000,
    piecesCosts = [0,99,0,306,297,495,846], // cost of the pieces (empty,pawn,king,knight,bishop,rook,queen)
    rowsCosts = [-1,0,1,2,2,1,0,-1]; // cost of the rows/columns

  function movesForPiece(piece) {
    var moves = [
      [9,11,10,20],                 // black pawn
      [-1,1,-10,10,-11,-9,9,11],    // king
      [-21,-19,-12,-8,8,12,19,21],  // knight
      [-11,-9,9,11],                // bishop
      [-1,1,-10,10],                // rook
      [-1,1,-10,10,-11,-9,9,11]     // queen
    ];

    // for white pawn
    if ((piece & 15) == 9)
      return [-9,-11,-10, -20];

    // for other pieces
    return moves[(piece & 7) - 1];
  }

  function executeMove(O, p, n, m, g) {
    board[p] = n;
    if (m) {
      board[g] = board[m];
      board[m] = 0;
    } else if (g) {
      board[g] = 0;
    }
    board[O] = 0;
  }

  function undoMove(O, p, o, r, m, g) {
    board[O] = o;
    board[p] = r;
    if (m) {
      board[m] = board[g];
      board[g] = 0;
    } else if (g) {
      board[g] = 9 ^ curPlayer;
    }
  }

  // When w=0 function scans all possible moves, otherwise just that ends up at w
  // c - cutoff threshold. Function returns if h>0 and move with heuristic greater than c found
  // h - current depth (starts with 0)
  // e - cell from which moves enumeration starts (usually 21, "A8")
  // S - position of pawn after two-square move, 0 after any other move
  // s - scan depth (1 - verify B -> b and execute it,
  //                 0 - used for check checking (returns above 70k when opponent's king under attack)
  function compute(w,cutoff,currDepth,startCell,pawn2SquareMoveParam,scanDepth) {
    var t,
      o,
      L, // heuristic of the current move
      E,
      d,
      O = startCell,
      N = -C10000*C10000, // heuristic of the best move
      K = (78 - currDepth) << C10, // cost of the check
      p,
      g, // "en passant" or castling target position
      n,
      m, // castling source position
      q,
      r,
      C,
      J,
      a = curPlayer ? -C10 : C10, // +10 for white, -10 for black
      moves;
    curPlayer ^= 8;
    C120++;
    d = w || (scanDepth && scanDepth>=currDepth && compute(0,0,0,21,0,0) > C10000);
    // loop for all cells starting with e (usually 21, "A8") and finishing just before e
    // O - current cell, read-only inside loop
    do {
      p = O; // current position
      o = board[p]; // current piece code (or'ed with 16) or 0 or 7
      if (o) { // if cell isn't empty
        q = o & C15 ^ curPlayer; // current piece code (1..6 for current player, 9..14 for opponent, 7 or 15 - outside)
        if (q < 7) {
          q--;
          moves = movesForPiece(o);
          C = 0;
          // q decreased: 0 pawn, 1 king, 2 knight, 3 bishop, 4 rook, 5 queen
          // check each possible move of the current piece
          // C,q,o are read-only inside loop
          do {
            p += moves[C]; // target cell position
            r = board[p]; // piece code at the target cell, read-only below
            if (!w | p == w) { // required target cell not specified or equals to current target
              g = (q == 0 && p + a == pawn2SquareMoveParam) ? pawn2SquareMoveParam : 0; // en passant
              if ((!r & (!!q | C>1 || !!g)) || ((r+1&C15^curPlayer)>9 && (q | C<2))) {
                m = !(r - 2 & 7); // king on the target cell, check!
                if (m) {
                  curPlayer ^= 8;
                  I[C120--] = O;
                  return K;
                }
                // m is 0 after this point
                J = n = o & C15; // J & n - current piece code
                E = board[p - a] & C15; // piece at the cell above target (for white) or below target (for black)
                // for pawn on the last line loop runs from n=3 (or 11) to t=6 (or 14) (promotions)
                // for king loop can run two times if castling is possible
                // for any other piece loop runs only once with n = t = piece code
                t = (q | E-7) ? n : (n+=2,6^curPlayer);
                while (n <= t) {
                  // Heuristic:
                  // For attack moves:
                  //   + attacked piece cost
                  //     pawn: 99, knight: 306, bishop: 297, rook: 495, queen: 846
                  //   - attacker piece cost
                  //     pawn: 0, king: 1, knight: 2, bishop: 3, rook: 4, queen: 5
                  //   - current depth
                  // For king:
                  //   +9 for castling
                  // For all except king:
                  //   + for target row
                  //   - for source row
                  //     1:-1, 2:0, 3:1, 4:2, 5:2, 6:1, 7:0, 8:-1
                  //   + for target column (doubled for pawns)
                  //   - for source column
                  //     A:-1, B:0, C:1, D:2, E:2, F:1, G:0, H:-1
                  //   +8 if piece doesn't moved before
                  // For pawn:
                  //   -99 if current move isn't "en passant"
                  //   +1 if have own pawn to the left/right of the target cell
                  //   + for promotion:
                  //     knight: 306, bishop: 297, rook: 495, queen: 846
                  //   +1 for two-square move
                  // For all:
                  //   +1 for blocking opponent's pawn
                  L = r ? piecesCosts[r&7]-currDepth-q : 0; // value of the attacked piece (0 for empty cell)
                  if (scanDepth) {
                    L+=((1-q) ? rowsCosts[(p-p%C10)/C10-2] - rowsCosts[(O-O%C10)/C10-2] +
                          rowsCosts[p%C10-1]*(q?1:2) - rowsCosts[O%C10-1] + (o&16)/2
                          : !!m * 9) +
                       (!q ? !(board[p-1]^n) + !(board[p+1]^n) + piecesCosts[n&7] - 99 + !!g * 99 + (C == 3)
                         : 0) +
                       !(E ^ curPlayer ^ 9);
                  }
                  if ((scanDepth > currDepth) || ((1<scanDepth & scanDepth==currDepth) && (L>C15 | d))) {
                    // execute move
                    executeMove(O, p, n, m, g);
                    // find opponent's best move
                    J = (q | C<3) ? 0 : p;
                    L -= compute((scanDepth > currDepth | d) ? 0 : p,
                         L - N,
                         currDepth + 1,
                         I[C120+1],
                         J,
                         scanDepth);
                    // if we in check mode (s==1) and current move (O,p,n) same as player's (B,b,i)
                    // and move is possible then update chessboard and return
                    if (!currDepth && scanDepth == 1 && moveFrom == O && curPieceCode == n && p == moveTo && L >= -C10000) {
                      callbacks.aiCallback( curPlayer, moveFrom, moveTo);
                      if( m) // castling
                        callbacks.aiCallback( curPlayer, m, g);
                      DrawPieces();
                      C120--;
                      pawn2SquareMove = J;
                      return pawn2SquareMove;
                    }
                    // is castling possible?
                    J = (q-1 | C>1) || m || (!scanDepth | d | r | o<C15) || compute(0,0,0,21,0,0) > C10000;
                    // undo move
                    undoMove(O, p, o, r, m, g);
                  }
                  // if current move has better heuristic
                  if (L>N || (scanDepth>1 && L==N && !currDepth && Math.random()<.5)) {
                    I[C120] = O;
                    if (scanDepth > 1) {
                      // cutoff
                      if (currDepth && L > cutoff) {
                        curPlayer ^= 8;
                        C120--;
                        return L;
                      }
                      // output this move
                      if (!currDepth) {
                        curPieceCode = n;
                        moveFrom = O;
                        moveTo = p;
                      }
                    }
                    N = L;
                  }
                  // try castling if J == 0
                  n += J || (g = p,
                         m = (p < O) ? g-3 : g+2,
                         (board[m] < C15 | board[m+O-p]) || board[p+=p-O]) ? 1 : 0;
                }
              }
            }
            // If target cell was empty and current piece is rook, queen or bishop -
            // try to move further in same direction. otherwise try next move from table
            // skip two-square move for pawn if it was moved, or square ahead of it is occupied.
          } while ((!r & q>2) || (p=O, (q | C < 2 | o > C15 & !r) && (++C < moves.length)));
        }
      }
    } while ((++O > 98) ? O = 20 : startCell - O);
    curPlayer ^= 8;
    C120--;
    return (N + C10000*C10000 && (N > 1924-K | d)) ? N : 0;
  }

  curPlayer = pawn2SquareMove = 0;

  function SetupChessboard() {
    var x, y;
    var i = 0;
    var initial = [
       5,  3,  4,  6,  2,  4,  3,  5,
       1,  1,  1,  1,  1,  1,  1,  1,
       9,  9,  9,  9,  9,  9,  9,  9,
      13, 11, 12, 14, 10, 12, 11, 13
    ];
    for (y=0; y<12; y++) {
      for (x=0; x<10; x++) {
        if (x<1 || y<2 || x>8 || y>9) {
          // outside
          board[y*10+x] = 7;
        } else if (y>=4 && y<=7) {
          // empty
          board[y*10+x] = 0;
        } else {
          // pieces
          board[y*10+x] = initial[i++] | 16;
        }
      }
    }
  }


  function DrawPieces() {
    moveFrom=moveTo;
    callbacks.drawCallback();
  }


  function triggerAI()
  {
    compute(0,0,0,21,pawn2SquareMove,2); // 2 = ply
    compute(0,0,0,21,pawn2SquareMove,1);
    clickLock=false;
  }

  var clickLock = false;

  function OnClick(fieldID) {
    if (clickLock)
      return;
    curPieceCode = (board[fieldID] ^ curPlayer) & C15;
    if (curPieceCode > 8) {
      // clicked on the own piece
      moveTo = fieldID;
      DrawPieces();
    } else if (moveFrom && curPieceCode<9) {
      // clicked on the opponent piece or empty space
      moveTo = fieldID;
      curPieceCode = board[moveFrom] & C15;
      // pawn promotion
      if ((curPieceCode & 7) == 1 & (moveTo < 29 | moveTo > 90))
        curPieceCode = ai.promotePawnTo ^ curPlayer;
      // verify player move and execute it
      var ret = compute(0,0,0,21,pawn2SquareMove,1);
      // Call A.I. after some delay
      if (curPlayer) {
        clickLock = true;
        setTimeout(triggerAI,250);
      }
    }
  }

  SetupChessboard();

  curPieceCode = 100;
  
  var callbacks = {
    drawCallback : function() {},
    aiCallback : function() {},
    OnClick : OnClick,
    board: board,
    promotePawnTo: promotePawnTo,
    getMoveFrom : function() {return moveFrom;}
  }
  return callbacks;

});

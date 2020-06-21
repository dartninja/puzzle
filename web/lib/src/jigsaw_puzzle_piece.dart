import 'dart:math';

import 'package:web/src/jigsaw_puzzle.dart';
import 'package:web/src/jigsaw_puzzle_piece_side.dart';
import 'package:web/src/jigsaw_puzzle_piece_side_type.dart';

class JigsawPuzzlePiece {
  List<JigsawPuzzlePieceSide> sides = List<JigsawPuzzlePieceSide>(4);

  static final Random _rand = Random();

  JigsawPuzzlePiece(JigsawPuzzle puzzle, int x, int y) {
    JigsawPuzzlePieceSide side;
    if(y==0) {
      side = JigsawPuzzlePieceSide(JigsawPuzzlePieceSideType.Flat, true);
    } else {
      var upperPieceLowerSide = puzzle.pieces[x][y-1].sides[2];
      side = JigsawPuzzlePieceSide(upperPieceLowerSide.type, !upperPieceLowerSide.inverted);
    }
    sides[0] = side;

    if(puzzle.width==x+1) {
      side = JigsawPuzzlePieceSide(JigsawPuzzlePieceSideType.Flat, true);
    } else {
      side = JigsawPuzzlePieceSide(JigsawPuzzlePieceSideType.Curvy1, _rand.nextBool());
    }
    sides[1] = side;

    if(puzzle.height==y+1) {
      side = JigsawPuzzlePieceSide(JigsawPuzzlePieceSideType.Flat, true);
    } else {
      side = JigsawPuzzlePieceSide(JigsawPuzzlePieceSideType.Curvy1, _rand.nextBool());
    }
    sides[2] = side;

    if(x==0) {
      side = JigsawPuzzlePieceSide(JigsawPuzzlePieceSideType.Flat, true);
    } else {
      var leftPieceRightSide = puzzle.pieces[x-1][y].sides[1];
      side = JigsawPuzzlePieceSide(leftPieceRightSide.type, !leftPieceRightSide.inverted);
    }
    sides[3] = side;
  }
}
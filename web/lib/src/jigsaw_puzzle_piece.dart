import 'dart:math';

import 'package:web/src/jigsaw_puzzle.dart';
import 'package:web/src/jigsaw_puzzle_piece_side.dart';
import 'package:web/src/jigsaw_puzzle_piece_side_type.dart';

class JigsawPuzzlePiece {
  final List<JigsawPuzzlePieceSide> sides = List<JigsawPuzzlePieceSide>(4);

  final JigsawPuzzle puzzle;

  static final Random _rand = Random();
  int sourceOffsetX, sourceOffsetY, sourceHeight, sourceWidth;
  Point piece;
  int get index => (piece.x * puzzle.height) + piece.y;
  num displayOffsetX, displayOffsetY;
  bool selected = false;
  int zIndex;

  Rectangle _sourceRectangle, _displayRectangle;
  Rectangle get sourceRectangle => _sourceRectangle ??=
      Rectangle(sourceOffsetX, sourceOffsetY, sourceWidth, sourceHeight);
  Rectangle get displayRectangle => _displayRectangle ??=
      Rectangle(displayOffsetX, displayOffsetY, sourceWidth, sourceHeight);

  JigsawPuzzlePiece get leftNeighbor => piece.x > 0 ? puzzle.pieces[index - 1] : null;
  JigsawPuzzlePiece get rightNeighbor =>
      piece.x < puzzle.width ? puzzle.pieces[index + 1] : null;
  JigsawPuzzlePiece get topNeighbor =>
      piece.y > 0 ? puzzle.pieces[index - puzzle.width] : null;
  JigsawPuzzlePiece get bottomNeighbor =>
      piece.y < puzzle.height ? puzzle.pieces[index + puzzle.width] : null;

  JigsawPuzzlePiece(this.puzzle, this.piece,
      {int offsetX = -1, int offsetY = -1}) {
    sourceWidth = (puzzle.imageWidth / puzzle.width).floor();
    sourceHeight = (puzzle.imageHeight / puzzle.height).floor();
    sourceOffsetX = (sourceWidth * piece.x).floor();
    sourceOffsetY = (sourceHeight * piece.y).floor();
    zIndex = index;

    if (offsetX == -1) {
      displayOffsetX = sourceOffsetX;
    } else {
      displayOffsetX = offsetX;
    }
    if (offsetY == -1) {
      displayOffsetY = sourceOffsetY;
    } else {
      displayOffsetY = offsetY;
    }
  }
  bool containsPoint(Point p)=>
      displayRectangle.containsPoint(p);

}

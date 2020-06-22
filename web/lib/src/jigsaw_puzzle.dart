import 'dart:math';

import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';

import 'jigsaw_puzzle_piece.dart';

class JigsawPuzzle {
  static final Logger _logger = Logger('JigsawPuzzle');
  final int imageWidth, imageHeight;
  int width, height, count;
  num aspect;
  List<JigsawPuzzlePiece> pieces;
  JigsawPuzzlePiece selectedPiece;

  JigsawPuzzle(this.count, this.imageWidth, this.imageHeight)
   {
  aspect = imageWidth/imageHeight;
  if (count > 5000) {
      throw Exception('Puzzles limited to 5000 pieces');
    }
    _logger.info('Generating puzzle with $count pieces and $aspect ratio');
    num calcWidth = 0, calcHeight = 0;
    while (calcWidth * calcHeight < count) {
      calcHeight += 1;
      calcWidth += aspect;
    }
    width = calcWidth.floor();
    height = calcHeight.floor();
    count = width * height;
    pieces = <JigsawPuzzlePiece>[];
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        var piece = JigsawPuzzlePiece(this, Point(x, y));
        pieces.add(piece);
      }
    }
  }
  JigsawPuzzlePiece findPiece(Point p) {
    JigsawPuzzlePiece candidate;
    for(var piece in pieces) {
      if(piece.zIndex>(candidate?.zIndex??0) && piece.containsPoint(p)) {
        candidate = piece;
      }
    }
    return candidate;
  }

  void selectPieceAt(Point p) {
    selectedPiece = findPiece(p);
    var selectedIndex = -1;
    if(selectedPiece!=null) {
      if(selectedPiece.selected) {
        return;
      }
      selectedIndex = selectedPiece.index;
    }

    for(var i = 0; i < pieces.length; i++) {
      pieces[i].selected = pieces[i].index==selectedIndex;
    }
  }

  void bringPieceToTop(JigsawPuzzlePiece piece) {
    pieces.remove(piece);
    pieces.add(piece);
  }

}

import 'package:logging/logging.dart';

import 'jigsaw_puzzle_piece.dart';

class JigsawPuzzle {
  static final Logger _logger = Logger('JigsawPuzzle');
  int width, height, count;
  final num aspect;
  List<List<JigsawPuzzlePiece>> pieces;

  JigsawPuzzle(this.count, this.aspect) {
    if (count > 5000) {
      throw Exception('Puzzles limited to 5000 pieces');
    }
    _logger.info('Generating puzzle with $count pieces');
    num calcWidth = 0, calcHeight = 0;
    while (calcWidth * calcHeight < count) {
      calcHeight += 1;
      calcWidth += aspect;
    }
    width = calcWidth.floor();
    height = calcHeight.floor();
    count = width * height;
    pieces = List<List<JigsawPuzzlePiece>>(width);
    for (var x = 0; x < width; x++) {
      var column = List<JigsawPuzzlePiece>(height);
      pieces[x] = column;
      for (var y = 0; y < height; y++) {
        var piece = JigsawPuzzlePiece(this, x, y);
        pieces[x][y] = piece;
      }
    }
  }

  void setPiece(int x, int y, JigsawPuzzlePiece piece) {
    if (pieces[x] == null) {
      pieces[x] = <JigsawPuzzlePiece>[];
    }
    pieces[x][y] = piece;
  }
}

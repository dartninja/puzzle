import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';
import 'package:web/src/jigsaw_puzzle_piece.dart';
import 'package:web/src/jigsaw_puzzle_piece_side.dart';
import 'package:web/src/side.dart';
import 'package:web/src/jigsaw_puzzle_piece_side_type.dart';
import '../jigsaw_puzzle.dart';

@Component(
  selector: 'jigsaw-puzzle',
  styleUrls: ['jigsaw_puzzle_component.css'],
  templateUrl: 'jigsaw_puzzle_component.html',
  directives: [MaterialSliderComponent],
  providers: [],
)
class JigsawPuzzleComponent implements OnInit {
  static final Logger _logger = Logger('JigsawPuzzleComponent');

  @ViewChild('canvas')
  html.CanvasElement canvas;
  @ViewChild('image')
  html.ImageElement image;

  JigsawPuzzle _puzzle;
  num _pieceWidth, _pieceHeight, _verticalBorder, _horizontalBorder;
  int currentZ;

  num _zoom = 1;
  num get zoom => _zoom;
  set zoom(num value) {
    num scale = value / _zoom;
    _zoom = value;
  }
  num viewOffsetX = 0, viewOffsetY = 0;

  @override
  Future<Null> ngOnInit() async {
    image.onLoad.first.then((value) {
      _puzzle = JigsawPuzzle(5000, image.width, image.height);
      canvas.onMouseMove.listen((e) {
        var point = this.getMousePosition(e);
        _puzzle.selectPieceAt(point);
      });

      renderloop(0);
    });
  }

  int frameCount = 0;

  void renderloop(num t) {
    canvas.width = html.window.innerWidth;
    canvas.height = html.window.innerHeight;

    var context = canvas.context2D;

    context.fillStyle = "black";
    context.fillRect(0, 0, canvas.width, canvas.height);

    for(var piece in _puzzle.pieces) {
      var sourceRect = piece.sourceRectangle;
      var destRect = piece.displayRectangle;

      context.drawImageToRect(image, destRect, sourceRect: sourceRect);
    }
    context.strokeStyle = "black";
    for(var piece in _puzzle.pieces.where((e) => !e.selected)) {
      var destRect = piece.displayRectangle;
      context.strokeRect(destRect.left, destRect.top, destRect.width, destRect.height);
    }
    context.strokeStyle = "white";
    for(var piece in _puzzle.pieces.where((e) => e.selected)) {
      var destRect = piece.displayRectangle;
      context.strokeRect(destRect.left, destRect.top, destRect.width, destRect.height);
    }

    context.font = "30px Arial";
    context.strokeStyle = "green";
    context.fillText(frameCount.toString(), 100, 100);
    frameCount++;

    html.window.requestAnimationFrame(renderloop);

  }

  Point getMousePosition(html.MouseEvent e) {
    var canvasRect = canvas.getBoundingClientRect();
    return Point(e.client.x - canvasRect.left,
        e.client.y - canvasRect.top);
  }
//  Graphics generateMask(JigsawPuzzlePiece piece) {
//    var mask = Graphics();
//    mask.beginPath();
//    mask.moveTo(0, 0);
//
//    drawMaskSide(mask, Side.Top, piece.sides[0]);
//    drawMaskSide(mask, Side.Right, piece.sides[1]);
//    drawMaskSide(mask, Side.Bottom, piece.sides[2]);
//    drawMaskSide(mask, Side.Left, piece.sides[3]);
//
//    mask.closePath();
//
//    return mask;
//  }
//
//  void drawMaskSide(Graphics graphic, Side direction, JigsawPuzzlePieceSide side) {
//    switch(direction) {
//      case Side.Top:
//        graphic.lineTo(_pieceWidth, 0);
//        break;
//      case Side.Right:
//        graphic.lineTo(_pieceWidth, _pieceHeight);
//        break;
//      case Side.Bottom:
//        graphic.lineTo(0, _pieceHeight);
//        break;
//      case Side.Left:
//        graphic.lineTo(0, 0);
//        break;
//    }
//
//
//    switch(side.type) {
//      case JigsawPuzzlePieceSideType.Flat:
//
//        break;
//      case JigsawPuzzlePieceSideType.Curvy1:
//        break;
//      default:
//        throw Exception('Side type not supported');
//    }
//  }

}

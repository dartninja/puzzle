import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';
import 'package:vector_math/vector_math_lists.dart';
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
  Point viewOffset = Point(0,0);

  @override
  Future<Null> ngOnInit() async {
    image.onLoad.first.then((value) async {
      startRenderer();
    });
  }

  void startRenderer() {
    _puzzle = JigsawPuzzle(100, image.width, image.height);
    canvas.onMouseMove.listen(mouseMove);
    canvas.onMouseWheel.listen(mouseWheel);
    canvas.onMouseDown.listen(mouseDown);
    canvas.onMouseUp.listen(mouseUp);

    _zoom = min(html.window.innerWidth / image.width, html.window.innerHeight / image.height);

    renderLoop(0);
  }

  var draggingPiece = false;

  void mouseDown(html.MouseEvent e) {
    if(_puzzle.selectedPiece!=null) {
      draggingPiece = true;
      _puzzle.bringPieceToTop(_puzzle.selectedPiece);
    }
  }

  void mouseUp(html.MouseEvent e) {
    draggingPiece = false;
  }

  void mouseMove(html.MouseEvent e) {
    if(draggingPiece) {
      // TODO: Get the piece offset
      var piece = _puzzle.selectedPiece;
      piece.displayOffset = unScalePoint(e.offset);

    } else {
      var point = getMousePosition(e);
      _puzzle.selectPieceAt(point);
    }
  }

  void mouseWheel(html.WheelEvent e) {
    var scalechange = e.deltaY * -0.001;
    _zoom += scalechange;

    viewOffset = html.Point(
      viewOffset.x + -(e.offset.x * scalechange),
      viewOffset.y + -(e.offset.y * scalechange)
    );
  }

  int frameCount = 0;

  void renderLoop(num t) {
    canvas.width = html.window.innerWidth;
    canvas.height = html.window.innerHeight;

    var context = canvas.context2D;
    context.fillStyle = "black";
    context.fillRect(0, 0, canvas.width, canvas.height);
    context.scale(_zoom, _zoom);
    context.translate(viewOffset.x, viewOffset.y);

    var canvasRectangle = Rectangle(viewOffset.x, viewOffset.y, canvas.width * _zoom, canvas.height * _zoom);

    context.fillStyle = "gray";
    context.fillRect(0, 0, _puzzle.imageWidth*_zoom, _puzzle.imageHeight*_zoom);

    var drawCalls = 2;
    var startTime = DateTime.now();

    for(var piece in _puzzle.pieces) {
      var destRect = piece.displayRectangle;

      if(canvasRectangle.intersects(destRect)) {
        var sourceRect = piece.sourceRectangle;
        context.drawImageToRect(image, destRect, sourceRect: sourceRect);
        drawCalls++;
      }
    }
//    context.strokeStyle = "black";
//    for(var piece in _puzzle.pieces.where((e) => !e.selected)) {
//      var destRect = piece.displayRectangle;
//      if(canvasRectangle.intersects(destRect)) {
//        context.strokeRect(
//            destRect.left, destRect.top, destRect.width, destRect.height);
//        drawCalls++;
//      }
//    }
    if(_puzzle.selectedPiece!=null) {
      context.strokeStyle = "white";
      var destRect = _puzzle.selectedPiece.displayRectangle;
      context.strokeRect(destRect.left, destRect.top, destRect.width, destRect.height);
      drawCalls++;
    }

    context.scale(1, 1);
    context.translate(-viewOffset.x,-viewOffset.y);

    context.font = "30px Arial";
    context.fillStyle = "green";
    drawCalls += 3;
    context.fillText('Draw Calls: ${drawCalls}', 100, 100);
    context.fillText('Frame Count: ${frameCount}', 100, 130);
    var renderTime = DateTime.now().millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
    context.fillText('Render Time: ${renderTime}', 100, 160);
    frameCount++;

    html.window.requestAnimationFrame(renderLoop);

  }

//  Point scalePoint(Point p) {
//    return Point(p.x * _zoom,p.y * _zoom);
//  }
  Point unScalePoint(Point p) {
    return Point((p.x / _zoom) - viewOffset.x, (p.y / _zoom) - viewOffset.y );
  }
//
//  Rectangle scaleRectangle(Rectangle r) {
//    return Rectangle(r.left * _zoom,r.top * _zoom,r.width * _zoom,r.height * _zoom);
//  }


  Point getMousePosition(html.MouseEvent e) {
    var canvasRect = canvas.getBoundingClientRect();
    return unScalePoint(Point(e.client.x - canvasRect.left,
        e.client.y - canvasRect.top));
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

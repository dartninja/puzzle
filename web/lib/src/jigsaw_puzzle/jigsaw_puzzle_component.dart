import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:stagexl/stagexl.dart';
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
  @ViewChild('canvas')
  html.CanvasElement canvas;

  Stage _stage;
  JigsawPuzzle _puzzle;
  num _pieceWidth, _pieceHeight, _verticalBorder, _horizontalBorder;
  int currentZ;

  final List<Sprite> _sprites = <Sprite>[];

  num _zoom = 1;

  num get zoom => _zoom;
  set zoom(num value) {
    num scale = value / _zoom;
    //_stage.setTransform(0, 0, _zoom, _zoom);
    setScale(_zoom);
//    _stage.transformationMatrix.scale(scale,scale);
    _zoom = value;
  }


  @override
  Future<Null> ngOnInit() async {
    var options = StageOptions()
      ..backgroundColor = Color.White
      ..stageScaleMode = StageScaleMode.NO_SCALE
      ..stageAlign = StageAlign.TOP_LEFT
      ..renderEngine = RenderEngine.WebGL;

    _stage = Stage(canvas, width: 100, height: 100, options: options);

    var renderLoop = RenderLoop();
    renderLoop.addStage(_stage);

    var resourceManager = ResourceManager();
    resourceManager.addBitmapData('dart', 'images/dart@1x.png');
    resourceManager.addBitmapData('jigsaw', 'images/jigsaw.webp');

    await resourceManager.load();

    var jigsawBitmapData = resourceManager.getBitmapData('jigsaw');
    _puzzle =
        JigsawPuzzle(2000, jigsawBitmapData.width / jigsawBitmapData.height);

    _pieceWidth = jigsawBitmapData.width / _puzzle.width;
    _pieceHeight = jigsawBitmapData.height / _puzzle.height;
    _verticalBorder = (_pieceHeight  / 4).floor();
    _horizontalBorder = (_pieceWidth  / 4).floor();
    var spacing = 5;
    currentZ = _puzzle.count;

    for (var x = 0; x < _puzzle.width; x++) {
      for (var y = 0; y < _puzzle.height; y++) {
        var piece = _puzzle.pieces[x][y];

        var sprite = Sprite();
        var spriteBitmap = Bitmap(jigsawBitmapData);
//        spriteBitmap.bounds = Rectangle(
//            x * _pieceWidth - _horizontalBorder,
//            y * _pieceHeight - _verticalBorder,
//            _pieceWidth + _horizontalBorder * 2,
//            _pieceHeight + _verticalBorder * 2);

        sprite.addChild(spriteBitmap);
        sprite.pivotX = (_pieceWidth + _horizontalBorder * 2) / 2;
        sprite.pivotY = (_pieceHeight + _verticalBorder * 2) / 2;
        sprite.x = x * _pieceWidth;
        sprite.y = y * _pieceHeight;
        sprite.width = _pieceWidth;
        sprite.height = _pieceHeight;

        var mask = generateMask(piece);
    //    sprite.mask  = Mask.circle(sprite.pivotX, sprite.pivotY, _pieceWidth);
        //        sprite.mask = Mask.graphics(mask);

//        sprite.graphics = mask;
  //      sprite.graphics.strokeColor(Color.Blue, 5);

        sprite.onMouseDown.listen(moveStart);
        sprite.onTouchBegin.listen(moveStart);
        sprite.onMouseUp.listen(moveEnd);
        sprite.onTouchEnd.listen(moveEnd);

        _sprites.add(sprite);
        _stage.addChild(sprite);
      }
    }

    var logoData = resourceManager.getBitmapData('dart');
    var logo = Sprite();
    logo.addChild(Bitmap(logoData));

    logo.pivotX = logoData.width / 2;
    logo.pivotY = logoData.height / 2;

    // Place it at top center.
    logo.x = 1280 / 2;
    logo.y = 0;

    _stage.addChild(logo);

    // And let it fall.
    var tween = _stage.juggler.addTween(logo, 3, Transition.easeOutBounce);
    tween.animate.y.to(800 / 2);

    // Add some interaction on mouse click.
    Tween rotation;
    logo.onMouseClick.listen((MouseEvent e) {
      // Don't run more rotations at the same time.
      if (rotation != null) return;
      rotation = _stage.juggler.addTween(logo, 0.5, Transition.easeInOutCubic);
      rotation.animate.rotation.by(2 * pi);
      rotation.onComplete = () => rotation = null;

    });
    logo.mouseCursor = MouseCursor.POINTER;

    // See more examples:
    // https://github.com/bp74/StageXL_Samples
  }
  void moveStart(InputEvent event) {
    Sprite sprite = event.target;
    _stage.setChildIndex(sprite, _puzzle.count);
    sprite.startDrag(true);

  }

  void moveEnd(event) {
    Sprite sprite = event.target;
    sprite.stopDrag();
  }

  void setScale(num scale) {
    for(var sprite in _sprites) {
      sprite.scaleY = scale;
      sprite.scaleX = scale;
    }
  }

  Graphics generateMask(JigsawPuzzlePiece piece) {
    var mask = Graphics();
    mask.beginPath();
    mask.moveTo(0, 0);

    drawMaskSide(mask, Side.Top, piece.sides[0]);
    drawMaskSide(mask, Side.Right, piece.sides[1]);
    drawMaskSide(mask, Side.Bottom, piece.sides[2]);
    drawMaskSide(mask, Side.Left, piece.sides[3]);

    mask.closePath();

    return mask;
  }

  void drawMaskSide(Graphics graphic, Side direction, JigsawPuzzlePieceSide side) {
    switch(direction) {
      case Side.Top:
        graphic.lineTo(_pieceWidth, 0);
        break;
      case Side.Right:
        graphic.lineTo(_pieceWidth, _pieceHeight);
        break;
      case Side.Bottom:
        graphic.lineTo(0, _pieceHeight);
        break;
      case Side.Left:
        graphic.lineTo(0, 0);
        break;
    }


    switch(side.type) {
      case JigsawPuzzlePieceSideType.Flat:

        break;
      case JigsawPuzzlePieceSideType.Curvy1:
        break;
      default:
        throw Exception('Side type not supported');
    }
  }

}

package trilateral3.drawing;
import justPath.IPathContext;
import trilateral3.math.Algebra;
import trilateral3.drawing.Contour;
typedef Dim = {
    var minX: Float;
    var maxX: Float;
    var minY: Float;
    var maxY: Float;
}
class Sketch implements IPathContext {
    var x:                          Float = 0.;
    var y:                          Float = 0.;
    public var width:               Float = 0.01;
    public var widthFunction:       Float->Float->Float->Float->Float->Float;
    public var colourFunction:      Int->Float->Float->Float->Float->Int;
    var tempArr:                    Array<Float>;
    public var contour:             Contour;
    var pen:                        Pen;
    var endLine:                    StyleEndLine;
    var sketchForm:                 StyleSketch;
    public var points:              Array<Array<Float>>;
    public var pointsClock:         Array<Array<Float>>;
    public var pointsAnti:          Array<Array<Float>>;
    public var dim:                 Array<Dim>;
    inline function tracerLine( x_: Float, y_: Float ){
        trace( 'lineTo( $x, $y, $x_, $y_, width )' );
    }
    inline function fillOnlyLine( x_: Float, y_: Float ){
    }
    function baseLine( x_: Float, y_: Float ) {
        tracerLine( x_, y_ );
        crudeLine( x_, y_ );
    }
    inline function crudeLine( x_: Float, y_: Float ){
        contour.line( x, y, x_, y_, width );
    }
    inline function roundEndLine( x_: Float, y_: Float ){
        contour.line( x, y, x_, y_, width, both );
    }
    inline function mediumLine( x_: Float, y_: Float ){
        contour.triangleJoin( x, y, x_, y_, width, false );
    }
    inline function mediumOverlapLine(x_: Float, y_: Float ){
        contour.triangleJoin( x, y, x_, y_, width, false, true );
    }
    inline function fineLine( x_: Float, y_: Float ){
        contour.triangleJoin( x, y, x_, y_, width, true );
    }
    inline function fineOverlapLine( x_: Float, y_: Float ){
        contour.triangleJoin( x, y, x_, y_, width, true, true );
    }
    public var line: ( x: Float, y: Float ) -> Void;
    public
    function new( pen_: Pen,  sketchForm_: StyleSketch, endLine_: StyleEndLine = no ){
        contour    = new Contour( pen_, endLine_ );
        pen        = pen_;
        endLine    = endLine_;
        sketchForm = sketchForm_;
        switch( sketchForm_ ){
            case Tracer:        line = tracerLine;
            case Base:          line = baseLine;
            case Crude:         line = crudeLine;
            case FillOnly:      line = fillOnlyLine;
            case Fine:          line = fineLine;
            case FineOverlap:   line = fineOverlapLine;
            case Medium:        line = mediumLine;
            case MediumOverlap: line = mediumOverlapLine;
            case RoundEnd:      line = roundEndLine;
        }
        points = [];
        pointsClock = [];
        pointsAnti = [];
        points[0] = new Array<Float>();
        dim = new Array<Dim>();
    }
    public static inline
    function create( drawType_: DrawAbstract
                   , colorType_: ColorAbstract
                   , sketchForm_: StyleSketch
                   , endLine_: StyleEndLine = no ){
        @:privateAccess
        var pen = new Pen( drawType_, colorType_ );
        return new Sketch( pen, sketchForm_, endLine_ );
    }
    // TODO: reset pen? reset Contour instead?
    public function reset(){
        // pen.reset?
        contour = new Contour( pen, endLine );
        points = [];
        pointsClock = [];
        pointsAnti = [];
        points[0] = new Array<Float>();
        dim = new Array<Dim>();
    }
    public function pointsNoEndOverlap(): Array<Array<Float>> {
        var p: Array<Float>;
        var l: Int;
        var j = 0;
        var pointsClean = new Array<Array<Float>>();
        for( i in 0...points.length ){
            p = points[ i ];
            if( p.length > 2 ) pointsClean[ j++ ] = p; // remove empty arrays by only storing full ones.
        }
        points = pointsClean;
        for( i in 0...points.length ){
            p = points[ i ];
            l = p.length;
            var repeat = ( p[ 0 ] == p[ l - 2 ] && p[ 1 ] == p[ l - 1 ] );
            if( repeat ){
                points[ i ].pop();
                points[ i ].pop();
                l -= 2;
            }
            /*  Possible functionality for correcting anti-clockwise 
            var cc = 0.;
            var k = 0;
            var x1: Float;
            var y1: Float;
            var x2: Float;
            var y2: Float;
            var last = l-2;
            while( k < l ){
                x1 = p[ k ];
                y1 = p[ k + 1 ];
                if( k == last ){
                    x2 = p[ 0 ];
                    y2 = p[ 1 ];
                } else {
                    x2 = p[ k + 2 ];
                    y2 = p[ k + 3 ];
                }
                cc += ( x2 - x1 ) * ( y2 + y1 ); //(x1 * y2 - x2 * y1)
                k += 2;
            }
            var reverse = cc < 0;
            trace( ' reverse ' + cc  );
            if( reverse ){
                trace( 'reversing points for shape number ' + i  );
                k = 0;
                while( k < l ){
                    x1 = p[ k ];
                    p[ k ] = p[ k + 1 ];
                    p[ k + 1 ] = x1;
                }
            }*/
        }
        return points;
    }
    public function pointsRewound(): Array<Array<Float>> {
        var p: Array<Float>;
        var l: Int;
        var j = 0;
        var pointsClean = new Array<Array<Float>>();
        for( i in 0...points.length ){
            p = points[ i ];
            if( p.length > 2 ) pointsClean[ j++ ] = p; // remove empty arrays by only storing full ones.
        }
        points = pointsClean;
        
        for( i in 0...points.length ){
            p = points[ i ];
            l = p.length;
            
            var repeat = ( p[ 0 ] == p[ l - 2 ] && p[ 1 ] == p[ l - 1 ] );
            if( repeat ){
                points[ i ].pop();
                points[ i ].pop();
                l -= 2;
            }
            
            var cc = 0.;
            var k = 0;
            var x1: Float;
            var y1: Float;
            var x2: Float;
            var y2: Float;
            var last = l-2;
            while( k < l ){
                x1 = p[ k ];
                y1 = p[ k + 1 ];
                if( k == last ){
                    x2 = p[ 0 ];
                    y2 = p[ 1 ];
                } else {
                    x2 = p[ k + 2 ];
                    y2 = p[ k + 3 ];
                }
                cc += ( x2 - x1 ) * ( y2 + y1 ); //(x1 * y2 - x2 * y1)
                k += 2;
            }
            /*
            var reverse = cc > 0;
            if( reverse ){
                k = 0;
                while( k < l ){
                    x1 = p[ k ];
                    p[ k ] = p[ k + 1 ];
                    p[ k + 1 ] = x1;
                    k += 2;
                }
            }
            
            p.reverse();*/
            points[ i ] = p;
        }
        return points;
    }
    
    inline function initDim(): Dim{
        return { minX: Math.POSITIVE_INFINITY, maxX: Math.NEGATIVE_INFINITY, minY: Math.POSITIVE_INFINITY, maxY: Math.NEGATIVE_INFINITY };
    }
    inline function updateDim( x: Float, y: Float ){
        var d = dim[ dim.length - 1 ];
        if( x < d.minX ) d.minX = x;
        if( x > d.maxX ) d.maxX = x;
        if( y < d.minY ) d.minY = y;
        if( y > d.maxY ) d.maxY = y;
    }
    public function moveTo( x_: Float, y_: Float ): Void {
        if( endLine == end || endLine == both ) contour.end( width );
        x = x_;
        y = y_;
        var l = points.length;
        points[ l ] = new Array<Float>();
        points[ l ][0] = x_;
        points[ l ][1] = y_;
        //if( contour.pointsClock.length != 0 ) {
            // contour.endEdges();
            pointsClock[ pointsClock.length ] = contour.pointsClock.copy();
            pointsAnti[ pointsAnti.length ] = contour.pointsAnti.copy();
            //}
        dim[ dim.length ] = initDim();
        updateDim( x_, y_ );
        contour.reset(); // TODO: needs improving
    }
    public inline
    function lastClock(){
        if( contour.pointsClock.length != 0 ) {
            // contour.endEdges();
            pointsClock[ pointsClock.length ] = contour.pointsClock.copy();
            pointsAnti[ pointsAnti.length ] = contour.pointsAnti.copy();
        }
        // contour.reset();?
    }
    // collates edges
    public inline
    function getEdges(): Array<Array<Float>> {
        var edges = new Array<Array<Float>>();// ideally consider sizing this?
        var no    = pointsClock.length;
        if( no > pointsAnti.length ) no = pointsAnti.length;
        var pClock: Array<Float>;
        var pAnti:  Array<Float>;
        var shape:  Array<Float>;
        for( s in 0...no ){
            pClock      = pointsClock[ s ];
            pAnti       = pointsAnti[ s ];
            var lc      = pClock.length;
            var la      = pAnti.length;
            edges[ s ]  = new Array<Float>();// ideally consider sizing this? lc + la
            shape       = edges[ s ];
            for( i in 0...lc ) shape[ i ] = pClock[ i ];
            var j       = shape.length;
            var l5      = Std.int( la/2 );
            for( i in 0...l5 ){ // add in reverse order
                shape[ j + i*2 ]     = pAnti[ la - i*2 - 1 ]; // put x below y
                shape[ j + i*2 + 1 ] = pAnti[ la - i*2 ];
            }
            j = shape.length;
            shape[ j++ ] = pClock[ 0 ];  // join up would be better to put Anti on front?
            shape[ j   ] = pClock[ 1 ];
        }
        return edges;
    }
    public inline 
    function lineTo( x_: Float, y_: Float ): Void{
        var repeat = ( x == x_ && y == y_ ); // added for poly2tryhx it does not like repeat points!
        if( !repeat ){ // this does not allow dot's to be created using lineTo can move beyond lineTo if it seems problematic.
            if( widthFunction != null ) width = widthFunction( width, x, y, x_, y_ );
            if( colourFunction != null ) pen.currentColor = colourFunction( pen.currentColor, x, y, x_, y_ );
            line( x_, y_ ); 
            var l = points.length;
            var p = points[ l - 1 ];
            var l2 = p.length;
            p[ l2 ]     = x_;
            p[ l2 + 1 ] = y_;
            updateDim( x_, y_ );
            x = x_;
            y = y_;
        }
    }
    public inline
    function quadTo( x1: Float, y1: Float, x2: Float, y2: Float ): Void {
        tempArr = [];
        quadCurve( tempArr, x, y, x1, y1, x2, y2 );
        plotCoord( tempArr, false );
        x = x2;
        y = y2;
    }
    // x1,y1 is a point on the curve rather than the control point, taken from my divtatic project.
    public inline
    function quadThru( x1: Float, y1: Float, x2: Float, y2: Float ): Void {
        var newx = 2*x1 - 0.5*( x + x2 );
        var newy = 2*y1 - 0.5*( y + y2 );
        return quadTo( newx, newy, x2, y2 );
    }
    public inline
    function curveTo( x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float ): Void {
        tempArr = [];
        cubicCurve( tempArr, x, y, x1, y1, x2, y2, x3, y3 );
        plotCoord( tempArr, false );
        x = x3;
        y = y3;
    }
    public inline
    function plotCoord( arr: Array<Float>, ?withMove: Bool = true ): Void {
        var l = arr.length;
        var i = 2;
        if( withMove ){ // normally when just plotting points you will do it withMove but from a curve not.
            moveTo( arr[ 0 ], arr[ 1 ] );
        } else {
            lineTo( arr[ 0 ], arr[ 1 ] );
        }
        while( i < l ){
            lineTo( arr[ i ], arr[ i + 1 ] );
            i += 2;
        }
    }
}

package sandy.materials 
{
	import sandy.core.data.Polygon;
	import sandy.materials.Material;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	/**
	 * @author thomaspfeiffer
	 */
	public class ColorMaterial extends Material 
	{
		private var m_nColor:Number;
		private var m_nAlpha:Number;
		// --
		public function ColorMaterial( p_nColor:uint = 0, p_nAlpha:uint = 100, p_oLineAttr:LineAttributes = null )
		{
			super();
			m_nColor = p_nColor;
			m_nAlpha = p_nAlpha/100;
			// --
			lineAttributes = p_oLineAttr;
		}
		
		public override function renderPolygon( p_oPolygon:Polygon ):void 
		{
			var sprite:Shape = p_oPolygon.container;
			var l_points:Array = p_oPolygon.cvertices;
			var l_graphics:Graphics = sprite.graphics;
			// --
			l_graphics.beginFill( m_nColor, m_nAlpha);
			// --
			if( lineAttributes )
				l_graphics.lineStyle( lineAttributes.thickness, lineAttributes.color, lineAttributes.alpha );
			// --
			l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
			// --
			switch( l_points.length )
			{
				case 2:
					l_graphics.lineTo( l_points[1].sx, l_points[1].sy );
					l_graphics.lineTo( l_points[2].sx, l_points[2].sy );
					break;
				case 4 :
					l_graphics.lineTo( l_points[1].sx, l_points[1].sy );
					l_graphics.lineTo( l_points[2].sx, l_points[2].sy );
					l_graphics.lineTo( l_points[3].sx, l_points[3].sy );
					break;
				default :
					var l:Number = l_points.length;
					while( --l > 0 )
					{
						l_graphics.lineTo( l_points[(l)].sx, l_points[(l)].sy);
					}
					break;
			}
			// -- we draw the last edge
			if( lineAttributes )
			{
				l_graphics.lineTo( l_points[0].sx, l_points[0].sy );
			}
			// --
			l_graphics.endFill();
		}
		public function get alpha():Number
		{return m_nAlpha;}
		
		public function get color():Number
		{return m_nColor;}
	
		
		public function set alpha(p_nValue:Number):void
		{m_nAlpha = p_nValue; m_bModified = true;}
		
		public function set color(p_nValue:Number):void
		{m_nColor = p_nValue; m_bModified = true;}
	
	}
}
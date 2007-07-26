/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/
package sandy.primitive 
{
	import sandy.core.data.Polygon;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Geometry3D;
	import sandy.core.scenegraph.Shape3D;
	
       	/**
	 * Box is a primitive class for creating a cube or box ( cuboid ).
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 *
	 * @example To create a rectilinear box with ( z, y, z ) dimensions ( 50, 100, 150 ),
	 * created in 'tri' mode and a with a quality of 2, here is the statement:
	 *
	 * <listing version="3.0">
	 *     var myBox:Box = new Box( "theBox", 50, 100, 150, PrimitiveMode.TRI, 2 );
	 *  </listing>
	 */
	public class Box extends Shape3D implements Primitive3D
	{
		/**
		 * height of the Box
		 */ 
		private var _h	: Number;
		/**
		 * depth of the Box
		 */ 
		private var _lg : Number;
		/**
		 * width of the Box
		 */ 
		private var _radius : Number;
		/**
		 * creation quality
		 */ 		
		private var _q:Number;
		/**
		 * creation mode - number of vertices per face
		 */
		 private var _mode : String;
	
		
		/**
		 * Creates a Box primitive.
		 *
		 * <p>The constructor will create a complete object with vertices,
		 * normals, texture coordinates and faces.<br/>
		 * By default, the Box is created centered at the origin of the world coordinate system,
		 * and with its edges parallel to world coordinate axes.</p>
		 *
		 * @param name		a string identifier for this object
		 * @param width 	width of the Box  ( x direction )
		 * @param height	height of the Box ( y direction ) 
		 * @param depth		depth of the Box  ( z direction )
		 * @param mode 		one of two available face generation modes: 
		 *                      "tri" generates faces with 3 vertices, 
		 * 			"quad" generates faces with 4 vertices.
		 */
		public function Box ( name:String, width:Number=6, height:Number = 6, depth:Number = 6, mode:String = "tri", quality:Number=1)
		{
			super ( name );
			//
			_h = height;
			_lg = depth;
			_radius = width;
			_q = (quality <= 0 || quality > 10) ?  1 : quality ;
			_mode = ( mode != 'tri' && mode != 'quad' ) ? 'tri' : mode;
			geometry = generate();
		}
		
		/**
		 * Generates the geometry for this Shape3D
		 *
		 * @see sandy.core.data.Vertex
		 * @see sandy.core.data.UVCoord
		 * @see sandy.core.data.Polygon
		 */
		public function generate (... arguments) :Geometry3D
		{
			// initialisation
			var l_geometry:Geometry3D = new Geometry3D();
			
			//we build points
			var h2 : Number = - _h / 2;
			var r2 : Number = _radius / 2;
			var l2 : Number = _lg / 2;
	
	
			var l_nID0:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID0, -r2, -h2, l2 );
	
			var l_nID1:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID1, r2, -h2, l2 );
	
			var l_nID2:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID2, r2, h2, l2 );
	
			var l_nID3:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID3, -r2, h2, l2 );
	
			var l_nID4:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID4, -r2, -h2, -l2 );
	
			var l_nID5:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID5, r2, -h2, -l2 );
	
			var l_nID6:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID6, r2, h2, -l2 );
	
			var l_nID7:Number = l_geometry.getNextVertexID();
			l_geometry.setVertex( l_nID7, -r2, h2, -l2 );
			
			// -- we setup texture coordinates		
			l_geometry.setUVCoords( 0, 0, 0 );
			l_geometry.setUVCoords( 1, 1, 0 );
			l_geometry.setUVCoords( 2, 0, 1 );
			l_geometry.setUVCoords( 3, 1, 1 );
			// -- Faces creation
			
			//Front Face
			__tesselate(l_geometry,
						l_nID0, l_nID1, l_nID2, l_nID3,
						0, 2, 3, 1,
						_q - 1 );
			
			//Behind Face
			__tesselate(l_geometry,
						l_nID4, l_nID7, l_nID6, l_nID5,
						0, 2, 3, 1,
						_q - 1 );
			//Top Face
			__tesselate(l_geometry,
						l_nID2, l_nID6, l_nID7, l_nID3,
						0, 2, 3, 1,
						_q - 1 );
			//Bottom Face
			__tesselate(l_geometry,
						l_nID0, l_nID4, l_nID5, l_nID1,
						3, 1, 0, 2,
						_q - 1 );
			//Left Face
			__tesselate(l_geometry,
						l_nID0, l_nID3, l_nID7, l_nID4,
						0, 2, 3, 1,
						_q - 1 );
			//Right Face
			__tesselate(l_geometry,
						l_nID1, l_nID5, l_nID6, l_nID2,
						1, 0, 2, 3,
						_q - 1 );

			return l_geometry;
		}
		
		private function __tesselate( 	p_geometry:Geometry3D,
										p0:Number, p1:Number, p2:Number, p3:Number,
										uv0:Number, uv1:Number, uv2:Number, uv3:Number,
										level:Number):void
		{
			var l_geometry:Geometry3D = p_geometry;
			
			var f:Polygon;
			if(level == 0 ) // End of recurssion
			{
				// -- We have the same normal for 2 faces, be careful to don't add extra normal
				if( _mode == 'tri' )
				{
					//l_geometry.createFace( p0, p1, p3 );
					//l_geometry.addUVCoords( uv0, uv1, uv3 );
					l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), p0, p1, p3 );
					l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), uv0, uv1, uv3 );
					
					//l_geometry.createFace( p2, p3, p1 );
					//l_geometry.addUVCoords( uv2, uv3, uv1 );
					l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), p2, p3, p1 );
					l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), uv2, uv3, uv1 );
				}
				else if( _mode == 'quad' )
				{
					//l_geometry.createFace( p0, p1, p2, p3 );
					//l_geometry.addUVCoords( uv0, uv1, uv2 );
					l_geometry.setFaceVertexIds( l_geometry.getNextFaceID(), p0, p1, p2, p3 );
					l_geometry.setFaceUVCoordsIds( l_geometry.getNextFaceUVCoordID(), uv0, uv1, uv2 );
				}
			}
			else
			{
				var l_oVertex0:Vertex = l_geometry.aVertex[p0];
				var l_oVertex1:Vertex = l_geometry.aVertex[p1];
				var l_oVertex2:Vertex = l_geometry.aVertex[p2];
				var l_oVertex3:Vertex = l_geometry.aVertex[p3];
				//milieu de p0, p1;
				var l_nID01:Number = l_geometry.getNextVertexID();
				l_geometry.setVertex( l_nID01, (l_oVertex0.x+l_oVertex1.x)/2, (l_oVertex0.y+l_oVertex1.y)/2, (l_oVertex0.z+l_oVertex1.z)/2 );
				// milieu de p1 p2
				var l_nID12:Number = l_geometry.getNextVertexID();
				l_geometry.setVertex( l_nID12, (l_oVertex1.x+l_oVertex2.x)/2, (l_oVertex1.y+l_oVertex2.y)/2, (l_oVertex1.z+l_oVertex2.z)/2 );
				//var m12:Vertex = new Vertex( (l_oVertex1.x+l_oVertex2.x)/2, (l_oVertex1.y+l_oVertex2.y)/2, (l_oVertex1.z+l_oVertex2.z)/2 );
				// milieu de p2 p3
				var l_nID23:Number = l_geometry.getNextVertexID();
				l_geometry.setVertex( l_nID23, (l_oVertex2.x+l_oVertex3.x)/2, (l_oVertex2.y+l_oVertex3.y)/2, (l_oVertex2.z+l_oVertex3.z)/2 );
				//var m23:Vertex = new Vertex( (l_oVertex2.x+l_oVertex3.x)/2, (l_oVertex2.y+l_oVertex3.y)/2, (l_oVertex2.z+l_oVertex3.z)/2 );
				//l_geometry.addPoint(m23);
				// milieu de p3 p0
				var l_nID30:Number = l_geometry.getNextVertexID();
				l_geometry.setVertex( l_nID30, (l_oVertex3.x+l_oVertex0.x)/2, (l_oVertex3.y+l_oVertex0.y)/2, (l_oVertex3.z+l_oVertex0.z)/2 );
				//var m30:Vertex = new Vertex( (l_oVertex3.x+l_oVertex0.x)/2, (l_oVertex3.y+l_oVertex0.y)/2, (l_oVertex3.z+l_oVertex0.z)/2 );
				//l_geometry.addPoint(m30);
				// milieu tout court
				var l_nIDMiddle:Number = l_geometry.getNextVertexID();
				l_geometry.setVertex( l_nIDMiddle, (l_oVertex0.x+l_oVertex1.x+l_oVertex2.x+l_oVertex3.x)/4, (l_oVertex0.y+l_oVertex1.y+l_oVertex2.y+l_oVertex3.y)/4, (l_oVertex0.z+l_oVertex1.z+l_oVertex2.z+l_oVertex3.z)/4 );
				//var center:Vertex = new Vertex( (l_oVertex0.x+l_oVertex1.x+l_oVertex2.x+l_oVertex3.x)/4, (l_oVertex0.y+l_oVertex1.y+l_oVertex2.y+l_oVertex3.y)/4, (l_oVertex0.z+l_oVertex1.z+l_oVertex2.z+l_oVertex3.z)/4 );
				//l_geometry.addPoint(center);
				//l_geometry.addPoints( m01, m12, m23, m30, center );
				
				
				var l_oUV0:UVCoord = l_geometry.aUVCoords[uv0];
				var l_oUV1:UVCoord = l_geometry.aUVCoords[uv1];
				var l_oUV2:UVCoord = l_geometry.aUVCoords[uv2];
				var l_oUV3:UVCoord = l_geometry.aUVCoords[uv3];
				//milieu de p0, p1;
				l_geometry.setUVCoords( l_nID01, (l_oUV0.u+l_oUV1.u)/2, (l_oUV0.v+l_oUV1.v)/2);
				// milieu de p1 p2
				l_geometry.setUVCoords( l_nID12, (l_oUV1.u+l_oUV2.u)/2, (l_oUV1.v+l_oUV2.v)/2 );
				// milieu de p2 p3
				l_geometry.setUVCoords( l_nID23, (l_oUV2.u+l_oUV3.u)/2, (l_oUV2.v+l_oUV3.v)/2 );
				// milieu de p3 p0
				l_geometry.setUVCoords( l_nID30, (l_oUV3.u+l_oUV0.u)/2, (l_oUV3.v+l_oUV0.v)/2 );
				// milieu tout court
				l_geometry.setUVCoords( l_nIDMiddle, (l_oUV0.u+l_oUV1.u+l_oUV2.u+l_oUV3.u)/4, (l_oUV0.v+l_oUV1.v+l_oUV2.v+l_oUV3.v)/4);	
				
				__tesselate(l_geometry,
							l_nIDMiddle, l_nID30, p0, l_nID01,
							l_nIDMiddle, l_nID30, uv0, l_nID01,
							level - 1 );
				__tesselate(l_geometry,
							l_nIDMiddle, l_nID01, p1, l_nID12,
							l_nIDMiddle, l_nID01, uv1, l_nID12,
							level - 1 );
				
				__tesselate(l_geometry,
							l_nIDMiddle, l_nID12, p2, l_nID23,
							l_nIDMiddle, l_nID12, uv2, l_nID23,
							level - 1 );
				
				__tesselate(l_geometry,
							l_nIDMiddle, l_nID23, p3, l_nID30,
							l_nIDMiddle, l_nID23, uv3, l_nID30,
							level - 1 );
				
			}
		}
	}
}

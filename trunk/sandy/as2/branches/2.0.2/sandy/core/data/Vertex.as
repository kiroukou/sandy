﻿/*
# ***** BEGIN LICENSE BLOCK *****
Sandy is a software supplied by Thomas PFEIFFER
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 ( the "License" );
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

import sandy.util.NumberUtil;
import sandy.core.data.Vector;

/**
 * A vertex is the point of intersection of edges the of a polygon.
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		(porting) Floris - xdevltd
 * @since		1.0
 * @version		2.0.2
 * @date 		24.08.2007
 *
 * @see sandy.core.data.Polygon
 */
	
class sandy.core.data.Vertex
{
		
	private static var ID:Number = 0;
		
	/**
	 * The unique identifier for the vertex.
	 */
	public var id:Number;

	/**
	 * The x coordinate in the scene.
	 */
	public var x:Number;
		
	/**
	 * The y coordinate in the scene.
	 */
	public var y:Number;
		
	/**
	 * The z coordinate in the scene.
	 */
	public var z:Number;

	/**
	 * The transformed x coordinate in the scene.
	 */
	public var wx:Number;
	
	/**
	 * The transformed y coordinate in the scene.
	 */
	public var wy:Number;
	
	/**
	 * The transformed z coordinate in the scene.
	 */
	public var wz:Number;

	/**
	 * The transformed x coordinate on the screen.
	 */
	public var sx:Number;
		
	/**
	 * The transformed y coordinate on the screen.
	 */
	public var sy:Number;

	/**
	 * The number of polygons the vertex belongs to.
	 */
	public var nbFaces:Number;

	/**
	 * An array of polygons that use the vertex</p>
	 */
	public var aFaces:Array;

	/**
	* Creates a new vertex.
	*
	* @param p_nx		The x position.
	* @param p_ny		The y position.
	* @param p_nz		The z position.
	* @param ...rest	Optional values for the <code>wx</code>, <code>wy</code>, and <code>wz</code> properties.
	*/
	public function Vertex( p_nx:Number, p_ny:Number, p_nz:Number )
	{
		nbFaces = 0;
		aFaces = new Array();
		id = ID++;
		x = p_nx||0;
		y = p_ny||0;
		z = p_nz||0;
		// --
		wx = ( arguments[ 3 ] ) ? arguments[ 3 ] : x;
		wy = ( arguments[ 4 ] ) ? arguments[ 4 ] : y;
		wz = ( arguments[ 5 ] ) ? arguments[ 5 ] : z;
		// --
		sy = sx = 0;
		m_oWorld = new Vector();
		m_oLocal = new Vector();
	}
		
	/**
	 * Reset the values of that vertex.
	 * This allows to change all the values of that vertex in one method call instead of acessing to each public property.
	 *  @param p_nX Value for x and wx properties
	 *  @param p_nY Value for y and wy properties
	 *  @param p_nZ Value for z and wz properties
	 */
	public function reset( p_nX:Number, p_nY:Number, p_nZ:Number ) : Void
	{
		x = p_nX;
		y = p_nY;
		z = p_nZ;
		wx = x;
		wy = y;
		wz = z;
	}
		
	/**
	 * Returns the 2D position of this vertex.  The function returns a vector with the x and y coordinates of the
	 * vertex and the depth as the <code>z</code> property.
	 *
	 * @return The 2D position of this vertex once projected.
	 */
	public function getScreenPoint() : Vector
	{
		return new Vector( sx, sy, wz );
	}

	/**
	* Returns a vector of the transformed vertex.
	*
	* @return A vector of the transformed vertex.
	*/
	public function getWorldVector() : Vector
	{
		m_oWorld.x = wx;
		m_oWorld.y = wy;
		m_oWorld.z = wz;
		return m_oWorld;
	}

	/**
	 * Returns a vector representing the original x, y, z coordinates.
	 *
	 * @return A vector representing the original x, y, z coordinates.
	 */
	public function getVector() : Vector
	{
		m_oLocal.x = x;
		m_oLocal.y = y;
		m_oLocal.z = z;
		return m_oLocal;
	}

	/**
	 * Returns a new Vertex object that is a clone of the original instance. 
	 * 
	 * @return A new Vertex object that is identical to the original. 
	 */		
	public function clone() : Vertex
	{
	    var l_oV:Vertex = new Vertex( x, y, z );
	    l_oV.wx = wx;    l_oV.sx = sx;
	    l_oV.wy = wy;    l_oV.sy = sy;
	    l_oV.wz = wz;
	    l_oV.nbFaces = nbFaces;
	    l_oV.aFaces = aFaces.concat();
	    return l_oV;
	}

	/**
	 * Returns a new vertex build on the transformed values of this vertex.
	 *
	 * <p>Returns a new Vertex object that is created with the vertex's transformed coordinates as the new vertex's start position.
	 * The <code>x</code>, y</code>, and z</code> properties of the new vertex would be the <code>wx</code>, <code>wy</code>, <code>wz</code> properties of this vertex.</p>
	 * <p>[ <strong>ToDo</strong>: What can this one be used for? - Explain! ]</p>
	 *
	 * @return 	The new Vertex object.
	 */
	public function clone2() : Vertex
	{
	    return new Vertex( wx, wy, wz );
	}

	/**
	 * Creates and returns a new vertex from the specified vector.
	 *
	 * @param p_v	The vertex's position vector.
	 *
	 * @return 	The new vertex.
	 */
	public static function createFromVector( p_v:Vector ) : Vertex
	{
	    return new Vertex( p_v.x, p_v.y, p_v.z );
	}

	/**
	 * Determines if this vertex is equal to the specified vertex.
	 *
	 * <p>This all properties of this vertex is compared to the properties of the specified vertex.
	 * If all properties of the two vertices are equal, a value of <code>true</code> is returned.</p>
	 *
	 * @return Whether the two verticies are equal.
	 */
 	public function equals( p_vertex:Vertex ) : Boolean
	{
		return Boolean( p_vertex.x  ==  x && p_vertex.y  ==  y && p_vertex.z  ==  z &&
						p_vertex.wx == wx && p_vertex.wy == wy && p_vertex.wz == wz &&
						p_vertex.sx == wx && p_vertex.sy == sy );
	}

	/**
	 * Makes this vertex a copy of the specified vertex.
	 *
	 * <p>All components of the specified vertex are copied to this vertex.</p>
	 *
	 * @param p_oVector	The vertex to copy.
	 */
	public function copy( p_oVector:Vertex ) : Void
	{
		x = p_oVector.x;
		y = p_oVector.y;
		z = p_oVector.z;
		wx = p_oVector.wx;
		wy = p_oVector.wy;
		wz = p_oVector.wz;
		sx = p_oVector.sx;
		sy = p_oVector.sy;
	}

	/**
	 * Returns the norm of this vertex.
	 *
	 * <p>The norm of the vertex is calculated as the length of its position vector.
	 * The norm is calculated by <code>Math.sqrt( x*x + y*y + z*z )</code>.</p>
	 *
	 * @return 	The norm.
	 */
	public function getNorm() : Number
	{
		return Math.sqrt( x * x + y * y + z * z );
	}

	/**
	 * Inverts the vertex.  All properties of the vertex become their nagative values.
	 */
	public function negate( /*v:Vertex*/ ) :  Void
	{
		// The argument is commented out, as it is not used - Petit
		x = -x;
		y = -y;
		z = -z;
		wx = -wx;
		wy = -wy;
		wz = -wz;
		//return new Vertex( -x, -y, -z, -wx, -wy, -wz );
	}

	/**
	 * Adds a specified vertex to this vertex.
	 *
	 * @param v 	The vertex to add to this vertex
	 */
	public function add( v:Vertex ) : Void
	{
		x += v.x;
		y += v.y;
		z += v.z;

		wx += v.wx;
		wy += v.wy;
		wz += v.wz;
	}

	/**
	 * Substracts the specified vertex from this vertex.
	 *
	 * @param v 	The vertex to subtract from this vertex.
	 */
	public function sub( v:Vertex ) : Void
	{
		x -= v.x;
		y -= v.y;
		z -= v.z;
		wx -= v.wx;
		wy -= v.wy;
		wz -= v.wz;
	}

	/**
	 * Raises the vertex to the specified power.
	 *
	 * <p>All components of the vertex are raised to the specified power.</p>
	 *
	 * @param pow The power to raise the vertex to.
	 */
	public function pow( pow:Number ) : Void
	{
		x = Math.pow( x, pow );
       	y = Math.pow( y, pow );
       	z = Math.pow( z, pow );
       	wx = Math.pow( wx, pow );
       	wy = Math.pow( wy, pow );
       	wz = Math.pow( wz, pow );
	}

	/**
	 * Multiplies this vertex by the specified number.
	 *
	 * <p>All components of the vertex are multiplied by the specified number.</p>
	 *
	 * @param n 	The number to multiply the vertex with.
	 */
	public function scale( n:Number ) : Void
	{
		x *= n;
		y *= n;
		z *= n;
		wx *= n;
		wy *= n;
		wz *= n;
	}

	/**
	 * Returns the dot product between this vertex and the specified vertex.
	 *
	 * <p>Only the original positions values are used for this dot product.</p>
	 *
	 * @param w 	The vertex to make a dot product with.
	 *
	 * @return The dot product.
	 */
	public function dot( w: Vertex ) : Number
	{
		return ( x * w.x + y * w.y + z * w.z );
	}

	/**
	 * Returns the cross product between this vertex and the specified vertex.
	 *
	 * <p>Only the original positions values are used for this cross product.</p>
	 *
	 * @param v 	The vertex to make a cross product with.
	 *
	 * @return The resulting vertex of the cross product.
	 */
	public function cross( v:Vertex ) : Vertex
	{
		// cross product vector that will be returned
       		// calculate the components of the cross product
		return new Vertex( 	( y * v.z ) - ( z * v.y ) ,
                            ( z * v.x ) - ( x * v.z ) ,
                            ( x * v.y ) - ( y * v.x ) );
	}

	/**
	 * Normalizes this vertex.
	 *
	 * <p>A vertex is normalized when its components are divided by its norm.
	 * The norm is calculated by <code>Math.sqrt( x*x + y*y + z*z )</code>, which is the length of the position vector.</p>
	 */
	public function normalize() : Void
	{
		// -- We get the norm of the vector
		var norm:Number = getNorm();
		// -- We escape the process is norm is null or equal to 1
		if( norm == 0 || norm == 1 ) return;
		x /= norm;
		y /= norm;
		z /= norm;

		wx /= norm;
		wy /= norm;
		wz /= norm;
	}

	/**
	 * Returns the angle between this vertex and the specified vertex.
	 *
	 * @param w	The vertex making an angle with this one.
	 *
	 * @return 	The angle in radians.
	 */
	public function getAngle ( w:Vertex ) : Number
	{
		var ncos:Number = dot( w ) / ( getNorm() * w.getNorm() );
		var sin2:Number = 1 - ncos * ncos;
		if( sin2 < 0 )
		{
			trace( "Wrong: " + ncos );
			sin2 = 0;
		}
		//I took long time to find this bug. Who can guess that ( 1-cos*cos ) is negative ?!
		//sqrt returns a NaN for a negative value !
		return  Math.atan2( Math.sqrt( sin2 ), ncos );
	}

	/**
	 * Returns a string representation of this object.
	 *
	 * @param decPlaces	The number of decimal places to round the vertex's components off to.
	 *
	 * @return	The fully qualified name of this object.
	 */
	public function toString( decPlaces:Number ) : String
	{
		if( decPlaces == 0 || !decPlaces )
		{
			decPlaces = .01;
		}
		// Round display to two decimals places
		// Returns "{x, y, z}"
		return "{" +
				NumberUtil.roundTo( x, decPlaces ) + ", " +
				NumberUtil.roundTo( y, decPlaces ) + ", " +
				NumberUtil.roundTo( z, decPlaces ) + ", " +
				NumberUtil.roundTo( wx, decPlaces ) + ", " +
				NumberUtil.roundTo( wy, decPlaces ) + ", " +
				NumberUtil.roundTo( wz, decPlaces ) + ", " +
				NumberUtil.roundTo( sx, decPlaces ) + ", " +
				NumberUtil.roundTo( sy, decPlaces ) + "}";
	}

	// Useful for XML output
	/**
	 * Returns a string representation of this vertex with rounded values.
	 *
	 * <p>[ <strong>ToDo</strong>: Explain why this is good for XML output! ]</p>
	 *
	 * @param decPlaces	Number of decimals
	 * @return The specific serialize string
	 */
	public function serialize( decPlaces:Number ) : String
	{
		if( decPlaces == 0 || !decPlaces )
		{
			decPlaces = .01
		}
		//returns x,y,x
		return  ( NumberUtil.roundTo( x, decPlaces ) + "," +
				  NumberUtil.roundTo( y, decPlaces ) + "," +
				  NumberUtil.roundTo( z, decPlaces ) + "," +
				  NumberUtil.roundTo( wx, decPlaces ) + "," +
				  NumberUtil.roundTo( wy, decPlaces ) + "," +
				  NumberUtil.roundTo( wz, decPlaces ) + "," +
				  NumberUtil.roundTo( sx, decPlaces ) + "," +
				  NumberUtil.roundTo( sy, decPlaces ) );
	}

	// Useful for XML output
	/**
	 * Sets the elements of this vertex from a string representation.
	 *
	 * <p>[ <strong>ToDo</strong>: Explain why this is good for XML intput! ]</p>
	 *
	 * @param 	A string representing the vertex ( specific serialize format ).
	 */
	public function deserialize( convertFrom:String ) : Void
	{
		var tmp:Array = convertFrom.split( "," );
		if( tmp.length != 9 )
		{
			trace ( "Unexpected length of string to deserialize into a vector " + convertFrom );
		}

		x = tmp[ 0 ];
		y = tmp[ 1 ];
		z = tmp[ 2 ];

		wx = tmp[ 3 ];
		wy = tmp[ 4 ];
		wz = tmp[ 5 ];
			
		sx = tmp[ 6 ];
		sy = tmp[ 7 ];
	}
		
	private var m_oWorld:Vector;
	private var m_oLocal:Vector;
	
}

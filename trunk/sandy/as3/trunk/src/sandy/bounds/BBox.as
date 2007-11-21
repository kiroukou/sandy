﻿/*
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
package sandy.bounds 
{
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vector;
	
	/**
	 * The <code>BBox</code> object is used to clip the object faster.
	 * <p>It creates a bounding box that contains the whole object</p>
	 * 
	 * @example 	This example is taken from the Shape3D class. It is used in
	 * 				the <code>updateBoundingVolumes()</code> method:
 	 *
 	 * <listing version="3.0">
 	 *     _oBBox = BBox.create( m_oGeometry.aVertex );
 	 *  </listing>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		0.1
	 * @date 		22.03.2006
	 */
	public class BBox
	{
		/**
		 * Max vector, representing the upper point of the cube volume
		 */
		public var max:Vector;		
		
		/**
		 * Min vector, representing the lower point of the cube volume.
		 */
		public var min:Vector;		
	
		public var tmin:Vector;
		public var tmax:Vector;
		
		public var aCorners:Array;
		public var aTCorners:Array;
		
		/**
		 * Creates a bounding sphere that encloses a 3D object. This object's vertices are passed
		 * to the <code>create</code> method in the form of an <code>Array</code>. Very useful 
		 * for clipping and thus performance!
		 * 
		 * @param p_aVertices		The vertices of the 3D object
		 * @return 					A <code>BBox</code> instance
		 */		
		public static function create( p_aVertices:Array ):BBox
		{
			if(p_aVertices.length == 0) return null;
		   
		    var l:Number = p_aVertices.length;
		    var l_min:Vector = new Vector();
		    var l_max:Vector = new Vector();
			
			var lTmp:Array;
			lTmp = p_aVertices.sortOn (["x"], [Array.NUMERIC|Array.RETURNINDEXEDARRAY ]);
			l_min.x = p_aVertices[lTmp[0]].x;
			l_max.x = p_aVertices[lTmp[lTmp.length-1]].x;
			  
			lTmp = p_aVertices.sortOn (["y"], [Array.NUMERIC|Array.RETURNINDEXEDARRAY ]);
			l_min.y = p_aVertices[lTmp[0]].y;
			l_max.y = p_aVertices[lTmp[lTmp.length-1]].y;
			  
			lTmp = p_aVertices.sortOn (["z"], [Array.NUMERIC|Array.RETURNINDEXEDARRAY ]);
			l_min.z = p_aVertices[lTmp[0]].z;
			l_max.z = p_aVertices[lTmp[lTmp.length-1]].z;
			 
			return new BBox( l_min, l_max );
		}
	
		/**
		 * Creates a new <code>BBox</code> instance by passing the min and the max <code>Vector</code>.
		 * 
		 * @param p_min		Min vector, representing the lower point of the cube volume
		 * @param p_max		Max vector, representing the upper point of the cube volume
		 */		
		public function BBox( p_min:Vector=null, p_max:Vector=null )
		{
			min		= (p_min != null) ? p_min : new Vector( -0.5,-0.5,-0.5 );
			max		= (p_max != null) ? p_max : new Vector(  0.5, 0.5, 0.5 );
			tmin = new Vector();
			tmax = new Vector();
			aCorners = new Array(8);
			aTCorners = new Array(8);
			__computeCorners(false);
		}		
		
		/**
		 * Returns the center of the Bounding Box volume in the form of a 3D vector.
		 * 
		 * @return 		A <code>Vector</code> representing the center of the Bounding Box
		 */
		public function getCenter():Vector
		{
			return new Vector( 	(max.x + min.x) / 2,
								(max.y + min.y) / 2,
								(max.z + min.z) / 2);
		}
	
		/**
		 * Return the size of the Bounding Box.
		 * 
		 * @return 		A <code>Vector</code> representing the size of the volume in three dimensions.
		 */
		public function getSize():Vector
		{
			return new Vector(	Math.abs(max.x - min.x),
								Math.abs(max.y - min.y),
								Math.abs(max.z - min.z));
		}
	
		/**
		 * Get all the eight corner vertices of the bounding box.
		 * 
		 * @param p_bRecalcVertices 	If set to true the vertices array will be recalculated.
		 * 								Otherwise it will return the last calculated array.
		 * @return 		The array containing eight vertices representing the Bounding Box corners.
		 */
		private function __computeCorners( p_bRecalcVertices:Boolean=false ):Array
		{
			var minx:Number,miny:Number,minz:Number,maxx:Number,maxy:Number,maxz:Number;
			
			if( p_bRecalcVertices == true )
			{
			    minx = tmin.x;    miny = tmin.y;    minz = tmin.z;
			    maxx = tmax.x;    maxy = tmax.y;    maxz = tmax.z;
			}
			else
			{
			    minx = min.x;    miny = min.y;    minz = min.z;
			    maxx = max.x;    maxy = max.y;    maxz = max.z;
			}
			// --
			aTCorners[0] = new Vector(); aCorners[0] = new Vector((minx), (maxy), (maxz));
			aTCorners[1] = new Vector(); aCorners[1] = new Vector((maxx), (maxy), (maxz));
			aTCorners[2] = new Vector(); aCorners[2] = new Vector((maxx), (miny), (maxz));
			aTCorners[3] = new Vector(); aCorners[3] = new Vector((minx), (miny), (maxz));
			aTCorners[4] = new Vector(); aCorners[4] = new Vector((minx), (maxy), (minz));
			aTCorners[5] = new Vector(); aCorners[5] = new Vector((maxx), (maxy), (minz));
			aTCorners[6] = new Vector(); aCorners[6] = new Vector((maxx), (miny), (minz));
			aTCorners[7] = new Vector(); aCorners[7] = new Vector((minx), (miny), (minz));
			// --
			return aCorners;
		}	
		
	    /**
	     * Applies the transformation that is specified in the <code>Matrix4</code> parameter.
	     * 
	     * @param p_oMatrix		The transformation matrix
	     */		
	    public function transform( p_oMatrix:Matrix4 ):void
	    {
		    var lVector:Vector;
		    // --
		    
		    for( var lId:uint = 0; lId < 8; lId ++ )
		    {
		        aTCorners[lId].copy( aCorners[lId] )
		        p_oMatrix.vectorMult( aTCorners[lId] );
		    }
		    
		    // --
		    tmin.x = Number.MAX_VALUE; tmax.x = Number.MIN_VALUE;
			tmin.y = Number.MAX_VALUE; tmax.y = Number.MIN_VALUE;
			tmin.z = Number.MAX_VALUE; tmax.z = Number.MIN_VALUE;
		    for each ( lVector in aTCorners )
			{
				if( lVector.x < tmin.x )		tmin.x = lVector.x;
				if( lVector.x > tmax.x )		tmax.x = lVector.x;
				// --
				if( lVector.y < tmin.y )		tmin.y = lVector.y;
				if( lVector.y > tmax.y )		tmax.y = lVector.y;
				// --
				if( lVector.z < tmin.z )		tmin.z = lVector.z;
				if( lVector.z > tmax.z )		tmax.z = lVector.z;
	    	}
	    }
	    
		/**
		 * Returns a <code>String</code> representation of the <code>BBox</code>.
		 * 
		 * @return 	A String representing the bounding box
		 */			
		public function toString():String
		{
			return "sandy.bounds.BBox";
		}
		
		/**
		 * Clones the current bounding box. 
		 * 
		 * @return 		A cloned <code>BBox</code> instance
		 */		
		public function clone():BBox
		{
		    var l_oBBox:BBox = new BBox();
		    l_oBBox.max = max.clone();
		    l_oBBox.min = min.clone();
		    l_oBBox.tmax = tmax.clone();
		    l_oBBox.tmin = tmin.clone();
		    return l_oBBox;
		}
		
	}
}
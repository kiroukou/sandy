﻿package sandy.core.scenegraph {	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.geom.Point;		import sandy.bounds.BBox;	import sandy.core.Scene3D;	import sandy.core.data.Matrix4;	import sandy.core.data.Point3D;	import sandy.core.data.Polygon;	import sandy.core.data.UVCoord;	import sandy.core.data.Vertex;	import sandy.events.*;	import sandy.materials.Appearance;	import sandy.materials.Material;	import sandy.materials.WireFrameMaterial;	import sandy.math.IntersectionMath;	import sandy.view.CullingState;	import sandy.view.Frustum;	/**	 * The Shape3D class is the base class of all true 3D shapes.	 *	 * <p>It represents a node in the object tree of the world.<br/>	 * A Shape3D is a leaf node and can not have any child nodes.</p>	 * <p>It must be the child of a branch group or a transform group, 	 * but transformations can be applied to the Shape directly.</p>	 * 	 * @author		Thomas Pfeiffer - kiroukou	 * @version		3.1	 * @date 		26.07.2007	 */	public class Shape3D extends ATransformable implements IDisplayable	{ 		/**		 * Default material for the DEFAULT_APPEARANCE object		 */		public static var DEFAULT_MATERIAL:Material = new WireFrameMaterial();		/**		 * Default appearance for Shape3D instances. If no apperance is given, this default one will be applied using the DEFAULT_MATERIAL as front and back material		 */		public static var DEFAULT_APPEARANCE:Appearance = new Appearance( DEFAULT_MATERIAL );				/**		 * The array of polygons building this object.		 */				public var aPolygons:Array = new Array();		/**		 * <p>		 * Enable the Frustum near plane clipping on the visible polygons.		 * Enable this when you need a perfect intersection between the front camera plane.		 * This is mainly used when you need the camera to move on a long plane.</p>		 * 		 * <p>Important: Enable the clipping makes process a bit slower, especially with big scenes.</p>		 */ 		public var enableNearClipping:Boolean = false;				/**		 * <p>		 * Enable the Frustum clipping on the visible polygons.		 * Enable this when you need a perfect intersection between the camera and some object shapes.		 * In case you need to make the camera look inside and outide a box, or other immerssive things.</p>		 * 		 * <p>Important: Enable the clipping makes process a bit slower, especially with big scenes.</p>		 *		 * <p>Specify if this object polygons should be clipped against the camera frustum planes.</p>		 */		override public function set enableClipping( p_bClippingValue:Boolean ):void		{			m_bClipping = p_bClippingValue;		}				public function get enableClipping():Boolean		{			return m_bClipping;		}		/**		 * Should forced depth be enable for this object?.		 *		 * <p>If true it is possible to force this object to be drawn at a specific depth,<br/>		 * if false the normal Z-sorting algorithm is applied.</p>		 * <p>When correctly used, this feature allows you to avoid some Z-sorting problems.</p>		 */		public var enableForcedDepth:Boolean = false;				/**		 * The forced depth for this object.		 *		 * <p>To make this feature work, you must enable the ForcedDepth system too.<br/>		 * The higher the depth is, the sooner the more far the object will be represented.</p>		 */		public var forcedDepth:Number = 0;					/**		 * Animated flag. 		 * <p>If the geometry vertices are dynamically modified by some animation engine or mathematic function, some polygon may disapear with no reason.		 * The normal Point3D is used to compute the polygon visibility, and if you don't update the normal Point3D after the vertices modifications, there's an error.		 * To fix that problem, Sandy3D offers that new property appeared in 3.0.3 release, which once set to true, automatically update the normal Point3Ds for you.		 * As a performance warning, don't set this value to true if your model geometry isn't animated.</p>		 */		public var animated:Boolean = false;		 		/**		 * Array containing the visible polygons of that shape.		 * Contente is available after the SCENE_RENDER_DISPLAYLIST event of the current scene has been dispatched		 */		public const aVisiblePolygons:Array = new Array();		 		/**		 * Creates a 3D object		 *		 * <p>This creates a new 3D geometry object. That object will handle the rendering of a static Geometry3D object into a real 3D object and finally to the 2D camera representation.</p>		 *		 * @param p_sName		A string identifier for this object		 * @param p_oGeometry		The geometry of this object		 * @param p_oAppearance		The appearance of this object. If no apperance is given, the DEFAULT_APPEARANCE will be applied.		 * @param p_bUseSingleContainer	Whether tis object should use a single container to draw on		 */			public function Shape3D( p_sName:String = "", p_oGeometry:Geometry3D = null, p_oAppearance:Appearance = null, p_bUseSingleContainer:Boolean=true )		{			super( p_sName );			// -- Add this graphical object to the World display list			m_oContainer = new Sprite();			m_oContainer.name = name;			// --	        geometry = p_oGeometry;	        // -- HACK to make sure that the correct container system will be applied			m_bUseSingleContainer = !p_bUseSingleContainer;			useSingleContainer = p_bUseSingleContainer;			// --			appearance = ( p_oAppearance ) ? p_oAppearance : Shape3D.DEFAULT_APPEARANCE;			// -- 			updateBoundingVolumes();	    }	    		    /**		 * Reference to the scene is it linked to.		 * Initialized at null.		 */		override public function set scene( p_oScene:Scene3D ):void		{		 	super.scene = p_oScene;		 	for each( var l_oPoly:Polygon in aPolygons )		 	{		 		l_oPoly.scene = null;		 		l_oPoly.scene = p_oScene;		 	}		}		    	/**    	 * setter that allow user to change the way to render this object.    	 * set to true, the shape will be rendered into a single Sprite object, which is accessible through the container property.    	 * set to false, the container property does not target anything, but all the polygons will be rendered into their own dedidated container.    	 *    	 * <p>If true, this object renders itself on a single container ( Sprite ),<br/>    	 * if false, each polygon is rendered on its own container.</p>    	 */    	override public function set useSingleContainer( p_bUseSingleContainer:Boolean ):void    	{    		var l_oFace:Polygon;    		// --    		if( p_bUseSingleContainer == m_bUseSingleContainer ) return;    		// --    		if( p_bUseSingleContainer )    		{    			for each( l_oFace in aPolygons )    			{					if( l_oFace.container.parent ) 					{						l_oFace.container.graphics.clear();						l_oFace.container.parent.removeChild( l_oFace.container );						this.broadcaster.removeChild( l_oFace.broadcaster );					}    			}    		}    		else    		{    			if( m_oContainer.parent )    			{    				m_oContainer.graphics.clear();    				m_oContainer.parent.removeChild( m_oContainer );    			}    			// --    			for each( l_oFace in aPolygons )    			{					this.broadcaster.addChild( l_oFace.broadcaster );					// we reset the polygon container to the original one, and add it to the world container					l_oFace.container.graphics.clear();    			}    		}    		m_bUseSingleContainer = p_bUseSingleContainer;    		changed = true;    	}    		/**		 * @private		 */		public function get useSingleContainer ():Boolean		{return m_bUseSingleContainer;}		/**		 * Updates the bounding volumes of this object.		 */    	override public function updateBoundingVolumes():void    	{    	    if( m_oGeometry )    	    {    	        boundingBox	= BBox.create( m_oGeometry.aVertex );    	        boundingSphere.resetFromBox( boundingBox );    	    }    	    if( parent )				parent.updateBoundingVolumes();    	}		  		/**		 * Tests this node against the camera frustum to get its visibility.		 *		 * <p>If this node and its children are not within the frustum, 		 * the node is set to cull and it would not be displayed.<p/>		 * <p>The method also updates the bounding volumes to make the more accurate culling system possible.<br/>		 * First the bounding sphere is updated, and if intersecting, 		 * the bounding box is updated to perform the more precise culling.</p>		 * <p><b>[MANDATORY] The update method must be called first!</b></p>		 *		 * @param p_oScene The current scene		 * @param p_oFrustum	The frustum of the current camera		 * @param p_oViewMatrix	The view martix of the curren camera		 * @param p_bChanged		 */		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void		{			super.cull( p_oFrustum, p_oViewMatrix, p_bChanged );			if( culled == Frustum.OUTSIDE ) return;			/////////////////////////	        //// BOUNDING SPHERE ////	        /////////////////////////	       	boundingSphere.transform( viewMatrix );        	culled = p_oFrustum.sphereInFrustum( boundingSphere );			// --			if( culled == Frustum.INTERSECT )			{				////////////////////////				////  BOUNDING BOX  ////				////////////////////////				culled = p_oFrustum.boxInFrustum( boundingBox.transform( viewMatrix ) );			}			// --			if( culled != CullingState.OUTSIDE && m_oAppearance != null )			{				scene.renderer.addToDisplayList(this);			}						if( m_bEv || m_bMouseInteractivity )			{				if( m_bWasOver == true && m_oLastContainer.hitTestPoint(m_oLastContainer.mouseX, m_oLastContainer.mouseY) == false )				{					m_oEB.dispatchEvent( new Shape3DEvent( MouseEvent.MOUSE_OUT, this, m_oLastEvent.polygon, m_oLastEvent.uv, m_oLastEvent.point, m_oLastEvent.event ) );					m_bWasOver = false;					if( m_oLastContainer != m_oContainer )					{						m_oLastEvent.polygon._onTextureInteraction( m_oLastEvent.event );						m_oLastEvent.polygon._stopMouseInteraction();					}				}			}		}		/**		* Clears the graphics object of this object's container.		*		* <p>The the graphics that were drawn on the Graphics object is erased, 		* and the fill and line style settings are reset.</p>		*/		public function clear():void		{			if( m_oContainer ) 				m_oContainer.graphics.clear();			changed = true;		}				/**		 * Performs a z-sorting and renders the objects visible polygons.		 *		 * <p>The method is called only if the object renders on a single container<br/> 		 * - ( useSingleContainer = true ).</p>		 *		 * @param p_oScene The current scene		 * @param p_oContainer	The container to draw on		 */		public function display( p_oContainer:Sprite = null  ):void		{			if ( m_bNotConvex || m_bBackFaceCulling == false ) 			{				// sort only if convex flag is not set				aVisiblePolygons.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );			}		    // --		   	var l_oFace:Polygon;			for each( l_oFace in aVisiblePolygons )			{				l_oFace.display( m_oContainer );			}		}		/**		 * The contianer for this object.		 * This container property exist if the useSingleContainer is set to true.		 * It is a direct access to the Shape3D container to, for example, apply nice effects such as filters etc.		 */		public function get container():Sprite		{return m_oContainer;}				/**		 * The depth of this object.		 * In case the useSingleContainer mode is enabled (default mode), this value returns the means depth of the Shape in the camera frame.		 * This value is mainly used as a z-sorting value.		 */		public function get depth():Number		{return m_nDepth;}				/**		 * @private		 */		public function set depth( p_nDepth:Number ):void		{m_nDepth = p_nDepth; changed = true;}				/**		 * This property call allows you to get the geometryCenter offset Point3D of the Shape.		 * Modifying this Point3D will impact the way the shape is rendered, mainly its rotation center.		 * 		 * @return a Point3D which corresponds to the 2 directions offset.		 */		public function get geometryCenter():Point3D		{return m_oGeomCenter;		}				private var m_bClipping:Boolean;		/**		 * Change the geometryCenter of the Shape3D.		 * To change the geometryCenter point of a shape, simply set this geometryCenter property.		 * The geometryCenter property requires a Point3D. This Point3D is an position offset relative to the original geometry one.		 * For example, a Sphere primitive creates automatically a geometry which center is the 0,0,0 position. If you rotate this sphere as this,		 * it will rotate around its center.		 * Now if you set the geometryCenter property, this rotation center will change.		 * 		 * The updateBoundingVolumes method which does update the bounding volumes to enable a correct frustum culling is automatically called.		 * 		 * @example To change the geometryCenter center at runtime		 * <listing version="3.1">		 *    var l_oSphere:Sphere = new Sphere("mySphere", 50, 3 );		 *    // Change the rotation reference to -50 offset in Y direction from the orinal one		 *    // and that corresponds to the bottom of the sphere		 *    l_oSphere.geometryCenter = new Point3D( 0, -50, 0 ); 		 *    l_oSphere.rotateZ = 45;		 * </listing>		 */		public function set geometryCenter( p_oGeomCenter:Point3D ):void		{			var l_oDiff:Point3D = p_oGeomCenter.clone();			l_oDiff.sub( m_oGeomCenter );			// --			if( m_oGeometry )			{				for each( var l_oVertex:Vertex in m_oGeometry.aVertex )				{					l_oVertex.x += l_oDiff.x;					l_oVertex.y += l_oDiff.y;					l_oVertex.z += l_oDiff.z;				}			}			// --			m_oGeomCenter.copy( p_oGeomCenter );				// --			updateBoundingVolumes();			changed = true;			}    			/**		 * Set the appearance of this object.		 * NOTE: Please mind that Sandy3D allows to set an appearance at a polygon level.		 * @param p_oApp The appearance object which stores the front material and -if set- the back material which represents that shape.		 */		override public function set appearance( p_oApp:Appearance ):void		{			// Now we register to the update event			m_oAppearance = p_oApp;			// --			if( m_oGeometry )			{				for each( var v:Polygon in aPolygons )					v.appearance = m_oAppearance;			}			changed = true;		}				/**		 * @private		 */		public function get appearance():Appearance 		{			return m_oAppearance;		}				/**		 * Returns the material currently used by the renderer		 * @return Material the material used to render		 */		public function get material():Material		{			return ( aPolygons[0].visible ) ? m_oAppearance.frontMaterial : m_oAppearance.backMaterial;		}		       		/**		 * The geometry of this object.		 */		public function set geometry( p_geometry:Geometry3D ):void		{			if( p_geometry == null ) return;			// TODO shall we clone the geometry?			m_oGeometry = p_geometry;			updateBoundingVolumes();			// -- we generate the possible missing normals			m_oGeometry.generateFaceNormals();//Must be called first			m_oGeometry.generateVertexNormals();//must be called second			// --			__destroyPolygons();			__generatePolygons( m_oGeometry );			changed = true;		}				/**		 * @private		 */		public function get geometry():Geometry3D		{			return m_oGeometry;		}			/**		 * Should back face culling be enabled for this object?.		 *		 * <p>If set to false all faces of this object are drawn.<br/>		 * A true value enables the back face culling algorithm - Default true</p>		 */		override public function set enableBackFaceCulling( b:Boolean ):void		{			if( b != m_bBackFaceCulling )			{				m_bBackFaceCulling = b;				changed = true;			}		}				/**		 * @private		 */		public function get enableBackFaceCulling():Boolean		{			return m_bBackFaceCulling;		}					/**		 * Enable the interactivity on this shape and its polygon.		 * Be careful, this mode have some requirements :		 *   - to have useSingleContainer set to false. It is done automatically if enabled		 * 		 * The original settings are back to their  original state when the mode is disabled		 */		override public function set enableInteractivity( p_bState:Boolean ):void		{			if( p_bState != m_bMouseInteractivity )			{				changed = true;				// --				if( p_bState )				{					if( m_bUseSingleContainer == true )					{						m_bUseSingleContainer = false;						m_bForcedSingleContainer = true;					}				}				else				{					if( m_bForcedSingleContainer == true )					{						useSingleContainer = true;						m_bForcedSingleContainer = false;					}				}				// --				for each( var l_oPolygon:Polygon in aPolygons )				{		    		l_oPolygon.enableInteractivity = p_bState;		    	}		    							m_bMouseInteractivity = p_bState;			}		}					public function get enableInteractivity():Boolean		{ return m_bMouseInteractivity; }				/**		 * Enables the event system for mouse events.		 *		 * <p>When set to true, the onPress, onRollOver and onRollOut events are broadcast.<br/>		 * The event system is enabled or disabled for all faces of this object.<br/>		 * As an alternative, you have the possibility to enable events only for specific faces.</p>		 *		 * <p>Once this feature is enabled, the animation is more CPU intensive.</p>		 * 		 * <p>Example		 * <code>		 * 	var l_oShape:Shape3D = new Sphere("sphere");		 * 	l_oShape.enableEvents = true;		 * 	l_oShape.addEventListener( MouseEvent.CLICK, onClick );		 * 		 * 	function onClick( p_eEvent:Shape3DEvent ):void         * 	{         *   	var l_oPoly:Polygon = ( p_eEvent.polygon );           *   	var l_oPointAtClick:Point3D =  p_eEvent.point;         *   	// -- get the normalized uv of the point under mouse position         *  	var l_oIntersectionUV:UVCoord = p_eEvent.uv;         *   	// -- get the correct material         *   	var l_oMaterial:BitmapMaterial = (l_oPoly.visible ? l_oPoly.appearance.frontMaterial : l_oPoly.appearance.backMaterial) as BitmapMaterial;         * 	}         * </code>		 */		override public function set enableEvents( b:Boolean ):void		{			// To use only when use Single container is disabled 			var v:Polygon = null;						if( b )			{				if( !m_bEv )				{	    			if( m_bUseSingleContainer == false )	    			{		    			for each( v in aPolygons )						{		    			    v.enableEvents = true;		    			}	    			}	    			else	    			{	    				m_oContainer.addEventListener(MouseEvent.CLICK, _onInteraction);			    		m_oContainer.addEventListener(MouseEvent.MOUSE_UP, _onInteraction);			    		m_oContainer.addEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);			    		m_oContainer.addEventListener(MouseEvent.ROLL_OVER, _onInteraction);			    		m_oContainer.addEventListener(MouseEvent.ROLL_OUT, _onInteraction);			    								m_oContainer.addEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);						m_oContainer.addEventListener(MouseEvent.MOUSE_OVER, _onInteraction);						m_oContainer.addEventListener(MouseEvent.MOUSE_OUT, _onInteraction);						m_oContainer.addEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);	    			}				}			}			else if( !b && m_bEv )			{				if( m_bUseSingleContainer == false )    			{	    			for each( v in aPolygons )					{	    			    v.enableEvents = false;	    			}    			}    			else    			{    				m_oContainer.removeEventListener(MouseEvent.CLICK, _onInteraction);					m_oContainer.removeEventListener(MouseEvent.MOUSE_UP, _onInteraction);					m_oContainer.removeEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);					m_oContainer.removeEventListener(MouseEvent.ROLL_OVER, _onInteraction);					m_oContainer.removeEventListener(MouseEvent.ROLL_OUT, _onInteraction);					m_oContainer.removeEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);					m_oContainer.removeEventListener(MouseEvent.MOUSE_OVER, _onInteraction);					m_oContainer.removeEventListener(MouseEvent.MOUSE_OUT, _onInteraction);					m_oContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);    			}			}			m_bEv = b;		}			protected function _onInteraction( p_oEvt:Event ):void		{			// we need to get the polygon which has been clicked.			var l_oClick:Point = new Point( m_oContainer.mouseX, m_oContainer.mouseY );			var l_oA:Point = new Point(), l_oB:Point = new Point(), l_oC:Point = new Point();			var l_oPoly:Polygon;			var l_aSId:Array = aPolygons.sortOn( 'depth', Array.NUMERIC | Array.RETURNINDEXEDARRAY );			var l:int = aPolygons.length, j:int;			for( j = 0; j < l; j += 1 )			//j = l;			//while( --j > -1 )			{				l_oPoly = aPolygons[ l_aSId[ int(j) ] ];				if( !l_oPoly.visible && m_bBackFaceCulling ) continue;				// --				var l_nSize:int = l_oPoly.vertices.length;				var l_nTriangles:int = l_nSize - 2;				for( var i:int = 0; i < l_nTriangles; i++ )				{					l_oA.x = l_oPoly.vertices[i].sx; l_oA.y = l_oPoly.vertices[i].sy;					l_oB.x = l_oPoly.vertices[i+1].sx; l_oB.y = l_oPoly.vertices[i+1].sy;					l_oC.x = l_oPoly.vertices[(i+2)%l_nSize].sx; l_oC.y = l_oPoly.vertices[(i+2)%l_nSize].sy;					// --					if( IntersectionMath.isPointInTriangle2D( l_oClick, l_oA, l_oB, l_oC ) )					{						var l_oUV:UVCoord = l_oPoly.getUVFrom2D( l_oClick );						var l_oPt3d:Point3D = l_oPoly.get3DFrom2D( l_oClick );						m_oLastContainer = m_oContainer;						m_oLastEvent = new Shape3DEvent( p_oEvt.type, this, l_oPoly, l_oUV, l_oPt3d, p_oEvt );						m_oEB.dispatchEvent( m_oLastEvent );						// to be able to dispatch mouse out event						if( p_oEvt.type == MouseEvent.MOUSE_OVER )							m_bWasOver = true;						return;					}				}			}		}				/**		 * Changes the backface culling side.		 *		 * <p>When you want to display a cube and you are the cube, you see its external faces.<br/>		 * The internal faces are not drawn due to back face culling</p>		 *		 * <p>In case you are inside the cube, by default Sandy's engine still doesn't draw the internal faces		 * (because you should not be in there).</p> 		 *		 * <p>If you need to be only inside the cube, you can call this method to change which side is culled.<br/>		 * The faces will be visible only from the interior of the cube.</p>		 *		 * <p>If you want to be both on the inside and the outside, you want to make the faces visible from on both sides.<br/>		 * In that case you just have to set enableBackFaceCulling to false.</p>		 */		public function swapCulling():void		{			for each( var v:Polygon in aPolygons )			{				v.swapCulling();			}			changed = true;		}				/**		 * Destroy this object and all its faces		 * container object is removed, and graphics cleared.  All polygons have their		 */		public override function destroy():void		{			// 	FIXME Fix it - it should be more like 			m_oGeometry.dispose();			// --			clear();			if( m_oContainer.parent ) m_oContainer.parent.removeChild( m_oContainer );			if( m_oContainer ) m_oContainer = null;			// --			__destroyPolygons();			// --			super.destroy();		}		/**		 * This method returns a clone of this Shape3D.		 * The current appearance will be applied, and the geometry is cloned (not referenced to curent one).		 * 		 * @param p_sName The name of the new shape you are going to create		 * @param p_bKeepTransform Boolean value which, if set to true, applies the current local transformations to the cloned shape. Default value is false.		 *		 * @return 	The clone		 */		public function clone( p_sName:String="", p_bKeepTransform:Boolean = false ):Shape3D		{			var l_oClone:Shape3D = new Shape3D( p_sName, geometry.clone(), appearance, m_bUseSingleContainer );			// --			if( p_bKeepTransform == true ) l_oClone.matrix.copy( this.matrix );			// --			return l_oClone;		}				/**		 * Returns a string representation of this object.		 *		 * @return	The fully qualified name of this object and its geometry.		 */		public override function toString ():String		{			return "sandy.core.scenegraph.Shape3D" + " " +  m_oGeometry.toString();		}		/**		 * Sets internal convex flag. Set this to true if you know that this shape is convex.		 * @internal this is implemented as simple write-only flag to avoid any computation costs whatsoever.		 */		public function setConvexFlag (convex:Boolean):void		{			m_bNotConvex = !convex;		}		///////////////////		///// PRIVATE /////		///////////////////				private function __destroyPolygons():void		{	    	if( aPolygons != null && aPolygons.length > 0 )			{				var i:int, l:int = aPolygons.length;				while( i<l )				{					if( broadcaster != null ) broadcaster.removeChild( aPolygons[i].broadcaster );					if( aPolygons[i] ) Polygon( aPolygons[int(i)] ).destroy();					// --					aPolygons[int(i)] = null;					// --					i ++;				}			}			aPolygons.splice(0);			aPolygons = null;		}				private function __generatePolygons( p_oGeometry:Geometry3D ):void		{			var i:int = 0, l:int = p_oGeometry.aFacesVertexID.length;			aPolygons = new Array( l );			// --			for( i=0; i < l; i += 1 )			{				aPolygons[i] = new Polygon( this, p_oGeometry, p_oGeometry.aFacesVertexID[i], p_oGeometry.aFacesUVCoordsID[i], i, i );				if( m_oAppearance ) aPolygons[int(i)].appearance = m_oAppearance;				this.broadcaster.addChild( aPolygons[int(i)].broadcaster );			}					}	    				// ______________		// [PRIVATE] DATA________________________________________________						private var m_oAppearance:Appearance ; // The Appearance of this Shape3D			    private var m_bEv:Boolean = false; // The event system state (enable or not)		protected var m_oGeomCenter:Point3D = new Point3D();		private var m_bBackFaceCulling:Boolean = true;				//@private		public var m_bWasOver:Boolean = false;		public var m_oLastEvent:Shape3DEvent;		public var m_oLastContainer:Sprite;				/** Geometry of this object */		private var m_oGeometry:Geometry3D;				protected var m_bUseSingleContainer:Boolean = true;		protected var m_nDepth:Number = 0;		protected var m_oContainer:Sprite;		private var m_bMouseInteractivity:Boolean = false;		private var m_bForcedSingleContainer:Boolean = false;		private var m_bNotConvex:Boolean = true;	}}
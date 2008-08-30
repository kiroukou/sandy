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

# ***** END LICENSE BLOCK ******/

package sandy.core.scenegraph;

import sandy.core.Scene3D;
import sandy.core.data.Matrix4;
import sandy.core.data.Vector;

/**
 * ABSTRACT CLASS - super class for all movable objects in the object tree.
 *
 * <p> This class should not be directly instatiated, but sub classed.<br/>
 * The Atransformable class is resposible for scaling, rotation and translation of objects in 3D space.</p>
 *
 * <p>Rotations and translations are performed in one of three coordinate systems or reference frames:<br/>
 * - The local frame which is the objects own coordinate system<br />
 * - The parent frame which is the coordinate system of the object's parent, normally a TransformGroup<br/>
 * - The world frame which is the coordinate system of the world, the global system.</p>
 * <p>Positions, directions, translations and rotations of an ATransformable object are performed in its parent frame.<br />
 * Tilt, pan and roll, are rotations around the local axes, and moveForward, moveUpwards and moveSideways are translations along local axes.</p>
 *
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author Niel Drummond - haXe port 
 * 
 * 
 **/
class ATransformable extends Node
{
	/**
	 * Disable the local transformations applied to this Node if set to false.
	 * They will be applied back once et back to true.
	 */
	public var disable:Null<Bool>;
	
	/**
	 * Creates a transformable node in the object tree of the world.
	 *
	 * <p>This constructor should normally not be called directly, but from a sub class.</p>
	 *
	 * @param p_sName	A string identifier for this object
	 */
	public function new ( ?p_sName:String )
	{
		p_sName = (p_sName != null)?p_sName:"";

		super( p_sName );
  disable = false;

	 m_oPreviousOffsetRotation = new Vector();

		// --
		initFrame();
		// --
		_p 		= new Vector();
		_oScale = new Vector( 1, 1, 1 );
		_vRotation = new Vector(0,0,0);
		// --
		_vLookatDown = new Vector(0.00000000001, -1, 0);// value to aVoid some colinearity problems.;
		// --
		_nRoll 	= 0;
		_nTilt 	= 0;
		_nYaw  	= 0;
		// --
		m_tmpMt = new Matrix4();
		m_oMatrix = new Matrix4();
	}
	/**
	 * Initiates the local coordinate system for this object.
	 *
	 * <p>The local coordinate system for this object is set parallell the parent system.</p>
	 */
	public function initFrame():Void
	{
		_vSide 	= new Vector( 1, 0, 0 );
		_vUp 	= new Vector( 0, 1 ,0 );
		_vOut 	= new Vector( 0, 0, 1 );
	}

	public var matrix(__getMatrix, __setMatrix):Matrix4;
	private function __getMatrix():Matrix4
	{
	    	return m_oMatrix;
	}

	/**
	 * This property allows you to directly set the matrix you want to a transformable object.
	 * But be careful with its use. It modifies the rotation AND the position.
	 * WARNING : Please remove any scale from this matrix. This is not managed yet.
	 * WARNING : Please think about call initFrame before changing this frame. Without calling this method first, the frame will stay local, and the transformation will be applied
	 * locally.
	 * @param p_oMatrix The new local matrix for this node
	 */
	private function __setMatrix( p_oMatrix:Matrix4 ):Matrix4
	{
		m_oMatrix = p_oMatrix;
	    // --
	    m_oMatrix.vectorMult3x3(_vSide);
	    m_oMatrix.vectorMult3x3(_vUp);
	    m_oMatrix.vectorMult3x3(_vOut);
	    // --
	    _vSide.normalize();
	    _vUp.normalize();
	    _vOut.normalize();
	    // --
	    _p.x = p_oMatrix.n14;
	    _p.y = p_oMatrix.n24;
	    _p.z = p_oMatrix.n34;
					return p_oMatrix;
	}
	

	/**
	 * @private
	 */
	private function __setX( p_nX:Null<Float> ):Null<Float>
	{
		_p.x = p_nX;
		changed = true;
		return p_nX;
	}
	/**
	 * x position of this object in its parent frame.
	 */
	public var x(__getX,__setX):Null<Float>;
	private function __getX():Null<Float>
	{
		return _p.x;
	}

	/**
	 * @private
	 */
	private function __setY( p_nY:Null<Float> ):Null<Float>
	{
		_p.y = p_nY;
		changed = true;
		return p_nY;
	}

	/**
	 * y position of this object in its parent frame.
	 */
	public var y(__getY,__setY):Null<Float>;
	private function __getY():Null<Float>
	{
		return _p.y;
	}

	/**
	 * @private
	 */
	private function __setZ( p_nZ:Null<Float> ):Null<Float>
	{
		_p.z = p_nZ;
		changed = true;
		return p_nZ;
	}

	/**
	 * z position of the node in its parent frame.
	 */
	public var z(__getZ,__setZ):Null<Float>;
	private function __getZ():Null<Float>
	{
		return _p.z;
	}

	/**
	 * Forward direction ( local z ) in parent coordinates.
	 */
	public var out(__getOut,null):Vector;
	private function __getOut():Vector
	{
		return _vOut;
	}

	/**
	 * Side direction ( local x ) in parent coordinates.
	 */
	public var side(__getSide,null):Vector;
	private function __getSide():Vector
	{
		return _vSide;
	}

	/**
	 * Up direction ( local y ) in parent coordinates.
	 */
	public var up(__getUp,null):Vector;
	private function __getUp():Vector
	{
		return _vUp;
	}

	/**
	 * @private
	 */
	private function __setScaleX( p_nScaleX:Null<Float> ):Null<Float>
	{
		_oScale.x = p_nScaleX;
		changed = true;
		return p_nScaleX;
	}

	/**
	 * x scale of this object.
	 *
	 * <p>A value of 1 scales to the original x scale, a value of 2 doubles the x scale.<br/>
	 * NOTE : This value does not affect the camera object.</p>
	 */
	public var scaleX(__getScaleX,__setScaleX):Null<Float>;
	private function __getScaleX():Null<Float>
	{
		return _oScale.x;
	}

	/**
	 * @private
	 */
	private function __setScaleY( p_scaleY:Null<Float> ):Null<Float>
	{
		_oScale.y = p_scaleY;
		changed = true;
		return p_scaleY;
	}

	/**
	 * y scale of this object.
	 *
	 * <p>A value of 1 scales to the original y scale, a value of 2 doubles the y scale.<br/>
	 * NOTE : This value does not affect the camera object.</p>
	 */
	public var scaleY(__getScaleY,__setScaleY):Null<Float>;
	private function __getScaleY():Null<Float>
	{
		return _oScale.y;
	}

	/**
	 * @private
	 */
	public function __setScaleZ( p_scaleZ:Null<Float> ):Null<Float>
	{
		_oScale.z = p_scaleZ;
		changed = true;
		return p_scaleZ;
	}

	/**
	 * z scale of this object.
	 *
	 * <p>A value of 1 scales to the original z scale, a value of 2 doubles the z scale.<br/>
	 * NOTE : This value does not affect the camera object.</p>
	 */
	public var scaleZ(__getScaleZ,__setScaleZ):Null<Float>;
	public function __getScaleZ():Null<Float>
	{
		return _oScale.z;
	}

	/**
	 * Translates this object along its side vector ( local x ) in the parent frame.
	 *
	 * <p>If you imagine yourself in the world, it would be a step to your right or to your left</p>
	 *
	 * @param p_nD	How far to move
	 */
	public function moveSideways( p_nD : Float ) : Void
	{
		changed = true;
		_p.x += _vSide.x * p_nD;
		_p.y += _vSide.y * p_nD;
		_p.z += _vSide.z * p_nD;
	}

	/**
	 * Translates this object along its up vector ( local y ) in the parent frame.
	 *
	 * <p>If you imagine yourself in the world, it would be a step up or down<br/>
	 * in the direction of your body, not always vertically!</p>
	 *
	 * @param p_nD	How far to move
	 */
	public function moveUpwards( p_nD : Float ) : Void
	{
		changed = true;
		_p.x += _vUp.x * p_nD;
		_p.y += _vUp.y * p_nD;
		_p.z += _vUp.z * p_nD;
	}

	/**
	 * Translates this object along its forward vector ( local z ) in the parent frame.
	 *
	 * <p>If you imagine yourself in the world, it would be a step forward<br/>
	 * in the direction you look, not always horizontally!</p>
	 *
	 * @param p_nD	How far to move
	 */
	public function moveForward( p_nD : Float ) : Void
	{
		changed = true;
		_p.x += _vOut.x * p_nD;
		_p.y += _vOut.y * p_nD;
		_p.z += _vOut.z * p_nD;
	}

	/**
	 * Translates this object parallel to its parent zx plane and in its forward direction.
	 *
	 * <p>If you imagine yourself in the world, it would be a step in the forward direction,
	 * but without changing your altitude ( constant global z ).</p>
	 *
	 * @param p_nD	How far to move
	 */
	public function moveHorizontally( p_nD:Null<Float> ) : Void
	{
		changed = true;
		_p.x += _vOut.x * p_nD;
		_p.z += _vOut.z * p_nD;
	}

	/**
	 * Translates this object vertically in ots parent frame.
	 *
	 * <p>If you imagine yourself in the world, it would be a strictly vertical step,
	 * ( in the global y direction )</p>
	 *
	 * @param p_nD	How far to move
	 */
	public function moveVertically( p_nD:Null<Float> ) : Void
	{
		changed = true;
		_p.y += p_nD;
	}

	/**
	 * Translates this object laterally in its parent frame.
	 *
	 * <p>This is a translation in the parents x direction.</p>
	 *
	 * @param p_nD	How far to move
	 */
	public function moveLateraly( p_nD:Null<Float> ) : Void
	{
		changed = true;
		_p.x += p_nD;
	}

	/**
	 * Translate this object from it's current position with the specified offsets.
	 *
	 * @param p_nX 	Offset that will be added to the x coordinate of the object
	 * @param p_nY 	Offset that will be added to the y coordinate of the object
	 * @param p_nZ 	Offset that will be added to the z coordinate of the object
	 */
	public function translate( p_nX:Null<Float>, p_nY:Null<Float>, p_nZ:Null<Float> ) : Void
	{
		changed = true;
		_p.x += p_nX;
		_p.y += p_nY;
		_p.z += p_nZ;
	}


	/**
	 * Rotate this object around the specified axis in the parent frame by the specified angle.
	 *
	 * <p>NOTE : The axis will be normalized automatically.</p>
	 *
	 * @param p_nX		The x coordinate of the axis
	 * @param p_nY		The y coordinate of the axis
	 * @param p_nZ		The z coordinate of the axis
	 * @param p_nAngle	The angle of rotation in degrees.
	 */
	public function rotateAxis( p_nX : Float, p_nY : Float, p_nZ : Float, p_nAngle : Float ):Void
	{
		changed = true;
		p_nAngle = (p_nAngle + 360)%360;
		var n:Null<Float> = Math.sqrt( p_nX*p_nX + p_nY*p_nY + p_nZ*p_nZ );
		// --
		m_tmpMt.axisRotation( p_nX/n, p_nY/n, p_nZ/n, p_nAngle );
		// --
		m_tmpMt.vectorMult3x3(_vSide);
		m_tmpMt.vectorMult3x3(_vUp);
		m_tmpMt.vectorMult3x3(_vOut);
	}

	/**
	 * The position in the parent frame this object should "look at".
	 *
	 * <p>Useful for following a moving object or a static object while this object is moving.<br/>
	 * Normally used when this object is a camera</p>
	 */
	public var target( null,__setTarget ):Vector;
	private function __setTarget( p_oTarget:Vector ):Vector
	{
		lookAt( p_oTarget.x, p_oTarget.y, p_oTarget.z) ;
		return p_oTarget;
	}

	/**
	 * Makes this object "look at" the specified position in the parent frame.
	 *
	 * <p>Useful for following a moving object or a static object while this object is moving.<br/>
	 * Normally used when this object is a camera</p>
	 *
	 * @param	p_nX	Number	The x position to look at
	 * @param	p_nY	Number	The y position to look at
	 * @param	p_nZ	Number	The z position to look at
	 */
	public function lookAt( p_nX:Null<Float>, p_nY:Null<Float>, p_nZ:Null<Float> ):Void
	{
		changed = true;
		//
		_vOut.x = p_nX; _vOut.y = p_nY; _vOut.z = p_nZ;
		//
		_vOut.sub( _p );
		_vOut.normalize();
		// -- the vOut vector should not be colinear with the reference down vector!
		_vSide = null;
		_vSide = _vOut.cross( _vLookatDown );
		_vSide.normalize();
		//
		_vUp = null;
		_vUp = _vOut.cross(_vSide );
		_vUp.normalize();
	}

	/**
	 * Rotates this object around an axis parallel to the parents x axis.
	 *
	 * <p>The object rotates a specified angle ( degrees ) around an axis through the
	 * objects reference point, paralell to the x axis of the parent frame.</p>
	 */
	private function __setRotateX ( p_nAngle:Null<Float> ):Null<Float>
	{
		var l_nAngle:Null<Float> = (p_nAngle - _vRotation.x);
		if(l_nAngle == 0 ) return null;
		changed = true;
		// --
		m_tmpMt.rotationX( l_nAngle );
		m_tmpMt.vectorMult3x3(_vSide);
		m_tmpMt.vectorMult3x3(_vUp);
		m_tmpMt.vectorMult3x3(_vOut);
		// --
		_vRotation.x = p_nAngle;
		return p_nAngle;
	}

	/**
	 * @private
	 */
	public var rotateX(__getRotateX,__setRotateX):Null<Float>;
	private function __getRotateX():Null<Float>
	{
		return _vRotation.x;
	}

	/**
	 * Rotates this object around an axis parallel to the parents y axis.
	 *
	 * <p>The object rotates a specified angle ( degrees ) around an axis through the
	 * objects reference point, parallel to the y axis of the parent frame.</p>
	 */
	private function __setRotateY ( p_nAngle:Null<Float> ):Null<Float>
	{
		var l_nAngle:Null<Float> = (p_nAngle - _vRotation.y);
		if(l_nAngle == 0 ) return null;
		changed = true;
		// --
		m_tmpMt.rotationY( l_nAngle );
		m_tmpMt.vectorMult3x3(_vSide);
		m_tmpMt.vectorMult3x3(_vUp);
		m_tmpMt.vectorMult3x3(_vOut);
		// --
		_vRotation.y = p_nAngle;
		return p_nAngle;
	}

	/**
	 * @private
	 */
	public var rotateY(__getRotateY,__setRotateY):Null<Float>;
	private function __getRotateY():Null<Float>
	{
		return _vRotation.y;
	}

	/**
	 * Rotates this object around an axis paralell to the parents z axis.
	 *
	 * <p>The object rotates a specified angle ( degrees ) around an axis through the
	 * objects reference point, paralell to the z axis of the parent frame.</p>
	 */
	private function __setRotateZ ( p_nAngle:Null<Float> ):Null<Float>
	{
		var l_nAngle:Null<Float> = (p_nAngle - _vRotation.z );
		if(l_nAngle == 0 ) return null;
		changed = true;
		// --
		m_tmpMt.rotationZ( l_nAngle );
		m_tmpMt.vectorMult3x3(_vSide);
		m_tmpMt.vectorMult3x3(_vUp);
		m_tmpMt.vectorMult3x3(_vOut);
		// --
		_vRotation.z = p_nAngle;
		return p_nAngle;
	}

	/**
	 * @private
	 */
	public var rotateZ(__getRotateZ,__setRotateZ):Null<Float>;
	private function __getRotateZ():Null<Float>
	{
		return _vRotation.z;
	}

	/**
	 * Rolls this object around the local z axis.
	 *
	 * <p>The roll angle interval is -180 to +180 degrees<br/>
	 * At 0 degrees the local x axis is aligned with the horizon of its parent<br/>
	 * Full roll right = 180 and full roll left = -180 degrees ( upside down ).</p>
	 *
	 * @param p_nAngle 	The roll angle in degrees.
	 */
	private function __setRoll ( p_nAngle:Null<Float> ):Null<Float>
	{
		var l_nAngle:Null<Float> = (p_nAngle - _nRoll);
		if(l_nAngle == 0 ) return null;
		changed = true;
		// --
		m_tmpMt.axisRotation ( _vOut.x, _vOut.y, _vOut.z, l_nAngle );
		m_tmpMt.vectorMult3x3(_vSide);
		m_tmpMt.vectorMult3x3(_vUp);
		// --
		_nRoll = p_nAngle;
		return p_nAngle;
	}

	/**
	 * @private
	 */
	public var roll(__getRoll,__setRoll):Null<Float>;
	private function __getRoll():Null<Float>
	{
		return _nRoll;
	}

	/**
	 * Tilts this object around the local x axis.
	 *
	 * <p>The tilt angle interval is -90 to +90 degrees<br/>
	 * At 0 degrees the local z axis is paralell to the zx plane of its parent coordinate system.<br/>
	 * Straight up = +90 and stright down = -90 degrees.</p>
	 *
	 * @param p_nAngle 	The tilt angle in degrees.
	 */
	private function __setTilt ( p_nAngle:Null<Float> ):Null<Float>
	{
		var l_nAngle:Null<Float> = (p_nAngle - _nTilt);
		if(l_nAngle == 0 ) return null;
		changed = true;
		// --
		m_tmpMt.axisRotation ( _vSide.x, _vSide.y, _vSide.z, l_nAngle );
		m_tmpMt.vectorMult3x3(_vOut);
		m_tmpMt.vectorMult3x3(_vUp);
		// --
		_nTilt = p_nAngle;
		return p_nAngle;
	}

	/**
	 * Getter for the tilt value
	 */
	public var tilt(__getTilt,__setTilt):Null<Float>;
	private function __getTilt():Null<Float>
	{
		return _nTilt;
	}

	/**
	 * Pans this object around the local y axis.
	 *
	 * <p>The pan angle interval is 0 to 360 degrees<br/>
	 * Directions within the parent frame are: North = 0, East = 90, South = 180 nad West = 270 degrees.</p>
	 *
	 * @param p_nAngle 	The pan angle in degrees.
	 */
	private function __setPan ( p_nAngle:Null<Float> ):Null<Float>
	{
		var l_nAngle:Null<Float> = (p_nAngle - _nYaw);
		if(l_nAngle == 0 ) return null;
		changed = true;
		// --
		m_tmpMt.axisRotation ( _vUp.x, _vUp.y, _vUp.z, l_nAngle );
		m_tmpMt.vectorMult3x3(_vOut);
		m_tmpMt.vectorMult3x3(_vSide);
		// --
		_nYaw = p_nAngle;
		return p_nAngle;
	}

	/**
	 * @private
	 */
	public var pan(__getPan,__setPan):Null<Float>;
	private function __getPan():Null<Float>
	{
		return _nYaw;
	}

	/**
	 * Sets the position of this object in coordinates of its parent frame.
	 *
	 * @param p_nX 	The x coordinate
	 * @param p_nY 	The y coordiante
	 * @param p_nZ 	The z coordiante
	 */
	public function setPosition( p_nX:Null<Float>, p_nY:Null<Float>, p_nZ:Null<Float> ):Void
	{
		changed = true;
		// we must consider the screen y-axis inversion
		_p.x = p_nX;
		_p.y = p_nY;
		_p.z = p_nZ;
	}
	
	/**
	 * Updates this node or object.
	 *
	 * <p>For node's with transformation, this method updates the transformation taking into account the matrix cache system.<br/>
	 * <b>FIXME<b>: Transformable nodes shall upate their transform if necessary before calling this method.</p>
	 *
	 * @param p_oScene The current scene
	 * @param p_oModelMatrix The matrix which represents the parent model matrix. Basically it stores the rotation/translation/scale of all the nodes above the current one.
	 * @param p_bChanged	A boolean value which specify if the state has changed since the previous rendering. If false, we save some matrix multiplication process.
	 */
	public override function update( p_oScene:Scene3D, p_oModelMatrix:Matrix4, p_bChanged:Null<Bool> ):Void
	{
		updateTransform();
		// --
		if( p_bChanged || changed )
		{
			 if( p_oModelMatrix != null && !disable )
			 {
				modelMatrix.copy(p_oModelMatrix);
				modelMatrix.multiply4x3( m_oMatrix );
			 }
			 else
			 {
				modelMatrix.copy( m_oMatrix );
			 }
		}
		// --
		super.update( p_oScene, modelMatrix, p_bChanged );
	}

	/**
	 * Updates the transform matrix of the current object/node before it is rendered.
	 */
	public function updateTransform():Void
	{
		if( changed )
		{
			m_oMatrix.n11 = _vSide.x * _oScale.x;
			m_oMatrix.n12 = _vUp.x * _oScale.y;
			m_oMatrix.n13 = _vOut.x * _oScale.z;
			m_oMatrix.n14 = _p.x;

			m_oMatrix.n21 = _vSide.y * _oScale.x;
			m_oMatrix.n22 = _vUp.y * _oScale.y;
			m_oMatrix.n23 = _vOut.y * _oScale.z;
			m_oMatrix.n24 = _p.y;

			m_oMatrix.n31 = _vSide.z * _oScale.x;
			m_oMatrix.n32 = _vUp.z * _oScale.y;
			m_oMatrix.n33 = _vOut.z * _oScale.z;
			m_oMatrix.n34 = _p.z;

			//m_oMatrix.n41 = m_oMatrix.n42 = m_oMatrix.n43 = 0;
			//m_oMatrix.n44 = 1;
		}
	}

	/**
	 * Returns the position of this group or object.
	 *
	 * <p>Choose which coordinate system the returned position refers to, by passing a mode string:<br/>
	 * The position is returned as a vector in one of the following:<br/>
	 * If "local", the position is coordinates of the parent frame.
	 * If "absolute" the position is in world coordinates
	 * If "camera" the position is relative to the camera's coordinate system.
	 * Default value is "local"
	 *
	 * @return 	The position of the group or object
	 */
	public function getPosition( ?p_sMode:String ):Vector
	{
		var l_oPos:Vector;

		p_sMode = (p_sMode != null)?p_sMode:"local";

		switch( p_sMode )
		{
			case "local" 	: l_oPos = new Vector( _p.x, _p.y, _p.z ); 
			case "camera" : l_oPos = new Vector( viewMatrix.n14, viewMatrix.n24, viewMatrix.n34 ); 
			case "absolute" 	: l_oPos = new Vector( modelMatrix.n14, modelMatrix.n24, modelMatrix.n34 ); 
			default 		: l_oPos = new Vector( _p.x, _p.y, _p.z ); 
		}
		return l_oPos;
	}

	/**
	 * Returns a string representation of this object
	 *
	 * @return	The fully qualified name of this class
	 */
	public override function toString():String
	{
	    	return "sandy.core.scenegraph.ATransformable";
	}
	//
	private var m_oMatrix:Matrix4;
	// Side Orientation Vector
	private var _vSide:Vector;
	// view Orientation Vector
	private var _vOut:Vector;
	// up Orientation Vector
	private var _vUp:Vector;
	// current tilt value
	private var _nTilt:Null<Float>;
	// current yaw value
	private var _nYaw:Null<Float>;
	// current roll value
	private var _nRoll:Null<Float>;
	private var _vRotation:Vector;
	private var _vLookatDown:Vector; // Private absolute down vector
	private var _p:Vector;
	private var _oScale:Vector;
	private var m_tmpMt:Matrix4; // temporary transform matrix used at updateTransform
	private var m_oPreviousOffsetRotation:Vector;
}

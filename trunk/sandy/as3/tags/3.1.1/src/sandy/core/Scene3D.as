﻿package sandy.core
	import sandy.core.data.Pool;
	import sandy.core.light.Light3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.events.SandyEvent;

	import flash.display.Sprite;
	import flash.events.EventDispatcher;

	 * The Sandy 3D scene.
	 *
	 * <p>Supercedes deprecated World3D class.</p>
	 *
	 * <p>The Scene3D object is the central point of a Sandy scene.<br/>
	 * You can have multiple scenes.<br/>
	 * A scene contains the object tree with groups, a camera, a light source and a canvas to draw on</p>
	 *
	 * @example	To create the scene, you invoke the Scene3D constructor, passing it the base movie clip, the camera, and the root group for the scene.<br/>
	 * The rendering of the scene is driven by a "heart beat", which may be a Timer or the Event.ENTER_FRAME event.
	 *
	 * The following pseudo-code approximates the necessary steps. It is very approximate and not meant as a working example:
	 * <listing version="3.0.3">
	 * 		var cam:Camera = new Camera3D(600, 450, 45, 0, 2000); // camera viewport height,width, fov, near plane, and far plane
	 *		var mc:MovieClip = someSceneHoldingMovieClip;  // Programmer must ensure it is a valid movie clip.
	 *		var rootGroup = new Group("world_root_group");
	 *		// Add some child objects to the world (not shown), perhaps as follows
	 *		//rootGroup.addChild(someChild);
	 *		// Create the scene and render it
	 *     	var myScene:Scene3D = new Scene3D("scene_name", mc, cam, rootGroup);
	 *		myScene.render();
	 *	//The enterFrameHandler presumably calls the myScene.render() method to render the scene for each frame.
	 *	yourMovieRoot.addEventListener( Event.ENTER_FRAME, enterFrameHandler );
	 *  </listing>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.1
	 * @date 		25.08.2008
	 */
	public class Scene3D extends EventDispatcher
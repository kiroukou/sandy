package sandy.core.scenegraph 
{	import sandy.core.Scene3D;	
	
	/**	 * @author thomas	 */	public interface Renderable 
	{
		function render( p_oScene:Scene3D, p_oCamera:Camera3D ):void;
			}}
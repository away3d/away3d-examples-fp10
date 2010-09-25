package
{
	import away3d.debug.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.lights.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	
	[SWF(width="800", height="600", frameRate="60", backgroundColor="0x000000")]
	public class Advanced_PixelShaders extends Sprite
	{
		[Embed(source="assets/torso_marble256.jpg")]
		private var _texture : Class;
		
		[Embed(source="assets/torso_normal_256.jpg")]
		private var _normalMap : Class;
		
		[Embed(source="assets/torsov2.MD2", mimeType="application/octet-stream")]
		private var Model : Class;
		
		private var _mesh : Mesh;
		private var _view : View3D;
		private var _light : PointLight3D;
		private var _light2 : PointLight3D;
		
		private var _count : Number = 0;
		
		private var _centerZ : Number;
		
		private var _ambient : AmbientLight3D;
		
		public function Advanced_PixelShaders()
		{
			var dir : DirectionalLight3D;
			_mesh = Md2.parse(new Model());
			_mesh.scale(0.075);
			_mesh.material = new PhongMultiPassMaterial(	(new _texture() as Bitmap).bitmapData,
															(new _normalMap() as Bitmap).bitmapData,
															_mesh, null,
															{	gloss: 5, 
																specular: 1, 
																smooth: true
															}
														);

			_view = new View3D({x: stage.stageWidth*.5, y : stage.stageHeight*.5, stats: false});
			_view.scene.addChild(_mesh);
			addChild(_view);
			
			_centerZ = (_mesh.maxZ + _mesh.minZ)*_mesh.scaleZ*.5;
			
			_light = new PointLight3D({color: 0xff3333, debug: false, brightness: 1});
			_light2 = new PointLight3D({color: 0x0000ff, debug: false, brightness: 1});
			_ambient = new AmbientLight3D({color: 0x0c0c22});
			dir = new DirectionalLight3D({color: 0xffffdd});
			dir.direction = new Vector3D(0, 5000, 1155);
			
			_view.scene.addLight(_light);
			_view.scene.addLight(_light2);
			_view.scene.addLight(_ambient);
			_view.scene.addLight(dir);
			
			_light.radius = 300;
			_light.fallOff = 1000;
			_light2.radius = 300;
			_light2.fallOff = 320;
			
			addChild(new AwayStats(_view));
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event : Event) : void
		{
			var mx : Number = 3*(2*mouseX-stage.stageWidth)/stage.stageWidth;
			//var my : Number = 3*(2*mouseY-stage.stageHeight)/stage.stageHeight;
			_count += .05;

			_light.x = Math.sin(_count)*200;
			_light.y = Math.cos(_count*.33)*200;
			_light.z = Math.cos(_count)*500+_centerZ;
			
			_light2.x = Math.sin(_count*.75)*500;
			_light2.y = Math.cos(_count)*300;
			_light2.z = Math.cos(_count*1.2)*100+_centerZ;

			_view.camera.x = Math.sin(mx)*1000;
			_view.camera.z = -Math.cos(mx)*1000+_centerZ;
			_view.camera.y = (stage.stageHeight*.5-mouseY)*5;
			_view.camera.lookAt(new Vector3D(0, 0, _centerZ));

			_view.render();
		}
	}
}
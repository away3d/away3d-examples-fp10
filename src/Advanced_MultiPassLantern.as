/*

Flash 10 Pixel Bender shaders example in Away3d

Demonstrates:

How to use the multi-pass and single-pass pass phong Pixel Bender shader on a mesh
The advantage of using detailed normal and specular maps

Code and textures by David Lenaerts
http://www.derschmale.com

Model by Fabrice Closier
http://www.closier.nl/

This code is distributed under the MIT License

Copyright (c) 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package
{
	import away3d.debug.AwayStats;
	import AS3s.*;
	
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.materials.utils.*;
	import away3d.primitives.*;
	import away3d.primitives.utils.*;
	import away3d.sprites.*;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(width="800", height="600", frameRate="30", backgroundColor="0x000000")]
	public class Advanced_MultiPassLantern extends Sprite
	{
		/**
		 * All the assets used in this demo
		 */
		[Embed(source="assets/skybox/negX.jpg")]
		private var _left : Class;
		
		[Embed(source="assets/skybox/posX.jpg")]
		private var _right : Class;
		
		[Embed(source="assets/skybox/posY.jpg")]
		private var _top : Class;
		
		[Embed(source="assets/skybox/negY.jpg")]
		private var _bottom : Class;
		
		[Embed(source="assets/skybox/posZ.jpg")]
		private var _back : Class;
		
		[Embed(source="assets/skybox/negZ.jpg")]
		private var _front : Class;
		
		[Embed(source="assets/lanternDiffuse.jpg")]
		private var _texture : Class;
		
		[Embed(source="assets/lanternSpecular.jpg")]
		private var _specularMap : Class;
		
		[Embed(source="assets/lanternNormal.png")]
		private var _normalMap : Class;
		
		[Embed(source="assets/floorDiffuse.png")]
		private var _grass : Class;
		
		[Embed(source="assets/floorSpecular.jpg")]
		private var _grassSpecular : Class;
		
		[Embed(source="assets/floorNormal.jpg")]
		private var _grassNormal : Class;
		
		[Embed(source="assets/firefly.png")]
		private var _fireFlyTexture : Class;
		
		// the 3D view
		private var _view : View3D;
		
		// models used
		private var _container : Lantern;
		private var _lanternMesh : Mesh;
		private var _floorMesh : Mesh;
		private var _fireFly : MovieClipSprite;
		private var _flame : MovieClipSprite;
		
		// lights used in the scene
		private var _light : PointLight3D;
		private var _light2 : PointLight3D;
		private var _ambient : AmbientLight3D;
		private var _directional : DirectionalLight3D;
		
		// used for hovering light
		private var _count : Number = 0;
		
		private var _hiQual : Boolean = false;
		
		private var _sign : Bitmap;
		
		private var _origin : Number3D = new Number3D();
		
		public function Advanced_MultiPassLantern()
		{
			stage.quality = StageQuality.LOW;
			initView();
			initSkyBox();
			initLights();
			initMaterials();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			addChild(new AwayStats(_view));
		}
		
		private function onClick(event : MouseEvent) : void
		{
			_hiQual = !_hiQual;
			if (_hiQual)
				stage.quality = StageQuality.HIGH;
			else
				stage.quality = StageQuality.LOW;
		}
		
		private function initView() : void
		{
			_view = new View3D({x: stage.stageWidth*.5, y : stage.stageHeight*.5});
			_view.addSourceURL("srcview/index.html");
			addChild(_view);
			
			_container = new Lantern();
			_container.scaleX = _container.scaleY = _container.scaleZ = 22;
			_floorMesh = _container.meshes[1];
			_lanternMesh = _container.meshes[0];
		 	_container.x += 30;
			_container.y += _lanternMesh.minY*_container.scaleY;
			_container.rotationY = 180;
			_view.scene.addChild(_container);
			
			// the flame
			_flame = new MovieClipSprite(new FireAsset());
			_flame.y = 100;
			_flame.movieClip.scaleY = 0.4; 
			_view.scene.addSprite(_flame);
			
			// firefly
			_fireFly = new MovieClipSprite(new _fireFlyTexture());
			_view.scene.addSprite(_fireFly);
			
			// set camera
			_view.camera.z = 1500;
			
			showSig();
		}
		
		private function showSig() : void
		{
			var spr : signature = new signature();
			var bmd : BitmapData = new BitmapData(spr.width, spr.height, true, 0x00000000);
			stage.quality = StageQuality.HIGH;
			bmd.draw(spr);
			stage.quality = StageQuality.LOW;
			_sign = new Bitmap(bmd);
			addChild(_sign);
			_sign.y = stage.stageHeight-(_sign.height);
		}
		
		private function initSkyBox() : void
		{
			// assign face textures to array
			var faces : Array = [];
			faces[CubeFaces.LEFT] = new _left().bitmapData;
			faces[CubeFaces.RIGHT] = new _right().bitmapData;
			faces[CubeFaces.FRONT] = new _front().bitmapData;
			faces[CubeFaces.BACK] = new _back().bitmapData;
			faces[CubeFaces.TOP] = new _top().bitmapData;
			faces[CubeFaces.BOTTOM] = new _bottom().bitmapData;
			
			// create skybox
			var skybox : Skybox = new Skybox( 	new BitmapMaterial(faces[CubeFaces.BACK]),
												new BitmapMaterial(faces[CubeFaces.LEFT]),
												new BitmapMaterial(faces[CubeFaces.FRONT]),
												new BitmapMaterial(faces[CubeFaces.RIGHT]),
												new BitmapMaterial(faces[CubeFaces.TOP]),
												new BitmapMaterial(faces[CubeFaces.BOTTOM])
											);
			skybox.scale(0.005);
			skybox.rotationY = 180;
			_view.scene.addChild(skybox);
		}
		
		private function initLights() : void
		{
			// the green rotating light
			_light = new PointLight3D({color: 0x338055, debug: false});
			// the flame light
			_light2 = new PointLight3D({color: 0xeb9134, debug: false});
			// some blue global lighting to generate nightly feel 
			_ambient = new AmbientLight3D({color: 0x100720});
			// moonlight pointing to lantern
			_directional = new DirectionalLight3D({color: 0xd8e8ff});
			_directional.direction = new Number3D(0, 3000, -5000);
			
			// add green light first, since it will be used for the single pass diffuse material
			_view.scene.addLight(_light);
			_view.scene.addLight(_light2);
			_view.scene.addLight(_ambient);
			_view.scene.addLight(_directional);
			
			//_light.brightness = 1;
			_light.radius = 300;
			_light.fallOff = 1000;
			_light2.radius = 300;
			_light2.fallOff = 1000;
			_light2.z = 50;
			_light2.y = 100;
		}
		
		private function initMaterials() : void
		{
			// multiple lights hitting the surface
			_lanternMesh.material = new PhongMultiPassMaterial(	new _texture().bitmapData,
															new _normalMap().bitmapData,
															_lanternMesh,
															null,
															{	gloss: 5, 
																specular: 2,
																smooth: true
															}
														);
			// only rendering green light for the floor
			_floorMesh.material = new PhongPBMaterial(	new _grass().bitmapData,
													TangentToObjectMapper.transform(new _grassNormal().bitmapData, _floorMesh, true),
													_floorMesh,
													new _grassSpecular().bitmapData,
													{	gloss: 1,
														specular: 1,
														smooth: true
													 }
												);
			
		}
		
		private function onEnterFrame(event : Event) : void
		{
			
			var mx : Number = 3*(2*mouseX-stage.stageWidth)/stage.stageWidth;
			//var my : Number = 3*(2*mouseY-stage.stageHeight)/stage.stageHeight;
			var offsetY : Number = _lanternMesh.minY*_lanternMesh.scaleY;
			_count += .1;
			
			// move light around
			_fireFly.x = _light.x = Math.sin(_count)*300;
			_fireFly.y = _light.y = (1+Math.cos(_count*.5))*100+offsetY+30;
			_fireFly.z = _light.z = Math.cos(_count*.698)*500;
			_fireFly.movieClip.alpha = _light.brightness = .75+Math.cos(_count)*.25;
			
			// flickering flame
			_light2.brightness = .5+Math.random();
			
			// move camera according to mouse
			_view.camera.x = (Math.sin(mx)*1500+_view.camera.x)*.5;
			_view.camera.y = (Math.max((stage.stageHeight*.5-mouseY)*5, offsetY+50)+_view.camera.y)*.5;
			_view.camera.z = (Math.cos(mx)*1500+_view.camera.z)*.5;
			_view.camera.lookAt(_origin);

			_view.render();
		}
	}
}

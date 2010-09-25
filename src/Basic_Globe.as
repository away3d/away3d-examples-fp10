/*

Globe example in Away3d

Demonstrates:

How to create a textured sphere.
How to use containers to rotate an object.
How to use the PhongBitmapMaterial.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

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
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.utils.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Basic_Globe extends Sprite
	{
		//texture for globe
		[Embed(source="assets/earth512.png")]
    	public static var EarthImage:Class;
		
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
    	
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material:PhongBitmapMaterial;
		
		//scene objects
		private var sphere:Sphere;
		private var spherecontainer:ObjectContainer3D;
		
		//light objects
		private var light:DirectionalLight3D;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var lastRotationX:Number;
		private var lastRotationY:Number;
		
		/**
		 * Constructor
		 */
		public function Basic_Globe() 
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initMaterials();
			initObjects();
			initLights();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			
			//camera = new Camera3D({z:-1000});
			camera = new Camera3D();
			camera.z = -1000;
			
			//view = new View3D({scene:scene, camera:camera});
			view = new View3D();
			view.scene= scene;
			view.camera = camera;
			
			view.addSourceURL("srcview/index.html");
			addChild(view);
			
			//add signature
            Signature = Sprite(new SignatureSwf());
            SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
            stage.quality = StageQuality.HIGH;
            SignatureBitmap.bitmapData.draw(Signature);
            stage.quality = StageQuality.LOW;
            addChild(SignatureBitmap);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			//material = new PhongBitmapMaterial(Cast.bitmap(EarthImage), {specular:0x1A1A1A, shininess:10});
			material = new PhongBitmapMaterial(Cast.bitmap(EarthImage));
			material.specular = 0x1A1A1A;
			material.shininess = 10;
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//sphere = new Sphere({material:material, radius:200, segmentsW:40, segmentsH:20});
			sphere = new Sphere();
			sphere.material = material;
			sphere.radius = 200;
			sphere.segmentsW = 40;
			sphere.segmentsH = 20;
			
			spherecontainer = new ObjectContainer3D(sphere);
			scene.addChild(spherecontainer);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			//light = new DirectionalLight3D({x:1, y:1, z:-1, ambient:0.2});
			light = new DirectionalLight3D();
			light.direction = new Vector3D(-1, -1, 1);
			light.ambient = 0.2;
			
			scene.addLight(light);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(e:Event):void
		{
			sphere.rotationY += 0.2;
			
			if (move) {
				spherecontainer.rotationX = (mouseY - lastMouseY)/2 + lastRotationX;
				if (spherecontainer.rotationX > 90)
					spherecontainer.rotationX = 90;
				if (spherecontainer.rotationX < -90)
					spherecontainer.rotationX = -90;
				sphere.rotationY = (lastMouseX - mouseX)/2 + lastRotationY;
			}
			
			view.render();
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseDown(e:MouseEvent):void
		{
			lastRotationX = spherecontainer.rotationX;
			lastRotationY = sphere.rotationY;
			lastMouseX = mouseX;
			lastMouseY = mouseY;
			move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseUp(e:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);    
		}
        
		/**
		 * Mouse stage leave listener for navigation
		 */
        private function onStageMouseLeave(event:Event):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
		}
	}
}
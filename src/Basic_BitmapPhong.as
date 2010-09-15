/*

Phong material example in Away3d using PhongBitmapMaterial

Demonstrates:

How to use the PhongBitmapMaterial with multiple lights.

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
	import away3d.debug.*;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW", width="800", height="600")]
	
	public class Basic_BitmapPhong extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
		//cube texture jpg
		[Embed(source="assets/blue.jpg")]
    	public static var BlueImage:Class;
    	
    	//sphere texture jpg
		[Embed(source="assets/green.jpg")]
    	public static var GreenImage:Class;
    	
    	//torus texture jpg
    	[Embed(source="assets/red.jpg")]
    	public static var RedImage:Class;
    	
    	//plane texture jpg
    	[Embed(source="assets/yellow.jpg")]
    	public static var YellowImage:Class;
    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var planeMaterial:BitmapMaterial;
		private var sphereMaterial:PhongBitmapMaterial;
		private var cubeMaterial:PhongBitmapMaterial;
		private var torusMaterial:PhongBitmapMaterial;
		
		//light objects
		private var light1:DirectionalLight3D;
		private var light2:DirectionalLight3D;
		
		//scene objects
		private var plane:Plane;
		private var sphere:Sphere;
		private var cube:Cube;
		private var torus:Torus;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Basic_BitmapPhong()
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
			initLights();
			initObjects();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			//camera = new HoverCamera3D({focus:50, distance:1000, mintiltangle:0, maxtiltangle:90});
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.distance = 1000;
			camera.minTiltAngle = 0;
			camera.maxTiltAngle = 90;
			
			camera.panAngle = 45;
			camera.tiltAngle = 20;
			camera.hover(true);
			
			//view = new View3D({scene:scene, camera:camera});
			view = new View3D();
			view.scene = scene;
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
            addChild(new AwayStats());
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			//planeMaterial = new BitmapMaterial(Cast.bitmap(YellowImage), {precision:2.5});
			planeMaterial = new BitmapMaterial(Cast.bitmap(YellowImage));
			
			//sphereMaterial = new PhongBitmapMaterial(Cast.bitmap(GreenImage), {shininess:20, specular:0x5A5A5A});
			sphereMaterial = new PhongBitmapMaterial(Cast.bitmap(GreenImage), {surfaceCache:true});
			sphereMaterial.shininess = 20;
			sphereMaterial.specular = 0x5A5A5A;
			
			cubeMaterial = new PhongBitmapMaterial(Cast.bitmap(BlueImage), {surfaceCache:true});
			cubeMaterial.specular = 0xB3B3B3;
			
			torusMaterial = new PhongBitmapMaterial(Cast.bitmap(RedImage), {surfaceCache:true});
			torusMaterial.specular = 0xB3B3B3;
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			//light1 = new DirectionalLight3D({y:1, ambient:0.1, diffuse:0.7});
			light1 = new DirectionalLight3D();
			light1.direction = new Number3D(0, -1, 0);
			light1.ambient = 0.1;
			light1.diffuse = 0.7;
			
			scene.addLight(light1);
			
			//light2 = new DirectionalLight3D({y:1, color:0x00FFFF, ambient:0.1, diffuse:0.7});
			light2 = new DirectionalLight3D();
			light2.direction = new Number3D(0, -1, 0);
			light2.color = 0x00FFFF;
			light2.ambient = 0.1;
			light2.diffuse = 0.7;
			
			scene.addLight(light2);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//plane = new Plane({material:planeMaterial, y:-20, width:1000, height:1000, pushback:true});
			plane = new Plane();
			plane.material = planeMaterial;
			plane.y = -20;
			plane.width = 1000;
			plane.height = 1000;
			plane.pushback = true;
			
			scene.addChild(plane);
			
	        //sphere = new Sphere({ownCanvas:true, material:sphereMaterial, x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:10});
	        sphere = new Sphere();
	        sphere.ownCanvas = true;
	        sphere.material = sphereMaterial;
	        sphere.x = 300;
	        sphere.y = 160;
	        sphere.z = 300;
	        sphere.radius = 150;
	        sphere.segmentsW = 12;
	        sphere.segmentsH = 10;
	        
			scene.addChild(sphere);
			
	        //cube = new Cube({ownCanvas:true, material:cubeMaterial, x:300, y:160, z:-80, width:200, height:200, depth:200});
	        cube = new Cube();
	        cube.ownCanvas = true;
	        cube.material = cubeMaterial;
	        cube.x = 300;
	        cube.y = 160;
	        cube.z = -80;
	        cube.width = 200;
	        cube.height = 200;
	        cube.depth = 200;
	        
			scene.addChild(cube);
			
	        //torus = new Torus({ownCanvas:true, material:torusMaterial, x:-250, y:160, z:-250, radius:150, tube:60, segmentsR:12, segmentsT:10});
	        torus = new Torus();
	        torus.ownCanvas = true;
	        torus.material = torusMaterial;
	        torus.x = -250;
	        torus.y = 160;
	        torus.z = -250;
	        torus.radius = 150;
	        torus.tube = 60;
	        torus.segmentsR = 12;
	        torus.segmentsT = 10;
	        
			scene.addChild(torus);
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
		private function onEnterFrame(event:Event):void
		{
			tick(getTimer());
			
			if (move) {
				camera.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			camera.hover();  
			view.render();
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
        {
            lastPanAngle = camera.panAngle;
			lastTiltAngle = camera.tiltAngle;
			lastMouseX = stage.mouseX;
            lastMouseY = stage.mouseY;
        	move = true;
        	stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
		
		/**
		 * Mouse up listener for navigation
		 */
        private function onMouseUp(event:MouseEvent):void
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
		 * Stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
		}
	    
	    /**
	    * Updates every frame
	    */
        private function tick(time:int):void
	    {
	        cube.rotationY += 2;
	        
	    	light1.direction = new Number3D(-Math.cos(time/2000), 0, -Math.sin(time/2000));
	    }
	}
}
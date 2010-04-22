/*

Flat shading example in Away3d

Demonstrates:

How to use the PointLight3D light source.
How to apply multiple light sources to a ShadingColorMaterial.
How to create a ripple effect on a Plane object.

Code by Rob Bateman & Alexander Zadorozhny
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
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.clip.RectangleClipping;
	import away3d.core.utils.Cast;
	import away3d.lights.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Basic_Shading extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public static var SignatureSwf:Class;
    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material:ShadingColorMaterial;
		
		//scene objects
		private var plane:Plane;
		private var light1:PointLight3D;
		private var light2:PointLight3D;
		private var light3:PointLight3D;
		
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Basic_Shading()
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
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			
			//camera = new HoverCamera3D({zoom:10, focus:50, distance:1000, minTiltAngle:-80, maxTiltAngle:90, panAngle:-90, tiltAngle:20});
			camera = new HoverCamera3D();
			camera.zoom = 10;
			camera.focus = 50;
			camera.distance = 1000;
			camera.minTiltAngle = -80;
			camera.maxTiltAngle = 90;
			camera.panAngle = -90;
			camera.tiltAngle = 20;
			camera.hover(true);
			
			//view = new View3D({scene:scene, camera:camera});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			
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
			material = new ShadingColorMaterial(0xFFFFFF, {diffuse:0xFFFFFF, specular:0xFFFFFF, alpha:1});
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//plane = new Plane({material:material, y:-100, width:1000, height:1000, segments:16});
			plane = new Plane();
			plane.material = material;
			plane.y = -100;
			plane.width = 1000;
			plane.height = 1000;
			plane.segmentsW = 16;
			plane.segmentsH = 16;
			scene.addChild(plane);
			
			//light1 = new PointLight3D({color:0xFF0000, ambient:0.5, diffuse:0.5, specular:1, brightness:1000, debug:true});
			light1 = new PointLight3D();
			light1.color = 0xFF0000;
			light1.ambient = 0;
			light1.diffuse = 0.5;
			light1.specular = 1;
			light1.brightness = 1;
			light1.debug = true;
			scene.addLight(light1);
			
	        //light2 = new PointLight3D({color:0x808000, ambient:0.5, diffuse:0.5, specular:1, brightness:1000, debug:true});
	        light2 = new PointLight3D();
	        light2.color = 0x808000;
	        light2.ambient = 0;
	        light2.diffuse = 0.5;
	        light2.specular = 1;
	        light2.brightness = 1;
	        light2.debug = true;
			scene.addLight(light2);
			
	        //light3 = new PointLight3D({color:0x0000FF, ambient:0.5, diffuse:0.5, specular:1, brightness:1000, debug:true});
	        light3 = new PointLight3D();
	        light3.color = 0x0000FF;
	        light3.ambient = 0;
	        light3.diffuse = 0.5;
	        light3.specular = 1;
	        light3.brightness = 1;
	        light3.debug = true;
			scene.addLight(light3);
			
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
		
		private function onMouseDown(event:MouseEvent):void
        {
            lastPanAngle = camera.panAngle;
			lastTiltAngle = camera.tiltAngle;
			lastMouseX = stage.mouseX;
            lastMouseY = stage.mouseY;
        	move = true;
        	stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
		
        private function onMouseUp(event:MouseEvent):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
        
        private function onStageMouseLeave(event:Event):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
        
        private function tick(time:int):void
	    {
	        for (var x:int = 0; x <= 16; x++)
	            for (var y:int = 0; y <= 16; y++)
	                plane.vertex(x, y).y = 50*Math.sin(dist(x-16/2*Math.sin(time/5000), y-16/2*Math.cos(time/7000))/2+time/500);
			
	        light1.x = 600*Math.sin(time/5000) + 200*Math.sin(time/6000) + 200*Math.sin(time/7000);
	        light1.z = 400*Math.cos(time/5000) + 500*Math.cos(time/6000) + 100*Math.cos(time/7000);
	        light1.y = 400 + 100*Math.sin(time/10000);
			
	        light2.x = 400*Math.sin(time/5500) + 400*Math.sin(time/4000) + 200*Math.sin(time/5000);
	        light2.z = 400*Math.cos(time/5500) + 500*Math.cos(time/4000) + 100*Math.cos(time/5000);
	        light2.y = 400 + 100*Math.sin(time/11000);
			
	        light3.x = 300*Math.sin(time/3000) + 200*Math.sin(time/6500) + 300*Math.sin(time/4000);
	        light3.z = 100*Math.cos(time/3000) + 300*Math.cos(time/6500) + 600*Math.cos(time/4000);
	        light3.y = 400 + 100*Math.sin(time/12000);
	    }
    	
        private function dist(dx:Number, dy:Number):Number
	    {
	        return Math.sqrt(dx*dx + dy*dy);
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
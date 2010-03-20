/*

Filters example in Away3d

Demonstrates:

How to use the filters property of a 3d object.
How to use the ownCanvas property of a 3d object.

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
﻿
package
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Basic_FlashFilters extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
    	//sphere texture jpg
		[Embed(source="assets/blue.jpg")]
		private var Blue:Class;
		
		//torus texture jpg
		[Embed(source="assets/red.jpg")]
		private var Red:Class;
		
		//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var sphereMaterial:BitmapMaterial;
		private var torusMaterial:BitmapMaterial;
		
		//scene objects
		private var container:ObjectContainer3D;
		private var sphere:Sphere;
		private var sphere1:Sphere;
		private var sphere2:Sphere;
		private var sphere3:Sphere;
		private var sphere4:Sphere;
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
		public function Basic_FlashFilters()
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
			
			//camera = new HoverCamera3D({distance:2000});
			camera = new HoverCamera3D();
			camera.distance = 2000;
			
			camera.panAngle= 45;
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
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			sphereMaterial = new BitmapMaterial(Cast.bitmap(Blue));
			
			torusMaterial = new BitmapMaterial(Cast.bitmap(Red));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			var filter1:BevelFilter = new BevelFilter(10, 45, 0xFFFFFF, 0.5, 0x000000, 0.5, 10, 10, 50);
			var filter2:GlowFilter = new GlowFilter(0xFFFFFF, 1, 50, 50);
			var filter3:GlowFilter = new GlowFilter(0xFF0000, 1, 50, 50);
			
			//container = new ObjectContainer3D({ownCanvas:true, filters:[filter1]});
			container = new ObjectContainer3D();
			container.ownCanvas = true;
			container.filters = [filter1];
			
			scene.addChild(container);
			
			//sphere = new Sphere({ownCanvas:true, filters:[filter2], material:sphereMaterial, radius:150, segmentsW:12, segmentsH:9});
			sphere = new Sphere();
			sphere.ownCanvas = true;
			sphere.filters = [filter2];
			sphere.material = sphereMaterial;
			sphere.radius = 150;
			sphere.segmentsW = 12;
			sphere.segmentsH = 9;
			
			container.addChild(sphere);
			
	    	//sphere1 = new Sphere({ownCanvas:true, filters:[filter3], material:sphereMaterial, x:200, radius:40});
	    	sphere1 = new Sphere();
			sphere1.ownCanvas = true;
			sphere1.filters = [filter3];
			sphere1.material = sphereMaterial;
			sphere1.x = 200;
			sphere1.radius = 40;
			
	    	container.addChild(sphere1);
	    	
	    	//sphere2 = new Sphere({ownCanvas:true, filters:[filter3], material:sphereMaterial, x:-200, radius:40});
	    	sphere2 = new Sphere();
			sphere2.ownCanvas = true;
			sphere2.filters = [filter3];
			sphere2.material = sphereMaterial;
			sphere2.x = -200;
			sphere2.radius = 40;
			
			container.addChild(sphere2);
			
	    	//sphere3 = new Sphere({ownCanvas:true, filters:[filter3], material:sphereMaterial, z:200, radius:40});
	    	sphere3 = new Sphere();
			sphere3.ownCanvas = true;
			sphere3.filters = [filter3];
			sphere3.material = sphereMaterial;
			sphere3.z = 200;
			sphere3.radius = 40;
			
	    	container.addChild(sphere3);
	    	
	    	//sphere4 = new Sphere({ownCanvas:true, filters:[filter3], material:sphereMaterial, z:-200, radius:40});
	    	sphere4 = new Sphere();
			sphere4.ownCanvas = true;
			sphere4.filters = [filter3];
			sphere4.material = sphereMaterial;
			sphere4.z = -200;
			sphere4.radius = 40;
			
	    	container.addChild(sphere4);
	    	
	    	//torus = new Torus({material:torusMaterial, radius:400, tube:100, segmentsR:20, segmentsT:8});
	    	torus = new Torus();
	    	torus.material = torusMaterial;
	    	torus.radius = 400;
	    	torus.tube = 100;
	    	torus.segmentsR = 20;
	    	torus.segmentsT = 8;
	    	
	    	container.addChild(torus);
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
	}
}
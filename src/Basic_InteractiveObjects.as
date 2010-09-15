/*

Object interaction example in Away3d using the mouse

Demonstrates:

How to use the MouseEvent3D listeners.
How to use the fog filter to provide depth shading on a mesh.

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
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.filter.*;
	import away3d.core.render.*;
	import away3d.debug.*;
	import away3d.events.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW", width="800", height="600")]
	
	public class Basic_InteractiveObjects extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
		//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var fogfilter:FogFilter;
		private var renderer:BasicRenderer;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
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
		public function Basic_InteractiveObjects()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */		
		private function init():void
		{
			initEngine();
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
			
			//fogfilter = new FogFilter({material:new ColorMaterial(0x000000), minZ:500, maxZ:2000});
			fogfilter = new FogFilter();
			fogfilter.material = new ColorMaterial(0x000000);
			fogfilter.minZ = 500;
			fogfilter.maxZ = 2000;
			
			renderer = new BasicRenderer(fogfilter);
			
			//view = new View3D({scene:scene, camera:camera, renderer:renderer});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.renderer = renderer;
			
			view.addSourceURL("srcview/index.html");
			addChild(view);
			
			//add signature
            Signature = Sprite(new SignatureSwf());
            SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
            stage.quality = StageQuality.HIGH;
            SignatureBitmap.bitmapData.draw(Signature);
            stage.quality = StageQuality.LOW;
            addChild(SignatureBitmap);
            
            addChild(new AwayStats(view));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//plane = new Plane({y:-20, width:1000, height:1000, pushback:true, segmentsW:20, segmentsH:20});
			plane = new Plane();
			plane.y = -20;
			plane.width = 1000;
			plane.height = 1000;
			plane.pushback = true;
			plane.segmentsW = 20;
			plane.segmentsH = 20;
			
			scene.addChild(plane);
			
	        //sphere = new Sphere({x:300, y:160, z:300, radius:150, segmentsW:12, segmentsH:10});
	        sphere = new Sphere();
	        sphere.x = 300;
	        sphere.y = 160;
	        sphere.z = 300;
	        sphere.radius = 150;
	        sphere.segmentsW = 12;
	        sphere.segmentsH = 10;
	        
			scene.addChild(sphere);
			
	        //cube = new Cube({x:300, y:160, z:-80, width:200, height:200, depth:200});
	        cube = new Cube();
	        cube.x = 300;
	        cube.y = 160;
	        cube.z = -80;
	        cube.width = 200;
	        cube.height = 200;
	        cube.depth = 200;
	        
			scene.addChild(cube);
			
	        //torus = new Torus({x:-250, y:160, z:-250, radius:150, tube:60, segmentsR:12, segmentsT:10});
	        torus = new Torus();
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
			//scene.addOnMouseUp(onSceneMouseUp);
			scene.addEventListener(MouseEvent3D.MOUSE_UP, onSceneMouseUp);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Mouse up listener for the 3d scene
		 */
	    private function onSceneMouseUp(e:MouseEvent3D):void
	    {
	        if (e.object is Mesh) {
	            var mesh:Mesh = e.object as Mesh;
	            mesh.material = new WireColorMaterial();
	        }
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
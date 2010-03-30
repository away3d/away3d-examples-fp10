/*

Z-sort intersection correction example in Away3d

Demonstrates:

How to use the Renderer class to correct z-sort  artifacts with intersecting objects.

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
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Intermediate_ZSortCorrection extends Sprite
	{
		//brick texture for floor
		[Embed(source="assets/brick.jpg")]
		private var Brick1:Class;
		
		//brick texture for spheres
		[Embed(source="assets/brick2.jpg")]
		private var Brick2:Class;
    	
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public static var SignatureSwf:Class;
    	
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var planeMaterial:BitmapMaterial;
		private var sphereMaterial:BitmapMaterial;
		
		//scene objects
		private var plane:Plane;
		private var container:ObjectContainer3D;
		private var sphere1:Sphere;
		private var sphere2:Sphere;
		
		/**
		 * Constructor
		 */
		public function Intermediate_ZSortCorrection() 
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
			
			//camera = new Camera3D({focus:50, y:-500, z:-250});
			camera = new Camera3D();
			camera.focus = 50;
			camera.y = -500;
			camera.z = -250;
			
			camera.lookAt(scene.position);
			
			//view = new View3D({scene:scene, camera:camera, renderer:Renderer.INTERSECTING_OBJECTS});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.renderer = Renderer.INTERSECTING_OBJECTS;
			
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
			planeMaterial = new BitmapMaterial(Cast.bitmap(Brick1));
			
			sphereMaterial = new BitmapMaterial(Cast.bitmap(Brick2));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//plane = new Plane({material:planeMaterial, width:500, height:500, segmentsW:4, segmentsH:4, yUp:false});
			plane = new Plane();
			plane.material = planeMaterial;
			plane.width = 500;
			plane.height = 500;
			plane.segmentsW = 4;
			plane.segmentsH = 4;
			plane.yUp = false;
			
			scene.addChild(plane);
			
			//sphere1 = new Sphere({material:sphereMaterial, radius:50, x:100, y:100});
			sphere1 = new Sphere();
			sphere1.material = sphereMaterial;
			sphere1.radius = 50;
			sphere1.x = 100;
			sphere1.y = 100;
			
			//sphere2 = new Sphere({material:sphereMaterial, radius:50, x:-100, y:-100});
			sphere2 = new Sphere();
			sphere2.material = sphereMaterial;
			sphere2.radius = 50;
			sphere2.x = -100;
			sphere2.y = -100;
			
			//container = new ObjectContainer3D({z:-100}, sphere1, sphere2);
			container = new ObjectContainer3D(sphere1, sphere2);
			container.z = -100;
			
			scene.addChild(container);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame( e:Event ):void
		{
			plane.rotationZ += 2;
			container.rotationX += 2;
			view.render();
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
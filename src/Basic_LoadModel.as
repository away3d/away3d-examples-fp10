/*

3ds file loading example in Away3d

Demonstrates:

How to use the Loader3D object to load and parse an external 3ds model.
How to extract material data and use it to set materials on a model.
how to access the children of a loaded 3ds model.

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
	import away3d.debug.AwayStats;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.loaders.*;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW", width="800", height="600")]
	
	public class Basic_LoadModel extends Sprite
	{
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
		
		//ferrari texture
		[Embed(source="assets/fskingr.jpg")]
		private var GreenPaint:Class;
		
		//ferrari texture
		[Embed(source="assets/fskin.jpg")]
		private var RedPaint:Class;
				
		//ferrari texture
		[Embed(source="assets/fskiny.jpg")]
		private var YellowPaint:Class;
				
		//ferrari texture
		[Embed(source="assets/fsking.jpg")]
		private var GreyPaint:Class;
		
		//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var materialArray:Array;
		private var materialIndex:int = 0;
		
		//scene objects
		private var max3ds:Max3DS;
		private var loader:LoaderCube;
		private var model:ObjectContainer3D;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Basic_LoadModel()
		{
			Debug.active = true;
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
			
			camera = new HoverCamera3D();
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
            
            addChild(new AwayStats(view));
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			materialArray = [Cast.material(GreenPaint), Cast.material(RedPaint), Cast.material(YellowPaint), Cast.material(GreyPaint)];
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//loader = Max3DS.load("assets/f360.3ds", {loadersize:200, centerMeshes:true, material:materialArray[materialIndex]}) as LoaderCube;
			max3ds = new Max3DS();
			max3ds.centerMeshes = true;
			max3ds.material = materialArray[materialIndex];
			
			loader = new LoaderCube();
			loader.loaderSize = 200;
			loader.addOnSuccess(onSuccess);
			loader.loadGeometry("assets/f360.3ds", max3ds);
			
			scene.addChild(loader);
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
			loader.handle.rotationY += 2;
			
			if (move) {
				camera.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			//rotate the wheels
			if (model) {
				for each (var object:Object3D in model.children) {
					//object.debugbb = true;
					if (object.name.indexOf("wheel") != -1)
						object.rotationX += 10;
				}
			}
			
			camera.hover();
			view.render();
		}
				
		/**
		 * Listener function for loading complete event on loader
		 */
		private function onSuccess(event:Event):void
		{
			model = loader.handle as ObjectContainer3D;
			model.scale(100);
			
			model.rotationX = 90;
			
			//model.addOnMouseUp(onClickModel);
			model.addEventListener(MouseEvent3D.MOUSE_UP, onClickModel);
		}
		
		/**
		 * Listener function for mouse click on car
		 */
		private function onClickModel(event:MouseEvent3D):void
		{
			materialIndex++;
			if (materialIndex > materialArray.length - 1)
				materialIndex = 0;
			
			model.materialLibrary.getMaterial("fskin").material = materialArray[materialIndex];
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
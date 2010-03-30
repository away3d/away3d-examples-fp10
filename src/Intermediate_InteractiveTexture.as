/*

Texture interaction example in Away3d using the mouse

Demonstrates:

How to use an interactive  MovieMaterial.
How to load a swf into flex retaining the contained actionscript.

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
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="HIGH", width="800", height="600")]
	
	public class Intermediate_InteractiveTexture extends Sprite
	{
		[Embed(source="assets/interactiveTexture.swf", mimeType="application/octet-stream")]
		private var InteractiveTexture:Class;
    	
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
		//loader for interactive form swf
		private var loader:Loader;
		
    	//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		
		//form variables
		private var SymbolClass:Class;
		private var SymbolInstance:Sprite;
		
		//material objects
		private var material:MovieMaterial;
		
		//scene objects
		private var plane:Plane;
		
		//navigation variables
		private var rotateSpeed:Number = 1;
		private var upFlag:Boolean = false;
		private var downFlag:Boolean = false;
		private var leftFlag:Boolean = false;
		private var rightFlag:Boolean = false;
		
		/**
		 * Constructor
		 */
		public function Intermediate_InteractiveTexture()
		{
			stage.quality = StageQuality.HIGH;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
			loader.loadBytes(new InteractiveTexture());
		}
		
		/**
		 * Global initialise function
		 */
		private function init(e:Event):void
		{
			initForm();
			initEngine();
			initMaterials();
			initObjects();
			initListeners();
		}
		
		/**
		 * Initialise the form
		 */
		private function initForm():void
		{
			SymbolClass = loader.contentLoaderInfo.applicationDomain.getDefinition("formUI") as Class;
			SymbolInstance = new SymbolClass() as Sprite;
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
			view.scene = scene;
			view.camera = camera;
			
			view.addSourceURL("srcview/index.html");
			addChild(view);
						
			//add signature
            Signature = Sprite(new SignatureSwf());
            addChild(Signature);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			//material = new MovieMaterial(SymbolInstance, {interactive:true, smooth:true});
			material = new MovieMaterial(SymbolInstance);
			material.interactive = true;
			material.smooth = true;
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//plane = new Plane({material:material, width:500, height:500, segmentsW:4, segmentsH:4, yUp:false, bothsides:true});
			plane = new Plane();
			plane.material = material;
			plane.width = 500;
			plane.height = 500;
			plane.segmentsW = 4;
			plane.segmentsH = 4;
			plane.yUp = false;
			plane.bothsides = true;
			
			plane.pitch(-20);
			plane.yaw(20);
			plane.roll(10);
		 	scene.addChild(plane);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (upFlag)
				plane.pitch(rotateSpeed);
			if (downFlag)
				plane.pitch(-rotateSpeed);
			if (leftFlag)
				plane.yaw(rotateSpeed);
			if (rightFlag)
				plane.yaw(-rotateSpeed);
			view.render();
		}
		
		/**
		 * Key down listener for navigation
		 */
		private function keyDownHandler(e:KeyboardEvent):void {
			switch(e.keyCode)
			{
				case Keyboard.UP:
					upFlag = true;
					break;
				case Keyboard.DOWN:
					downFlag = true;
					break;
				case Keyboard.LEFT:
					leftFlag = true;
					break;
				case Keyboard.RIGHT: 
					rightFlag = true;
					break;
				default:
			}
		}
		
		/**
		 * Key up listener for navigation
		 */
		private function keyUpHandler(e:KeyboardEvent):void {
			switch(e.keyCode)
			{
				case Keyboard.UP:
					upFlag = false;
					break;
				case Keyboard.DOWN:
					downFlag = false;
					break;
				case Keyboard.LEFT:
					leftFlag = false;
					break;
				case Keyboard.RIGHT: 
					rightFlag = false;
					break;
				default:
			}
		}
        
        /**
		 * Stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            Signature.y = stage.stageHeight - Signature.height;
		}
	}
}
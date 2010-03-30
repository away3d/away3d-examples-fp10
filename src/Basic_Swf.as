/*

Basic swf import example in Away3d

Demonstrates:

How to import vector graphics into Away3d from a swf file.
How to animate a mesh using the as3dmodlibrary.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

Graphics by Kevin Flahaut
http://www.rocketgenius.com

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
	import away3d.loaders.Swf;
	
	import com.as3dmod.*;
	import com.as3dmod.modifiers.*;
	import com.as3dmod.plugins.away3d.*;
	import com.as3dmod.util.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Basic_Swf extends Sprite
	{
    	//signature swf
    	[Embed(source="assets/signature_li.swf", symbol="Signature")]
    	public static var SignatureSwf:Class;
    	
    	//vector assets swf
    	[Embed(source="assets/vectorScene.swf", mimeType="application/octet-stream")]
		public var SwfBytes:Class;
		
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//scene objects
		private var swf:ObjectContainer3D;
		
		//modifier objects
		private var modStack:ModifierStack;
		private var bendMod:Bend;
		
		/**
		 * Constructor
		 */
		public function Basic_Swf() 
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
			initBend();
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
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			swf = Swf.parse(SwfBytes);
			swf.x = -1024/2;
			swf.y = 768/2;
			
			scene.addChild(swf);
		}
		
		/**
		 * Initialise the bend modifier
		 */
		private function initBend():void
		{
			//swf.children[0].debugbb = true;
			modStack = new ModifierStack(new LibraryAway3d(), swf.children[0]);
			bendMod = new Bend(0, 0.4, Math.PI/2);
			
			bendMod.constraint = ModConstant.RIGHT;
			modStack.addModifier(bendMod);
			modStack.apply();
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
		private function onEnterFrame(event:Event):void
		{
			hoverCamera();
			updateBend();
			view.render();
		}
		
		/**
		 * Update method for camera position
		 */
		private function hoverCamera():void
		{
			var mX:Number = this.mouseX > 0 ? this.mouseX : 0;
			var mY:Number = this.mouseY > 0 ? this.mouseY : 0;
			
			var tarX:Number = 3*(mX - stage.stageWidth/2);
			var tarY:Number = -2*(mY - stage.stageHeight/2);
			
			var dX:Number = camera.x - tarX;
			var dY:Number = camera.y - tarY;
			
			camera.x -= dX*0.25;
			camera.y -= dY*0.25;
			
			camera.lookAt(scene.position);
		}
		
		/**
		 * Update method for bend modifier
		 */
		private function updateBend():void
		{
			bendMod.force = Math.sin(getTimer()/200);
			modStack.apply();
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
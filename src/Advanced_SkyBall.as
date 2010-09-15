/*

Texture layering example in Away3d

Demonstrates:

How to project a texture using the projectionVector property of the TransformBitmapMaterial.
How to use a spherical panorama texture to create a skysphere.
How to use the surfaceCache property of the CompositeMaterial.

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
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.debug.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Advanced_SkyBall extends Sprite
	{
		[Embed(source="assets/sky.jpg")]
		private var Sky:Class;
		
		[Embed(source="assets/smiley.gif")]
		public static var SmileyImage:Class;
		
		//signature swf
		[Embed(source="assets/signature.swf", symbol="Signature")]
		private var SignatureSwf:Class;
		
		//engine variables
		private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var skyMaterial:BitmapMaterial;
		private var sphereMaterial:CompositeMaterial;
		private var projectedMaterialArray:Array = new Array();
		private var projectedMaterial:TransformBitmapMaterial;
		
		//projection vairables
		private var projectionNum:int = 6;
		private var projectionVectorArray:Array = new Array();
		private var projectionVector:Number3D;
		
		//scene objects
		private var skysphere:Sphere;
		private var innersphere:Sphere;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */				
		public function Advanced_SkyBall() 
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
			
			//camera = new HoverCamera3D({zoom:10, focus:40, minTiltAngle:-80, maxTiltAngle:20, panAngle:90, tiltAngle});
			camera = new HoverCamera3D();
			camera.zoom = 10;
			camera.focus = 40;
			camera.minTiltAngle = -80;
			camera.maxTiltAngle = 20;
			camera.panAngle = 90;
			camera.tiltAngle = 0;
			
			//view = new View3D({scene:scene, camera:camera});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			
			view.addSourceURL("srcview/index.html");
			addChild(view);
			
			addChild(new AwayStats(view));
			
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
			skyMaterial = new BitmapMaterial(Cast.bitmap(Sky));
			
			//sphereMaterial = new CompositeMaterial({width:1024, height:512, materials:[Cast.material(Sky)], surfaceCache:true});
			sphereMaterial = new CompositeMaterial();
			sphereMaterial.width = 1024;
			sphereMaterial.height = 512;
			sphereMaterial.surfaceCache = true;
			sphereMaterial.addMaterial(new BitmapMaterial(Cast.bitmap(Sky)));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//skysphere = new Sphere({material:skyMaterial, radius:50000, rotationX:180, segmentsW:10, segmentsH:12});
			skysphere = new Sphere();
			skysphere.material = skyMaterial;
			skysphere.radius = 50000;
			skysphere.rotationX = 180;
			skysphere.segmentsW = 10;
			skysphere.segmentsH = 12;
			skysphere.scale(-1);
			scene.addChild(skysphere);
			
			//innersphere = new Sphere({material:sphereMaterial, radius:250, segmentsW:10, segmentsH:12});
			innersphere = new Sphere();
			innersphere.material = sphereMaterial;
			innersphere.radius = 250;
			innersphere.segmentsW = 10;
			innersphere.segmentsH = 12;
			scene.addChild(innersphere);
			
			var i:int = projectionNum;
			while (i--) {
				//projectedMaterial = new TransformBitmapMaterial(Cast.bitmap(SmileyImage), {throughProjection:true});
				projectedMaterial = new TransformBitmapMaterial(Cast.bitmap(SmileyImage));
				projectedMaterial.throughProjection = true;
				sphereMaterial.addMaterial(projectedMaterial);
				projectedMaterialArray.push(projectedMaterial);
				projectionVectorArray.push(new Number3D());
			}
			
			i = projectionNum;
			var time:int = getTimer();
			while (i--) {
				projectionVector = projectionVectorArray[i];
				projectedMaterial = projectedMaterialArray[i];
				switch(i)
				{
					case 0:
						projectionVector.x = (Math.sin(time/500));
						projectionVector.y = 1;
						projectionVector.z = (Math.cos(time/500));
						projectedMaterial.rotation = time/1000;
						break;
					case 1:
						projectionVector.x = (Math.cos(-time/500));
						projectionVector.y = (Math.sin(time/500));
						projectionVector.z = 1;
						projectedMaterial.rotation = time/500;
						break;
					case 2:
						projectionVector.x = 1;
						projectionVector.y = (Math.sin(-time/500));
						projectionVector.z = (Math.cos(-time/500));
						projectedMaterial.rotation = time/250;
						break;
					case 3:
						projectionVector.x = (Math.cos(-time/500));
						projectionVector.y = 1;
						projectionVector.z = (Math.sin(-time/500));
						projectedMaterial.rotation = time/125;
						break;
					case 4:
						projectionVector.x = 1;
						projectionVector.y = (Math.cos(-time/500));
						projectionVector.z = (Math.sin(-time/500));
						projectedMaterial.rotation = time/75;
						break;
					case 5:
						projectionVector.x = 1;
						projectionVector.y = (Math.sin(time/500));
						projectionVector.z = (Math.cos(-time/500));
						projectedMaterial.rotation = time/250;
				}
				projectedMaterial.projectionVector = projectionVector;
			}
		}
		
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
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
			
			var i:int = projectionNum;
			var time:int = getTimer();
			while (i--) {
				projectionVector = projectionVectorArray[i];
				projectedMaterial = projectedMaterialArray[i];
				switch(i)
				{
					case 0:
						projectionVector.x = (Math.sin(time/500));
						projectionVector.y = 1;
						projectionVector.z = (Math.cos(time/500));
						projectedMaterial.rotation = time/1000;
						break;
					case 1:
						projectionVector.x = (Math.cos(-time/500));
						projectionVector.y = (Math.sin(time/500));
						projectionVector.z = 1;
						projectedMaterial.rotation = time/500;
						break;
					case 2:
						projectionVector.x = 1;
						projectionVector.y = (Math.sin(-time/500));
						projectionVector.z = (Math.cos(-time/500));
						projectedMaterial.rotation = time/250;
						break;
					case 3:
						projectionVector.x = (Math.cos(-time/500));
						projectionVector.y = 1;
						projectionVector.z = (Math.sin(-time/500));
						projectedMaterial.rotation = time/125;
						break;
					case 4:
						projectionVector.x = 1;
						projectionVector.y = (Math.cos(-time/500));
						projectionVector.z = (Math.sin(-time/500));
						projectedMaterial.rotation = time/75;
						break;
					case 5:
						projectionVector.x = 1;
						projectionVector.y = (Math.sin(time/500));
						projectionVector.z = (Math.cos(-time/500));
						projectedMaterial.rotation = time/250;
				}
				projectedMaterial.projectionVector = projectionVector;
			}
			
			camera.hover();  
			view.render();
		}
		
		/**
		 * Mouse up listener for navigation
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
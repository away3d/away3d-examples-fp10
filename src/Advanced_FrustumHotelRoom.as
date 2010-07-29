/*

Frustum clipping example in Away3d

Demonstrates:

How to use FrustumClipping and NearfieldClipping to the best effect.
How to correctively z-sort individual objects
How to use the precision property to achive perspective correct textures
How to create a 2d collision detection system

code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

Design by Dave Stewart
http://davestewart.co.uk/

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
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.debug.*;
	import away3d.events.*;
	import away3d.loaders.*;
	import away3d.loaders.data.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.ui.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	 
	public class Advanced_FrustumHotelRoom extends Sprite
	{
		static private var toRADIANS:Number = Math.PI / 180;
		
    	//signature swf
    	[Embed(source="assets/signature_dave.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
    	
    	//collision map
    	[Embed(source="assets/room/collision.png")]
		private var CollisionBitmap:Class;
		
    	//engine variables
    	private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var clipping:Clipping;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var tvMaterial:BitmapMaterial;
		private var materialData:MaterialData;
		
		//scene objects
		private var loader:LoaderCube;
		private var max3ds:Max3DS;
		private var model:ObjectContainer3D;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var upFlag:Boolean = false;
		private var downFlag:Boolean = false;
		private var leftFlag:Boolean = false;
		private var rightFlag:Boolean = false;
		private var cameraForwardSpeed:Number = 0;
		private var cameraForwardAcc:Number = 2;
		private var cameraForwardDrag:Number = 0.3;
		private var cameraRightSpeed:Number = 0;
		private var cameraRightAcc:Number = 2;
		private var cameraRightDrag:Number = 0.3;
		private var forwardVector:Number3D = new Number3D();
		private var rightVector:Number3D = new Number3D();
		private var tiltangle:Number = 0;
		private var panangle:Number = -100;
		private var target:Number3D = new Number3D();
		
		//collision varaibles
		private var collisionBitmap:BitmapData;
		private var sampleBitmap:BitmapData;
		private var sampleRect:Rectangle = new Rectangle();
		private var samplePoint:Point = new Point();
		private var collisionRect:Rectangle;
		private var cameraX:Number;
		private var cameraY:Number;
		private var collisionShape:Shape = new Shape();
		private var collisionVector:Point = new Point();
		private var collisionMatrix:Matrix = new Matrix();
		private var collisionDot:Number;
		private var collisionDistance:Number = 30;
		
		//misc variables
		private var debugPrecise:Boolean = false;
		private var preciseMaterials:Array = [];
		private var material:BitmapMaterial;
		private var sortObjects:Boolean = true;
		private var sortedObjects:Array = [];
		private var object:Object3D;
		private var text:TextField;
		
		/**
		 * Constructor
		 */
		public function Advanced_FrustumHotelRoom()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initLoaders();
			initCollisionBitmap();
			initText();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			Debug.active = true;
			scene = new Scene3D();
			
			//clipping = new FrustumClipping({minZ:10});
			clipping = new FrustumClipping();
			clipping.minZ = 10;
			
			//camera = new Camera3D({zoom:6, focus:100, x:176, z:54, lens:new PerspectiveLens()});
			camera = new Camera3D();
			camera.zoom = 6;
			camera.x = 176;
			camera.z = 54;
			camera.lens = new PerspectiveLens();
			
			//view = new View3D({scene:scene, camera:camera, clipping:clipping});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.clipping = clipping;
			
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
		private function initLoaders():void
		{
			//loader = Max3DS.load("assets/room/interior.3ds", {loadersize:40, centerMeshes:true}) as LoaderCube;
			loader = new LoaderCube();
			loader.loaderSize = 40;
			max3ds = new Max3DS();
			max3ds.centerMeshes = true;
			loader.loadGeometry("assets/room/interior.3ds", max3ds);
			
			//loader.addOnSuccess(onSuccess);
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			
			scene.addChild(loader);
		}
		
		/**
		 * Listener function for loading complete event on loader
		 */
		private function onSuccess(event:Event):void
		{
			initModel();
			initMaterials();
			initObjects();
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initModel():void
		{
			model = loader.handle as ObjectContainer3D;
			model.rotationX = 90;
			model.y = -80;
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			for each (materialData in model.materialLibrary) {
				if (materialData.name == "baked_Mati_re5" ||
					materialData.name == "Speaker_" ||
					materialData.name == "Ivory" ||
					materialData.name == "Ivory3" ||
					materialData.name == "_Snow_1" || 
					materialData.name == "baked__Snow_11" || 
					materialData.name == "baked__Snow_1" || 
					materialData.name == "orig__Snow_12" || 
					materialData.name == "SaddleBr1" || 
					materialData.name == "Mati_re81") {
					preciseMaterials.push(materialData.material);
				} else if (materialData.name == "Charcoal") {
					tvMaterial = new BitmapMaterial(materialData.textureBitmap);
					preciseMaterials.push(tvMaterial);
				}
			}
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			var pivot:Number3D;
			var mesh:Mesh;
			for each (var child:Object3D in model.children)
			{
				if (child.name == "wall_l" || child.name == "wall_b" || child.name == "wall_r") {
					child.pushback = true;
					child.ownCanvas = true;
				} else if (child.name == "wall_f") {
					child.pushback = true;
				} else if (child.name == "Bedside " || child.name == "TV Cabin" || child.name == "TV") {
					if (child.name == "TV") {
						mesh = (child as Mesh);
						(mesh.faces[52] as Face).material = tvMaterial;
						(mesh.faces[53] as Face).material = tvMaterial;
					}
					//child.debugbs = true;
					child.ownCanvas = true;
					child.renderer = Renderer.CORRECT_Z_ORDER;
					sortedObjects.push(child);
				} else if (child.name == "Door01") {
					child.pushfront = true;
				} else if (child.name == "Bed") {
					child.pushfront = true;
				} else if (child.name == "matress") {
					child.pushfront = true;
					child.ownCanvas = true;
					pivot = new Number3D(0, -20, 0);
					pivot.transform(pivot, child.transform);
					child.pivotPoint = pivot;
					child.moveTo(child.x, child.y - 20, child.z);
				} else if (child.name == "Pillows") {
					child.pushfront = true;
					child.ownCanvas = true;
					pivot = new Number3D(0, -90, 0);
					pivot.transform(pivot, child.transform);
					child.pivotPoint = pivot;
					child.moveTo(child.x, child.y - 90, child.z);
				} else if (child.name == "Lampsma" || child.name == "books" || child.name == "plant" || child.name == "picture" || child.name == "alarm") {
					if (child.name == "books" || child.name == "plant") {
						pivot = new Number3D(0, 0, 20);
						pivot.transform(pivot, child.transform);
						child.pivotPoint = pivot;
						child.moveTo(child.x, child.y, child.z + 20);
					}
					child.pushfront = true;
					child.ownCanvas = true;
				} else if (child.name == "Vase" || child.name == "wineglss") {
					(child as Mesh).bothsides = true;
				} else if (child.name == "Floor") {
					child.pushback = true;
					child.ownCanvas = true;
				}
			}
		}
		
		/**
		 * Create collision map for camera movement
		 */
		private function initCollisionBitmap():void
		{
			collisionBitmap = Cast.bitmap(CollisionBitmap);
			sampleBitmap = new BitmapData(collisionDistance*2, collisionDistance*2, false, 0);
			
			//adding a debug view to the collision detection system
			//var bitmap:Bitmap = new Bitmap(sampleBitmap);
			//addChild(bitmap);
			
			sampleRect = new Rectangle(0, 0, collisionDistance*2, collisionDistance*2);
		}
		
		/**
		 * Create an instructions overlay
		 */
		private function initText():void
		{
			text = new TextField();
			text.defaultTextFormat = new TextFormat("Verdana", 10, 0xFFFFFF);
			text.x = 0;
			text.y = 0;
			text.width = 240;
			text.height = 100;
			text.selectable = false;
			text.mouseEnabled = false;
			text.text = "Mouse click and drag - rotate\n" + 
					"Cursor keys / WSAD - move\n" + 
					"T - toggle debug triangles\n" + 
					"Z - toggle local z-sort correction\n" +
					"F - Frustum Clipping mode (default)\n" + 
					"N - Nearfield Clipping mode\n" + 
					"R - Rectangle Clipping mode\n";
			
			text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			
			addChild(text);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			//perform drag on teh speed of the camera
			cameraForwardSpeed *= (1-cameraForwardDrag);
			cameraRightSpeed *= (1-cameraRightDrag);
			
			//halt camera if below a certain speed
			if (cameraForwardSpeed < 0.01 && cameraForwardSpeed > -0.01)
				cameraForwardSpeed = 0;
			
			if (cameraRightSpeed < 0.01 && cameraRightSpeed > -0.01)
				cameraRightSpeed = 0;
			
			//check key flags
			if (upFlag)
				cameraForwardSpeed += cameraForwardAcc;
			if (downFlag)
				cameraForwardSpeed -= cameraForwardAcc;
			if (rightFlag)
				cameraRightSpeed += cameraRightAcc;
			if (leftFlag)
				cameraRightSpeed -= cameraRightAcc;
			
			//calculate forward & back vector
			forwardVector.rotate(Number3D.FORWARD, camera.transform);
			forwardVector.y = 0;
			forwardVector.normalize();
			camera.x += forwardVector.x*cameraForwardSpeed;
			camera.z += forwardVector.z*cameraForwardSpeed;
			
			//calculate left & right vector
			rightVector.rotate(Number3D.RIGHT, camera.transform);
			rightVector.y = 0;
			rightVector.normalize();
			
			//update camrea position
			camera.x += rightVector.x*cameraRightSpeed;
			camera.z += rightVector.z*cameraRightSpeed;
			
			//update rotation values
			if (move) {
				panangle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				tiltangle = -0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
				
            	if (tiltangle > 70)
            		tiltangle = 70;
            	if (tiltangle < -70)
            		tiltangle = -70;
			}
			
			//check collision
			checkCollisionData();
			
        	//update camera rotation
			target.x = 100 * Math.sin(panangle * toRADIANS) * Math.cos(tiltangle * toRADIANS) + camera.x;
            target.z = 100 * Math.cos(panangle * toRADIANS) * Math.cos(tiltangle * toRADIANS) + camera.z;
            target.y = 100 * Math.sin(tiltangle * toRADIANS) + camera.y;
            camera.lookAt(target);
			
			//render scene
			view.render();
			
			//check movement
			if (!move && !cameraRightSpeed && !cameraForwardSpeed)
				stage.quality = StageQuality.HIGH;
			else
				stage.quality = StageQuality.LOW;
		}
		
		/**
		 * Checks the camera position with the collision bitmap and resolves any collisions
		 */
		private function checkCollisionData():void
		{
			//get camera position on collision map
			cameraX = 350 - camera.x*1.87;
			cameraY = 510 + camera.z*1.87;
			
			//determine position of sample data
			sampleRect.x = int(cameraX - collisionDistance);
			sampleRect.y = int(cameraY - collisionDistance);
			
			//check for collision
			var i:int = collisionDistance + 1;
			do {
				i--;
				collisionRect = sampleBitmap.getColorBoundsRect(0xFFFFFF, 0x000000);
				collisionShape.graphics.clear();
				collisionShape.graphics.beginFill(0x660000);
				collisionShape.graphics.drawCircle(collisionDistance, collisionDistance, i);
				collisionShape.graphics.endFill();
				sampleBitmap.copyPixels(collisionBitmap, sampleRect, samplePoint);
				sampleBitmap.draw(collisionShape, null, null, BlendMode.MULTIPLY);
			} while (sampleBitmap.getColorBoundsRect(0xFFFFFF, 0x000000).width && i > 1);
			
			//resolve collision
			if (i < collisionDistance) {
				//calculate collision normal
				collisionVector.x = collisionRect.x + collisionRect.width/2 - collisionDistance;
				collisionVector.y = collisionRect.y + collisionRect.height/2 - collisionDistance;
				collisionVector.normalize(1);
				
				//update camera position on collision map
				cameraX -= collisionVector.x*(collisionDistance - i);
				cameraY -= collisionVector.y*(collisionDistance - i);
				
				//updata camrea position
				camera.x = (350 - cameraX)/1.87;
				camera.z = (cameraY - 510)/1.87;
				
				//determin collision vector in camera-space
				collisionMatrix.identity();
				collisionMatrix.rotate(panangle * toRADIANS);
				collisionVector.x = -collisionVector.x;
				collisionVector = collisionMatrix.deltaTransformPoint(collisionVector);
				
				//update camera speed
				collisionDot = cameraRightSpeed*collisionVector.x + cameraForwardSpeed*collisionVector.y;
				cameraRightSpeed -= collisionDot*collisionVector.x;
				cameraForwardSpeed -= collisionDot*collisionVector.y;
				
				//re-check collision data
				checkCollisionData();
			}
		}
		
		/**
		 * Mouse down handler for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
        {
            lastPanAngle = panangle;
            lastTiltAngle = tiltangle;
            lastMouseX = stage.mouseX;
            lastMouseY = stage.mouseY;
        	move = true;
        	stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
		
		/**
		 * Mouse up handler for navigation
		 */
        private function onMouseUp(event:MouseEvent):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
        
        /**
        * Key down handler for key controls
        */
        private function onKeyDown(e:KeyboardEvent):void {
			switch(e.keyCode)
			{
				case Keyboard.UP:
				case "W".charCodeAt():
					upFlag = true;
					break;
				case Keyboard.DOWN:
				case "S".charCodeAt():
					downFlag = true;
					break;
				case Keyboard.LEFT:
				case "A".charCodeAt():
					leftFlag = true;
					break;
				case Keyboard.RIGHT:
				case "D".charCodeAt():
					rightFlag = true;
					break;
				default:
			}
		}
        
        /**
        * Key up handler for key controls
        */
		private function onKeyUp(e:KeyboardEvent):void {
			switch(e.keyCode)
			{
				case Keyboard.UP:
				case "W".charCodeAt():
					upFlag = false;
					break;
				case Keyboard.DOWN:
				case "S".charCodeAt():
					downFlag = false;
					break;
				case Keyboard.LEFT:
				case "A".charCodeAt():
					leftFlag = false;
					break;
				case Keyboard.RIGHT:
				case "D".charCodeAt():
					rightFlag = false;
					break;
				case "T".charCodeAt():
					debugPrecise = !debugPrecise;
					for each (material in preciseMaterials)
						material.debug = debugPrecise;
					break;
				case "Z".charCodeAt():
					sortObjects = !sortObjects;
					for each (object in sortedObjects) {
						if (sortObjects)
							object.renderer = Renderer.CORRECT_Z_ORDER;
						else
							object.renderer = Renderer.BASIC;
					}
					break;
				case "F".charCodeAt():
					//view.clipping = new FrustumClipping({minZ:10});
					view.clipping = new FrustumClipping();
					view.clipping.minZ = 10;
					break;
				case "N".charCodeAt():
					//view.clipping = new NearfieldClipping({minZ:10});
					view.clipping = new NearfieldClipping();
					view.clipping.minZ = 10;
					break;
				case "R".charCodeAt():
					view.clipping = new RectangleClipping();
					break;
				default:
			}
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
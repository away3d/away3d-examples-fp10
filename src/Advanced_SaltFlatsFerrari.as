/*

Blendmodes & tiling materials example in Away3d

Demonstrates:

How to create and scroll a tiling texture using TransformBitmapMaterial.
How to apply blendmodes to 3d objects when ownCanvas is set to true.
how to load and animate a 3DS model.

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
	import away3d.core.base.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	 
	public class Advanced_SaltFlatsFerrari extends Sprite
	{
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
    	
		//cracks texture for desert
		[Embed(source="assets/cracks.jpg")]
    	public var Cracks:Class;
    	
    	//horizon texture for gradient
    	[Embed(source="assets/cracksOverlay.png")]
    	public var CracksOverlay:Class;
    	
    	//skydome texture
    	[Embed(source="assets/morning_preview.jpg")]
    	public var Sky:Class;
		
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
		
		//ferrari mesh
		[Embed(source="assets/f360.3ds", mimeType="application/octet-stream")]
		private var F360:Class;
		
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var materialContainer:CompositeMaterial;
		private var floorMaterial:TransformBitmapMaterial;
		private var overlayMaterial:BitmapMaterial;
		private var skyMaterial:BitmapMaterial;
		private var materialArray:Array;
		private var materialIndex:int = 0;
		
		//scene objects
		private var max3ds:Max3DS;
		private var model:ObjectContainer3D;
		private var floor:RegularPolygon;
		private var sky:Sphere;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Advanced_SaltFlatsFerrari()
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
			
			//camera = new HoverCamera3D({zoom:10, focus:50, distance:800, maxtiltangle:20, mintiltangle:0});
			camera = new HoverCamera3D();
			camera.zoom = 10;
			camera.focus = 50;
			camera.distance = 800;
			camera.maxTiltAngle = 20;
			camera.minTiltAngle = 0;
			
			camera.panAngle = -140;
			camera.tiltAngle = 4;
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
			//floorMaterial = new TransformBitmapMaterial(Cast.bitmap(Cracks), {scaleX:0.05, scaleY:0.05, repeat:true});
			floorMaterial = new TransformBitmapMaterial(Cast.bitmap(Cracks));
			floorMaterial.scaleX = 0.05;
			floorMaterial.scaleY = 0.05;
			floorMaterial.repeat = true;
			
			overlayMaterial = new BitmapMaterial(Cast.bitmap(CracksOverlay));
			
			//materialContainer = new CompositeMaterial({materials:[floorMaterial, overlayMaterial]});
			materialContainer = new CompositeMaterial();
			materialContainer.addMaterial(floorMaterial);
			materialContainer.addMaterial(overlayMaterial);
			
			//create mirrored sky bitmap for sphere texture
			var sky:BitmapData = Cast.bitmap(Sky);
			var skyMirror:BitmapData = new BitmapData(sky.width*2, sky.height*4 - 40, true, 0);
			stage.quality = StageQuality.HIGH;
			skyMirror.draw(sky, new Matrix(2, 0, 0, 2), null, null, new Rectangle(0, 0, sky.width*2, sky.height*2-20), true);
			stage.quality = StageQuality.LOW;
			skyMirror.draw(skyMirror.clone(), new Matrix(1, 0, 0, -1, 0, sky.height*4-40));
			skyMaterial = new BitmapMaterial(Cast.bitmap(skyMirror));
			
			materialArray = [Cast.material(GreenPaint), Cast.material(RedPaint), Cast.material(YellowPaint), Cast.material(GreyPaint)];
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//create ferrari model
			//model = Max3DS.parse(F360, {material:materialArray[materialIndex], ownCanvas:true, centerMeshes:true, pushfront:true, blendMode:BlendMode.HARDLIGHT, rotationX:90, y:-200});
			max3ds = new Max3DS();
			model = max3ds.parseGeometry(F360) as ObjectContainer3D;
			model.materialLibrary.getMaterial("fskin").material = materialArray[materialIndex];
			model.ownCanvas = true;
			model.centerMeshes();
			model.pushfront = true;
			model.blendMode = BlendMode.HARDLIGHT;
			model.rotationX = 90;
			model.y = -200;
			
			model.scale(100);
			scene.addChild(model);
			
			//create floor object
			//floor = new RegularPolygon({material:materialContainer, ownCanvas:true, radius:5000, sides:20, subdivision:20, y:-200, blendMode:BlendMode.MULTIPLY});
			floor = new RegularPolygon();
			floor.material = materialContainer;
			floor.ownCanvas = true;
			floor.radius = 5000;
			floor.sides = 20;
			floor.subdivision = 20;
			floor.y = -200;
			floor.blendMode = BlendMode.MULTIPLY;
			
			scene.addChild(floor);
			
			//create sky object
			//sky = new Sphere({material:skyMaterial, radius:5000, segmentsW:20, segmentsH:12, pushback:true, rotationX:180, y:-200});
			sky = new Sphere();
			sky.material = skyMaterial;
			sky.radius = 5000;
			sky.segmentsW = 20;
			sky.segmentsH = 12;
			sky.pushback = true;
			sky.rotationX = 180;
			sky.y = -200;
			
			sky.scale(-1);
			scene.addChild(sky);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			//model.addOnMouseUp(onClickModel);
			model.addEventListener(MouseEvent3D.MOUSE_UP, onClickModel);
			
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
				camera.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			if (model) {
				for each (var object:Object3D in model.children) {
					if (object.maxY - object.minY < 1)
						object.rotationX += 40;
				}
			}
			
			if (floorMaterial.offsetY < 0)
            	floorMaterial.offsetY += 512;
            
            floorMaterial.offsetY -= 4;
            
			camera.hover();  
			view.render();
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
/*

Texture animation & projection example in Away3d

Demonstrates:

How to use the projectionVector property on TransformBitmapMaterial to project a lightmap onto the surface of a 3d object.
How to use AnimatedBitmapMaterial to cache a looped animation for a texture.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

Models by Peter Kapelyan
flashnine@gmail.com
http://www.flashten.com

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
	import away3d.core.utils.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	import flash.text.*;
	
	[SWF(backgroundColor="#B2DBE6", frameRate="30", quality="LOW", width="800", height="600")]
	 
	public class Advanced_UnderwaterPool extends Sprite
	{
		//tile texture for pool sides
		[Embed(source="assets/bathroomtilegray3.jpg")]
    	public static var PoolTile:Class;
    	
    	//caustics animation for projected texture
    	[Embed(source="assets/caustics.swf", symbol="caustics")]
    	public var Caustics:Class;
    	
    	//Lifering texture
    	[Embed(source="assets/caustics.swf", symbol="lifering")]
    	public var LifeRing:Class;
    	
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
		private var poolTileMaterial:TransformBitmapMaterial;
		private var poolWaterMaterial:AnimatedBitmapMaterial;
		private var poolMaterial:CompositeMaterial;
		private var lifeRingMaterial:TransformBitmapMaterial;
		private var ringMaterial:CompositeMaterial;
		
		//movieclips for animated caustics material
		private var poolCaustics:MovieClip;
		private var poolContainer:MovieClip;
		
		//projection vector value
		private var projectionVector:Vector3D = new Vector3D(0.5, -1, 0.5);
		
		//scene objects
		private var pool:Cube;
		private var ring:Torus;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		//misc variables
		private var debugFlag:Boolean = false;
		private var text:TextField;
		
		/**
		 * Constructor
		 */
		public function Advanced_UnderwaterPool()
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
			initText();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			
			//camera = new HoverCamera3D({focus:50, distance:30000, yfactor:1, maxtiltangle:90, mintiltangle:10});
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.distance = 30000;
			camera.yfactor = 1;
			camera.maxTiltAngle = 90;
			camera.minTiltAngle = 10;
			
			camera.panAngle = 0;
			camera.tiltAngle = 10;
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
			//create transformed tile material for pool sides
			//poolTileMaterial = new TransformBitmapMaterial(Cast.bitmap(PoolTile), {offsetX:-1.2, offsetY:-0.6, scaleX:0.2, scaleY:0.2, repeat:true, precision:1});
			poolTileMaterial = new TransformBitmapMaterial(Cast.bitmap(PoolTile));
			poolTileMaterial.offsetX = -1.2;
			poolTileMaterial.offsetY = -0.6;
			poolTileMaterial.scaleX = 0.2;
			poolTileMaterial.scaleY = 0.2;
			poolTileMaterial.repeat = true;
			
			//create water movieclip with filter applied
			poolCaustics = new Caustics() as MovieClip;
			poolCaustics.filters = [new ColorMatrixFilter([1, 0, 0, 0, 0, 0, 1, 0, 0, 127, 0, 0, 1, 0, 200, 0.25, 0, 0, 0, 64])];
			poolContainer = new MovieClip();
			poolContainer.addChild(poolCaustics);
			
			//create water material
			//poolWaterMaterial = new AnimatedBitmapMaterial(poolContainer, {projectionVector:projectionVector, throughProjection:true, globalProjection:true, repeat:true, scaleX:50, scaleY:50});
			poolWaterMaterial = new AnimatedBitmapMaterial(poolContainer);
			poolWaterMaterial.projectionVector = projectionVector;
			poolWaterMaterial.throughProjection = true;
			poolWaterMaterial.globalProjection = true;
			poolWaterMaterial.repeat = true;
			poolWaterMaterial.scaleX = 50;
			poolWaterMaterial.scaleY = 50;
			
			//add frames manually to animated bitmapmaterial
			var i:int = poolCaustics.totalFrames;
			var frames:Array = new Array();
			var bitmapData:BitmapData;
			while(i--) {
				bitmapData = new BitmapData(256, 256, true, 0);
				poolCaustics.gotoAndStop(i+1);
				bitmapData.draw(poolContainer);
				frames.unshift(bitmapData);
			}
			poolWaterMaterial.setFrames(frames);
			
			//create composite material for pool
			//poolMaterial = new CompositeMaterial({materials:[poolTileMaterial, poolWaterMaterial]});
			poolMaterial = new CompositeMaterial();
			poolMaterial.addMaterial(poolTileMaterial);
			poolMaterial.addMaterial(poolWaterMaterial);
			
			//create transformed lifering material 
			//lifeRingMaterial = new TransformBitmapMaterial(Cast.bitmap(LifeRing), {projectionVector:new Vector3D(0, 1, 0), scaleX:100, scaleY:100, offsetX:-12800, offsetY:-12800, throughProjection:true});
			lifeRingMaterial = new TransformBitmapMaterial(Cast.bitmap(LifeRing));
			lifeRingMaterial.projectionVector = new Vector3D(0, 1, 0);
			lifeRingMaterial.scaleX = 100;
			lifeRingMaterial.scaleY = 100;
			lifeRingMaterial.offsetX = -12800;
			lifeRingMaterial.offsetY = -12800;
			lifeRingMaterial.throughProjection = true;
			
			//create composite material for lifering
			//ringMaterial = new CompositeMaterial({materials:[lifeRingMaterial, poolWaterMaterial]});
			ringMaterial = new CompositeMaterial();
			ringMaterial.addMaterial(lifeRingMaterial);
			ringMaterial.addMaterial(poolWaterMaterial);
        }
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//create pool sides
			//pool = new Cube({material:poolMaterial, width:50000, height:50000, depth:50000, y:10000});
			pool = new Cube();
			pool.material = poolMaterial;
			pool.width = 50000;
			pool.height = 50000;
			pool.depth = 50000;
			pool.y = 10000;
			
			pool.quarterFaces();
			pool.quarterFaces();
			pool.scale(-1);
			scene.addChild(pool);
			
			//create lifering
			//ring = new Torus({ownCanvas:true, material:ringMaterial, radius:6000, tube:2500, segmentsR:20, segmentsT:10});
			ring = new Torus();
			ring.ownCanvas = true;
			ring.material = ringMaterial;
			ring.radius = 6000;
			ring.tube = 2500;
			ring.segmentsR = 20;
			ring.segmentsT = 10;
			
			scene.addChild(ring);
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
					"T - toggle debug triangles\n";
			
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
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
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
            
            ring.rotationX += 3;
            ring.rotationY += 3;
            
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
        * Key up handler for key controls
        */
		private function onKeyUp(e:KeyboardEvent):void {
			switch(e.keyCode)
			{
				case "T".charCodeAt():
					debugFlag = !debugFlag;
					poolTileMaterial.debug = debugFlag;
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
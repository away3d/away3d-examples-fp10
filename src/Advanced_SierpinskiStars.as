/*

Billboard example in Away3d

Demonstrates:

How to use the Billboard element to create fast rendering arrays of particles.
How to create a Sierpinski triangle.

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
	import away3d.animators.data.*;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.sprites.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Point;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Advanced_SierpinskiStars extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
		//star jpg
		[Embed(source="assets/sirius.jpg")]
		private var Star:Class;
		
    	//engine variables
		private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var fogfilter:FogFilter;
		private var renderer:BasicRenderer;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var billboardMaterial:BitmapMaterial;
		
		//scene objects
		private var billboardMesh:Mesh;
		
		//generating objects
		private var toRadians:Number = Math.PI/180;
		private var billboard:Billboard;
		private var billboardObject:BillboardObject;
		private var speedx:Number;
		private var speedy:Number;
		private var speedz:Number;
		private var billboardObjects:Array = new Array();
		private var v1:Vertex;
		private var v2:Vertex;
		private var v3:Vertex;
		private var v4:Vertex;
		
		//navigation variables
		private var move:Boolean = false;
		private var active:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		//spring variables
		private var persp:Number;
		private var billboardVector:Number3D = new Number3D();
		private var mouseVector:Number3D = new Number3D();
		private var mouseDiff:Number3D = new Number3D();
		private var mouseDistance:Number;
		private var mouseMatrix:MatrixAway3D = new MatrixAway3D();
		
		/**
		 * Constructor
		 */
		public function Advanced_SierpinskiStars() 
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
			
			//camera = new HoverCamera3D({distance:1600, yfactor:1, mintiltangle:-45, steps:4});
			camera = new HoverCamera3D();
			camera.distance = 1600;
			camera.yfactor = 1;
			camera.minTiltAngle = -45;
			camera.steps = 4;
			
			camera.panAngle = 285;
			camera.tiltAngle = 10;
			camera.hover(true);
			
			//fogfilter = new FogFilter({material:new ColorMaterial(0x000000), minZ:800, maxZ:4000});
			fogfilter = new FogFilter();
			fogfilter.material = new ColorMaterial(0x000000);
			fogfilter.minZ = 800;
			fogfilter.maxZ = 4000;
			
			renderer = new BasicRenderer(fogfilter);
			
			//view = new View3D({scene:scene, camera:camera, renderer:renderer});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.renderer = renderer;
			
			view.addSourceURL("srcview/index.html");
			addChild( view );
			
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
			
			var star:BitmapData = Cast.bitmap(Star);
			var transstar:BitmapData = new BitmapData(star.width, star.height, true);
			transstar.applyFilter(star, star.rect, new Point(0,0), new ColorMatrixFilter([0, 0, 0, 0, 245, 0, 0, 0, 0, 245, 0, 0, 0, 0, 255, 0.3, 0.3, 0.3, 0, 0]));
			billboardMaterial = new BitmapMaterial( transstar );
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//billboardMesh = new Mesh({material:billboardMaterial});
			billboardMesh = new Mesh();
			billboardMesh.material = billboardMaterial;
			
			billboardMesh.rotate(new Number3D(1, 0, -1), 90 -Math.atan(1/Math.sqrt(2))/toRadians);
			scene.addChild(billboardMesh);
			
			generateSierpinski(5, 500, 0, 0, 0);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			stage.addEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Creates container clones from the turtle mesh
		 */
		private function generateSierpinski(itr:int, size:Number, x:Number, y:Number, z:Number):void
		{
			if (size != 500) {
				billboard = new Billboard(new Vertex(x, y, z), null, 5, 5);
				billboard.scaling = 0.005*size;
				billboardObjects.push(new BillboardObject(billboard, x, y, z, 0, 0, 0));
				billboardMesh.addBillboard(billboard);
			}
			if (itr) {
				itr--;
				size /= 2;
				generateSierpinski(itr, size, x+size, y+size, z+size);
				generateSierpinski(itr, size, x+size, y-size, z-size);
				generateSierpinski(itr, size, x-size, y-size, z+size);
				generateSierpinski(itr, size, x-size, y+size, z-size);
				return;
			}
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame( e:Event ):void
		{
			if (move) {
				camera.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			camera.hover();
			view.render();
			
			persp = camera.zoom/(1 + 1600/camera.focus);
			mouseVector.x = view.mouseX/persp;
			mouseVector.y = view.mouseY/persp;
			mouseVector.z = 1600;
			
			mouseMatrix.clone(view.cameraVarsStore.viewTransformDictionary[billboardMesh]);
			mouseMatrix.inverse(mouseMatrix);
			mouseVector.transform(mouseVector, mouseMatrix);
			
			for each(billboardObject in billboardObjects) {
				billboardVector.x = billboardObject.x;
				billboardVector.y = billboardObject.y;
				billboardVector.z = billboardObject.z;
				if (active) {
					mouseDiff.sub(billboardVector, mouseVector);
					mouseDistance = 5*(10000 + mouseDiff.modulo)/(1000 + mouseDiff.modulo2);
					mouseDiff.scale(mouseDiff, mouseDistance);
				} else {
					mouseDiff.x = 0;
					mouseDiff.y = 0;
					mouseDiff.z = 0;
				}
				billboardObject.speedx *= 0.6;
				billboardObject.speedy *= 0.6;
				billboardObject.speedz *= 0.6;
				speedx = (billboardObject.speedx += (billboardVector.x + mouseDiff.x - billboardObject.billboard.x)/4);
				speedy = (billboardObject.speedy += (billboardVector.y + mouseDiff.y - billboardObject.billboard.y)/4);
				speedz = (billboardObject.speedz += (billboardVector.z + mouseDiff.z - billboardObject.billboard.z)/4);
				
				speedx = speedx < 0 ? -speedx : speedx;
				speedy = speedy < 0 ? -speedy : speedy;
				speedz = speedz < 0 ? -speedz : speedz;
				if (speedx > 0.1 || speedy > 0.1 || speedz > 0.1) {
					billboardObject.billboard.x += (billboardObject.speedx += (billboardVector.x + mouseDiff.x - billboardObject.billboard.x)/4);
					billboardObject.billboard.y += (billboardObject.speedy += (billboardVector.y + mouseDiff.y - billboardObject.billboard.y)/4);
					billboardObject.billboard.z += (billboardObject.speedz += (billboardVector.z + mouseDiff.z - billboardObject.billboard.z)/4);
				}
			}
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
        }
		
		/**
		 * Mouse up listener for navigation
		 */
        private function onMouseUp(event:MouseEvent):void
        {
        	move = false;
        }
        
		/**
		 * Mouse stage leave listener for navigation
		 */
        private function onStageMouseLeave(event:Event):void
        {
        	move = false;
        	active = false;
        }
        
		/**
		 * Mouse stage over listener for navigation
		 */
        private function onStageMouseOver(event:MouseEvent):void
        {
        	active = true;
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

import away3d.core.base.Billboard;

/**
 * Data class for a billboard's position and speed
 */
class BillboardObject
{
	public var billboard:Billboard;
	
	public var x:Number;
	
	public var y:Number;
	
	public var z:Number;
	
	public var speedx:Number;
	
	public var speedy:Number;
	
	public var speedz:Number;
	
	public function BillboardObject(billboard:Billboard, x:Number, y:Number, z:Number, speedx:Number, speedy:Number, speedz:Number)
	{
		this.billboard = billboard;
		this.x = x;
		this.y = y;
		this.z = z;
		this.speedx = speedx;
		this.speedy = speedy;
		this.speedz = speedz;
	}
}
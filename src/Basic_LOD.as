/*

Level Of Detail (LOD) example in Away3d

Demonstrates:

How to use the LOD object to setup different meshes for different levels of detail.

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
	import away3d.core.utils.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Basic_LOD extends Sprite
	{
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
    	
    	//plane texture jpg
		[Embed(source="assets/green.jpg")]
    	public static var GreenImage:Class;
    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var planeMaterial:BitmapMaterial;
		
		//scene objects
		private var plane:Plane;
		private var primitive1:AutoLODPrimitive;
		private var primitive2:AutoLODPrimitive;
		private var primitive3:AutoLODPrimitive;
		private var primitive4:AutoLODPrimitive;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Basic_LOD()
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
			
			//camera = new HoverCamera3D({focus:50, distance:1000, mintiltangle:-90, maxtiltangle:90});
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.distance = 1000;
			camera.minTiltAngle = 10;
			camera.maxTiltAngle = 90;
			
			camera.panAngle = -90;
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
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			planeMaterial = new BitmapMaterial(Cast.bitmap(GreenImage));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//plane = new Plane({material:planeMaterial, y:-100, width:1000, height:1000});
			plane = new Plane();
			plane.material = planeMaterial;
			plane.y = -100;
			plane.width = 1000;
			plane.height = 1000;
			
			scene.addChild(plane);
			
			//primitive1 = new AutoLODPrimitive(0xFF0000, {x:350, y:160, z:350});
			primitive1 = new AutoLODPrimitive(0xFF0000);
			primitive1.x = 350;
			primitive1.y = 160;
			primitive1.z = 350;
			
			scene.addChild(primitive1);
			
            primitive2 = new AutoLODPrimitive(0xFFFF00, {x:350, y:160, z:-350});
            primitive2 = new AutoLODPrimitive(0xFFFF00);
            primitive2.x = 350;
            primitive2.y = 160;
            primitive2.z = -350;
            
			scene.addChild(primitive2);
			
            //primitive3 = new AutoLODPrimitive(0x00FF00, {x:-350, y:160, z:-350});
            primitive3 = new AutoLODPrimitive(0x00FF00);
            primitive3.x = -350;
            primitive3.y = 160;
            primitive3.z = -350;
            
			scene.addChild(primitive3);
			
            //primitive4 = new AutoLODPrimitive(0x0000FF, {x:-350, y:160, z:350});
            primitive4 = new AutoLODPrimitive(0x0000FF);
            primitive4.x = -350;
            primitive4.y = 160;
            primitive4.z = 350;
            
			scene.addChild(primitive4);
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

import away3d.containers.*;
import away3d.primitives.*;
import away3d.materials.*;

/**
 * Class for creating a primitive LOD object
 */
class AutoLODPrimitive extends ObjectContainer3D
{
	/**
	 * Constructor
	 */
    public function AutoLODPrimitive(color:int, init:Object = null)
    {
    	super(init);
    	
        //var primitive0:Plane = new Plane({material:new WireColorMaterial(color), width:300, height:300});
        var primitive0:Plane = new Plane();
        primitive0.material = new WireColorMaterial(color);
        primitive0.width = 300;
        primitive0.height = 300;
        
        //var primitive1:RegularPolygon = new RegularPolygon({material:new WireColorMaterial(color), radius:150});
        var primitive1:RegularPolygon = new RegularPolygon();
        primitive1.material = new WireColorMaterial(color);
        primitive1.radius = 150;
        
        //var primitive2:Cube = new Cube({material:new WireColorMaterial(color), width:300, height:300, depth:300, segmentsW:2, segmentsH:2});
        var primitive2:Cube = new Cube();
        primitive2.material = new WireColorMaterial(color);
        primitive2.width = 300;
        primitive2.height = 300;
        primitive2.depth = 300;
        primitive2.segmentsW = 2;
        primitive2.segmentsH = 2;
        
        //var primitive3:Torus = new Torus({material:new WireColorMaterial(color), radius:150, tube:60, segmentsR:10, segmentsT:8});
        var primitive3:Torus = new Torus();
        primitive3.material = new WireColorMaterial(color);
        primitive3.radius = 150;
        primitive3.tube = 60;
        primitive3.segmentsR = 10;
        primitive3.segmentsT = 8;
        
        //var primitive4:Cylinder = new Cylinder({material:new WireColorMaterial(color), radius:150, height:300, segmentsW:12, segmentsH:6});
        var primitive4:Cylinder = new Cylinder();
        primitive4.material = new WireColorMaterial(color);
        primitive4.radius = 150;
        primitive4.height = 300;
        primitive4.segmentsW = 12;
        primitive4.segmentsH = 6;
        
        //var primitive5:Cone = new Cone({material:new WireColorMaterial(color), radius:150, height:300, segmentsW:14, segmentsH:10});
        var primitive5:Cone = new Cone();
        primitive5.material = new WireColorMaterial(color);
        primitive5.radius = 150;
        primitive5.height = 300;
        primitive5.segmentsW = 14;
        primitive5.segmentsH = 10;
		        
        //var primitive6:Sphere = new Sphere({material:new WireColorMaterial(color), radius:150, segmentsW:16, segmentsH:12});
        var primitive6:Sphere = new Sphere();
        primitive6.material = new WireColorMaterial(color);
        primitive6.radius = 150;
        primitive6.segmentsW = 16;
        primitive6.segmentsH = 12;
        
        //var lod0:LODObject = new LODObject({minp:0.2, maxp:0.3}, primitive0);
        var lod0:LODObject = new LODObject(primitive0);
        lod0.minp = 0.2;
        lod0.maxp = 0.3;
        
        addChild(lod0);
        
        //var lod1:LODObject = new LODObject({minp:0.3, maxp:0.4}, primitive1);
        var lod1:LODObject = new LODObject(primitive1);
        lod1.minp = 0.3;
        lod1.maxp = 0.4;
        
        addChild(lod1);
        
        //var lod2:LODObject = new LODObject({minp:0.4, maxp:0.5}, primitive2);
        var lod2:LODObject = new LODObject(primitive2);
        lod2.minp = 0.4;
        lod2.maxp = 0.5;
        
        addChild(lod2);
        
        //var lod3:LODObject = new LODObject({minp:0.5, maxp:0.6}, primitive3);
        var lod3:LODObject = new LODObject(primitive3);
        lod3.minp = 0.5;
        lod3.maxp = 0.6;
        
        addChild(lod3);
        
        //var lod4:LODObject = new LODObject({minp:0.6, maxp:0.7}, primitive4);
        var lod4:LODObject = new LODObject(primitive4);
        lod4.minp = 0.6;
        lod4.maxp = 0.7;
        
        addChild(lod4);
        
        //var lod5:LODObject = new LODObject({minp:0.7, maxp:0.8}, primitive5);
        var lod5:LODObject = new LODObject(primitive5);
        lod5.minp = 0.7;
        lod5.maxp = 0.8;
        
        addChild(lod5);
        
        //var lod6:LODObject = new LODObject({minp:0.8, maxp:0.9}, primitive6);
        var lod6:LODObject = new LODObject(primitive6);
        lod6.minp = 0.8;
        lod6.maxp = 0.9;
        
        addChild(lod6);
    }
}
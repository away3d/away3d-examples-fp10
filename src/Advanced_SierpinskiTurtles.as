/*

Triangle caching example in Away3d

Demonstrates:

How to use the ownCanvas property to create container boundaries for enabling triangle caching.
How to clone and animate an exported .as mesh.
How to create a Sierpinski triangle

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
	import away3d.loaders.Md2;
	//import AS3s.SeaTurtleAnimated;
	
	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.debug.*;
	import away3d.events.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	use namespace arcane;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Advanced_SierpinskiTurtles extends Sprite
	{
		[Embed(source="assets/seaturtle.md2", mimeType="application/octet-stream")]
		private var SeaTurtleAnimated:Class;
		
		[Embed(source="assets/seaturtle.jpg")]
		private var SeaTurtleTexture:Class;
		
		[Embed(source="assets/sky.jpg")]
		private var Sky:Class;
		
		//signature swf
    	[Embed(source="assets/signature_peter.swf", symbol="Signature")]
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
		private var hiliteMaterial:ShadingColorMaterial;
		private var turtleMaterial:BitmapMaterial;
		
		//scene objects
		private var skysphere:Sphere;
		private var seaturtle:Mesh;
		private var containers:ObjectContainer3D;
		private var outlines:ObjectContainer3D;
		private var light:DirectionalLight3D;
		
		//generating objects
		private var toRadians:Number = Math.PI/180;
		private var turtles:Array = new Array();
		private var turtle:Mesh;
		private var angle:Number;
		private var v1:Vertex;
		private var v2:Vertex;
		private var v3:Vertex;
		private var v4:Vertex;
		
		//navigation variables
		private var move:Boolean = false;
		private var mesh:Mesh;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Advanced_SierpinskiTurtles() 
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
			initGeometry();
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
			camera.distance = 1500;
			camera.yfactor = 1;
			camera.minTiltAngle = -45;
			camera.steps = 4;
			
			camera.panAngle = 285;
			camera.tiltAngle = 10;
			//camera.hover(true);
			
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
			skyMaterial = new BitmapMaterial( Cast.bitmap(Sky) );
			
			//hiliteMaterial = new ShadingColorMaterial(0x0099FF, {shininess:5});
			hiliteMaterial = new ShadingColorMaterial(0x0099FF);
			hiliteMaterial.shininess = 5;
			
			turtleMaterial = new BitmapMaterial(Cast.bitmap(SeaTurtleTexture));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//skysphere = new Sphere({material:skyMaterial, radius:50000, rotationX:180, segmentsW:10, segmentsH:12});
			skysphere = new Sphere();
			skysphere.material = skyMaterial;
			skysphere.radius = 5000;
			skysphere.rotationX = 180;
			skysphere.segmentsW = 10;
			skysphere.segmentsH = 12;
			
			skysphere.scale(-1);
			scene.addChild(skysphere);
			
			angle = 90 - Math.atan(1/Math.sqrt(2))/toRadians;
			
			//light = new DirectionalLight3D({x:60, y:-100, z:-60, ambient:0.5, diffuse:0.5, specular:1});
			light = new DirectionalLight3D();
			light.direction = new Number3D(60, -100, -60);
			light.ambient = 0.5;
			light.diffuse = 0.5;
			light.specular = 1;
			
			scene.addLight(light);
			
			//containers = new ObjectContainer3D({visible:false});
			containers = new ObjectContainer3D();
			containers.visible = false;
			
			containers.rotate(new Number3D(1, 0, -1), angle);
			scene.addChild(containers);
			
			outlines = new ObjectContainer3D();
			
			outlines.rotate(new Number3D(1, 0, -1), angle);
			scene.addChild(outlines);
		}
		
		/**
		 * Initialise the sierpinski geometry
		 */
		private function initGeometry():void
		{
			generateContainers(4, 500, containers, 0, 0, 0);
			
			generateOutline(3, 500, outlines, 0, 0, 0);
		}
		
		/**
		 * Creates container clones from the turtle mesh
		 */
		private function generateContainers(itr:int, size:Number, parent:ObjectContainer3D, x:Number, y:Number, z:Number):void
		{
			if (itr) {
				itr--;
				size /= 2;
				generateContainers(itr, size, parent, x+size, y+size, z+size);
				generateContainers(itr, size, parent, x+size, y-size, z-size);
				generateContainers(itr, size, parent, x-size, y-size, z+size);
				generateContainers(itr, size, parent, x-size, y+size, z-size);
				return;
			}
			
			var md2:Md2 = new Md2();
			turtle = md2.parseGeometry(SeaTurtleAnimated) as Mesh;
			turtle.material = turtleMaterial;
			turtle.rotate(new Number3D(1, 0, -1), -angle);
			turtle.scale(0.24);
			turtle.ownCanvas = true;
			turtle.x = x;
			turtle.y = y;
			turtle.z = z;
			parent.addChild(turtle);
			
			turtles.push(turtle);
		}
		
		/**
		 * Creates an outline model for movement
		 */
		private function generateOutline(itr:int, size:Number, parent:ObjectContainer3D, x:Number, y:Number, z:Number):void
		{
			if (itr) {
				itr--;
				size /= 2;
				generateOutline(itr, size, parent, x+size, y+size, z+size);
				generateOutline(itr, size, parent, x+size, y-size, z-size);
				generateOutline(itr, size, parent, x-size, y-size, z+size);
				generateOutline(itr, size, parent, x-size, y+size, z-size);
				return;
			}
			
			//mesh = new Mesh({material:new WireframeMaterial(0x0066CC), ownCanvas:true, x:x, y:y, z:z});
			mesh = new Mesh();
			mesh.material = new WireframeMaterial(0x0066CC);
			mesh.ownCanvas = true;
			mesh.x = x;
			mesh.y = y;
			mesh.z = z;
			
			parent.addChild(mesh);
			
			v1 = new Vertex(size, size, size);
			v2 = new Vertex(size, -size, -size);
			v3 = new Vertex(-size, -size, size);
			v4 = new Vertex(-size, size, -size);
			
			mesh.addSegment(new Segment(v1, v2));
			mesh.addSegment(new Segment(v1, v3));
			mesh.addSegment(new Segment(v1, v4));
			mesh.addSegment(new Segment(v2, v3));
			mesh.addSegment(new Segment(v2, v4));
			mesh.addSegment(new Segment(v3, v4));
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			containers.addOnMouseOver(onMeshMouseOver);
			containers.addOnMouseOut(onMeshMouseOut);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame( e:Event ):void
		{
			if (move) {
				outlines.visible = true;
				containers.visible = false;
				camera.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			} else if (camera._currentPanAngle == camera.panAngle && camera._currentTiltAngle == camera.tiltAngle) {
				outlines.visible = false;
				containers.visible = true;
				
				//apply distance alpha to turtles
				for each (turtle in turtles)
					turtle.alpha = 1/(1 + (view.camera.screen(turtle).z - 1100)/1000);
			}
			
			camera.hover();
			view.render();
		}
		
		/**
		 * Updates the turtle material on rollover
		 */
		private function onMeshMouseOver(event:MouseEvent3D):void
		{
			mesh = (event.object as Mesh);
			mesh.material = hiliteMaterial;
			mesh.animationLibrary.getAnimation("swim").animator.play();
		}
		
		/**
		 * Resets the turtle material on rollout
		 */
		private function onMeshMouseOut(event:MouseEvent3D):void
		{
			mesh = (event.object as Mesh);
			mesh.material = turtleMaterial;
			mesh.animationLibrary.getAnimation("swim").animator.gotoAndStop(0);
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
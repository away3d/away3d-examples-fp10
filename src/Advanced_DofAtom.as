/*

2d Sprite example in Away3d with bitmap rendering and deph-of-field blurring

Demonstrates:

How to use DofSprite2D to create a depth-of-field blur effect.
How to vary the resolution and processing speed of a view by using the BitmapRenderSession object to render a view to a bitmapData object.
How to create a videowall effect by using getBitmapData() on a BitmapRenderSession object to create a new material.

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
	import away3d.core.base.*;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.session.*;
	import away3d.core.utils.Cast;
	import away3d.core.utils.DofCache;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.sprites.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Advanced_DofAtom extends Sprite
	{
		//red marble
		[Embed(source="assets/red.png")]
    	public var RedMarble:Class;
    	
    	//green marble
		[Embed(source="assets/green.png")]
    	public var GreenMarble:Class;
    	
    	//blue marble
		[Embed(source="assets/blue.png")]
    	public var BlueMarble:Class;
    	
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
		private var protonMaterial:BitmapMaterial;
		private var neutronMaterial:BitmapMaterial;
		private var electronMaterial:BitmapMaterial;
		private var skyboxMaterial:TransformBitmapMaterial;
		private var skyboxBitmap:BitmapData;
		private var skyboxColorTransform:ColorTransform = new ColorTransform(1, 1, 1, 0.5);
		
		//scene objects
		private var proton:Mesh;
		private var neutron:Mesh;
		private var electron:Mesh;
		private var protonContainer:ObjectContainer3D;
		private var neutronContainer:ObjectContainer3D;
		private var electronContainer:ObjectContainer3D;
		private var skybox:Skybox;
		
		//electron variables
		private var electrons:Array = new Array();
		private var electronNum:int = 50;
		private var electronSpeed:int = 5;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Advanced_DofAtom() 
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

			//camera = new HoverCamera3D({zoom:10, focus:100, distance:2000, yfactor:1});
			camera = new HoverCamera3D();
			camera.distance = 2000;
			camera.yfactor = 1;
			
			camera.panAngle = 45;
			camera.tiltAngle = 20;
			camera.hover(true);
			
			//view = new View3D({scene:scene, camera:camera});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			
			//adjusting the argument in the BitmapRenderSession adjusts the resolution of the rendered view.
			view.session = new BitmapSession(1);
			//view.session = new BitmapSession(2);
			
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
			//create bitmapData for DofSprites
    		protonMaterial = new BitmapMaterial(Cast.bitmap(RedMarble));
    		neutronMaterial = new BitmapMaterial(Cast.bitmap(BlueMarble));
    		electronMaterial = new BitmapMaterial(Cast.bitmap(GreenMarble));
    		
    		//create skybox material from view bitmap
			skyboxBitmap = view.getBitmapData().clone();
			
			//skyboxMaterial = new TransformBitmapMaterial(Cast.bitmap(skyboxBitmap), {scaleX:0.1, scaleY:0.1, repeat:true});
    		skyboxMaterial = new TransformBitmapMaterial(Cast.bitmap(skyboxBitmap));
    		skyboxMaterial.scaleX = 0.1;
    		skyboxMaterial.scaleY = 0.1;
    		skyboxMaterial.repeat = true;
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//setup depth of field constants
			DofCache.aperture = 100;
			DofCache.usedof = true;
			DofCache.maxblur = 50;
			DofCache.focus = 2000;
			
			//create particles
			var i:int = electronNum;
			while (i--)
			{
				proton = new Mesh();
				proton.addSprite(new DepthOfFieldSprite(protonMaterial));
				proton.x = 180;
				proton.ownCanvas = true;
				proton.blendMode = BlendMode.DIFFERENCE;
				
				protonContainer = new ObjectContainer3D();
				protonContainer.addChild(proton);
				protonContainer.rotationX = i*360/electronNum;
				protonContainer.rotationY = i*200/6;
				protonContainer.rotationZ = i*180/electronNum;
				
				scene.addChild( protonContainer );
				
				neutron = new Mesh();
				neutron.addSprite(new DepthOfFieldSprite(neutronMaterial));
				neutron.x = -180;
				neutron.ownCanvas = true;
				neutron.blendMode = BlendMode.DIFFERENCE;
				
				neutronContainer = new ObjectContainer3D();
				neutronContainer.addChild(neutron);
				neutronContainer.rotationX = i*360/electronNum;
				neutronContainer.rotationY = i*200/6;
				neutronContainer.rotationZ = i*180/electronNum;
				
				scene.addChild( neutronContainer );
				
				//A 3d object can have a session applied locally
				//nucleicContainer.ownSession = new BitmapRenderSession(2);
				
				
				electron = new Mesh();
				electron.addSprite(new DepthOfFieldSprite(electronMaterial));
				electron.y = 500;
				electron.ownCanvas = true;
				electron.blendMode = BlendMode.DIFFERENCE;
				
				electronContainer = new ObjectContainer3D();
				electronContainer.addChild(electron);
				electronContainer.rotationX = i*360/electronNum;
				electronContainer.rotationY = i*360/6;
				electronContainer.rotationZ = i*180/electronNum;
				
				electrons.push(electronContainer);
				scene.addChild(electronContainer);
			}
			
			skybox = new Skybox(skyboxMaterial, skyboxMaterial, skyboxMaterial, skyboxMaterial, skyboxMaterial, skyboxMaterial);
			scene.addChild(skybox);
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
		private function onEnterFrame( e:Event ):void
		{
			if (move) {
				camera.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			for each (electronContainer in electrons)
				electronContainer.rotationX += electronSpeed;
			
			//copy view bitmap to skybox
			skyboxBitmap.fillRect(skyboxBitmap.rect, 0);
			skyboxBitmap.draw(view.getBitmapData(), null, skyboxColorTransform, BlendMode.DIFFERENCE);
			skyboxMaterial.bitmap = skyboxBitmap;
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
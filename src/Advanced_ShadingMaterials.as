/*

Advanced shading materials example in Away3d

Demonstrates:

How to create and apply a Dot3BitmapMaterial to a 3d model.
How to create and apply an EnviroBitmapMaterial to a 3d model.
How to create and apply a PhongBitmapMaterial to a 3d model.
How to create and apply a ShadingColorMaterial to a 3d model.
How to load and display a QTVR-style skybox from six images.

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
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.debug.*;
	import away3d.lights.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.test.*;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW", width="800", height="600")]
	
	public class Advanced_ShadingMaterials extends Sprite
	{
		//Marble texture for torso
		[Embed(source="assets/torso_marble2.jpg")]
    	public static var TorsoImage:Class;
    	
    	//normal map for torso
    	[Embed(source="assets/torso_normal_400.jpg")]
    	public static var TorsoNormal:Class;
    	
    	//marble texture for pedestal
    	[Embed(source="assets/pedestal_marble2.jpg")]
    	public static var PedestalImage:Class;
    	
    	//cubic panorama textures
    	[Embed(source="assets/small_f_003.jpg")]
    	public static var PanoramaImageF:Class;
    	[Embed(source="assets/small_b_003.jpg")]
    	public static var PanoramaImageB:Class;
    	[Embed(source="assets/small_u_003.jpg")]
    	public static var PanoramaImageU:Class;
    	[Embed(source="assets/small_d_003.jpg")]
    	public static var PanoramaImageD:Class;
    	[Embed(source="assets/small_l_003.jpg")]
    	public static var PanoramaImageL:Class;
    	[Embed(source="assets/small_r_003.jpg")]
    	public static var PanoramaImageR:Class;
    	
    	//Torso mesh
    	[Embed(source="assets/torsov2.MD2",mimeType="application/octet-stream")]
    	public static var TorsoMD2:Class;
    	
    	//Pedestal mesh
    	[Embed(source="assets/pedestal2.MD2",mimeType="application/octet-stream")]
    	public static var PedestalMD2:Class;
    	
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
		
		//cubic panorama materials
		private var panoramaMaterialF:BitmapMaterial;
		private var panoramaMaterialL:BitmapMaterial;
		private var panoramaMaterialB:BitmapMaterial;
		private var panoramaMaterialR:BitmapMaterial;
		private var panoramaMaterialU:BitmapMaterial;
		private var panoramaMaterialD:BitmapMaterial;
		
		//pedestal materials
		private var pedestalMaterial:WhiteShadingBitmapMaterial;
		
		//torso materials
		private var torsoNormalMaterial:Dot3BitmapMaterial;
		private var torsoEnviroMaterial:EnviroBitmapMaterial;
		private var torsoPhongMaterial:PhongBitmapMaterial;
		private var torsoFlatMaterial:WhiteShadingBitmapMaterial;
		
		//light object
		private var light:DirectionalLight3D;
		
		//scene objects
		private var Md2Torso:Md2;
		private var Md2Pedestal:Md2;
		private var torso:Mesh;
		private var pedestal:Mesh;
		private var panorama:Skybox;
		
		//button objects
		private var buttonGroup:Sprite;
		private var normalButton:Button;
		private var enviroButton:Button;
		private var phongButton:Button;
		private var flatButton:Button;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Advanced_ShadingMaterials()
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
			initLights();
			initObjects();
			initButtons();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			
			//camera = new HoverCamera3D({zoom:3, focus:200, distance:40000, yfactor:1});
			camera = new HoverCamera3D();
			camera.zoom = 3;
			camera.focus = 200;
			camera.distance = 40000;
			camera.yfactor = 1;
			
			camera.panAngle = -10;
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
            
            addChild(new AwayStats(view));
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			panoramaMaterialF = new BitmapMaterial(Cast.bitmap(PanoramaImageF));
			panoramaMaterialL = new BitmapMaterial(Cast.bitmap(PanoramaImageL));
			panoramaMaterialB = new BitmapMaterial(Cast.bitmap(PanoramaImageB));
			panoramaMaterialR = new BitmapMaterial(Cast.bitmap(PanoramaImageR));
			panoramaMaterialU = new BitmapMaterial(Cast.bitmap(PanoramaImageU));
			panoramaMaterialD = new BitmapMaterial(Cast.bitmap(PanoramaImageD));
			
			pedestalMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(PedestalImage));
			
			torsoNormalMaterial = new Dot3BitmapMaterial(Cast.bitmap(TorsoImage), Cast.bitmap(TorsoNormal));
			torsoNormalMaterial.specular = 0x808080;
			
			//torsoEnviroMaterial = new EnviroBitmapMaterial(Cast.bitmap(TorsoImage), Cast.bitmap(PanoramaImageR), {reflectiveness:0.2});
			torsoEnviroMaterial = new EnviroBitmapMaterial(Cast.bitmap(TorsoImage), Cast.bitmap(PanoramaImageR));
			torsoEnviroMaterial.reflectiveness = 0.2;
			
			//torsoPhongMaterial = new PhongBitmapMaterial(Cast.bitmap(TorsoImage), {specular:0x808080});
			torsoPhongMaterial = new PhongBitmapMaterial(Cast.bitmap(TorsoImage));
			torsoPhongMaterial.specular = 0x808080;
			
			torsoFlatMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(TorsoImage));
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			
			//light = new DirectionalLight3D({color:0xFFFFFF, ambient:0.25, diffuse:0.75, specular:0.9, x:40000, y:40000, z:40000});
			light = new DirectionalLight3D();
			light.color = 0xFFFFFF;
			light.ambient = 0.25;
			light.diffuse = 0.75;
			light.specular = 0.9;
			light.direction = new Number3D(-1, -1, -1);
            
			scene.addLight(light);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
            //torso = Md2still.parse(TorsoMD2, {ownCanvas:true, material:torsoNormalMaterial});
            Md2Torso = new Md2();
            torso = Md2Torso.parseGeometry(TorsoMD2) as Mesh;
            torso.ownCanvas = true;
            torso.material = torsoNormalMaterial;
            
            torso.centerPivot();
            torso.x = torso.z = 0;
            torso.y = 4000;
            torso.scale(5);
            
            scene.addChild(torso);
			
			//pedestal = Md2still.parse(PedestalMD2, {ownCanvas:true, material:pedestalMaterial, rotationX:180, rotationZ:180});
			Md2Pedestal = new Md2();
			pedestal = Md2Pedestal.parseGeometry(PedestalMD2) as Mesh;
			pedestal.ownCanvas = true;
			pedestal.material = pedestalMaterial;
            pedestal.rotationX = 180;
			pedestal.rotationZ = 180;			
            
            pedestal.centerPivot();
            pedestal.x = pedestal.z = 0;
            pedestal.y = -30000;
            pedestal.scale(10);
            
			scene.addChild(pedestal);
			
			panorama = new Skybox(panoramaMaterialF, panoramaMaterialL, panoramaMaterialB, panoramaMaterialR, panoramaMaterialU, panoramaMaterialD);
			panorama.scale(0.15);
			panorama.quarterFaces();
			scene.addChild(panorama);
		}
		
		/**
		 * Initialise the buttons
		 */
		private function initButtons():void
		{
			buttonGroup = new Sprite();
			addChild(buttonGroup);
			
			normalButton = new Button("Normal Map", 90);
            normalButton.x = 0;
            normalButton.y = 0;
            buttonGroup.addChild(normalButton);
            
            enviroButton = new Button("Environment Map", 125);
            enviroButton.x = 110;
            enviroButton.y = 0;
            buttonGroup.addChild(enviroButton);
            
            phongButton = new Button("Phong Shading", 115);
            phongButton.x = 255;
            phongButton.y = 0;
            buttonGroup.addChild(phongButton);
            
            flatButton = new Button("Flat Shading", 95);
            flatButton.x = 390;
            flatButton.y = 0;
            buttonGroup.addChild(flatButton);
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
			normalButton.addEventListener(MouseEvent.CLICK, onNormalClick);
			enviroButton.addEventListener(MouseEvent.CLICK, onEnviroClick);
			phongButton.addEventListener(MouseEvent.CLICK, onPhongClick);
			flatButton.addEventListener(MouseEvent.CLICK, onFlatClick);
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
			
			torso.rotationY += 3;
			
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
		 * button listener for viewing normal map
		 */
		private function onNormalClick(event:MouseEvent):void
		{
			torso.material = torsoNormalMaterial;
		}
		
		/**
		 * button listener for viewing environment map
		 */
		private function onEnviroClick(event:MouseEvent):void
		{
			torso.material = torsoEnviroMaterial;
		}
		
		/**
		 * button listener for viewing phong shading
		 */
		private function onPhongClick(event:MouseEvent):void
		{
			torso.material = torsoPhongMaterial;
		}
		
		/**
		 * button listener for viewing flat shading
		 */
		private function onFlatClick(event:MouseEvent):void
		{
			torso.material = torsoFlatMaterial;
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
            buttonGroup.x = stage.stageWidth - 600;
            buttonGroup.y = stage.stageHeight - 40;
		}
	}
}
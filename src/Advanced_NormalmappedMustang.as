/*

Flash 10 normal mapping example in Away3d

Demonstrates:

How to use Dot3BitmapMaterial to apply diffuse and specular lighting to a normap-mapped material.
The advantage of using Dot3BitmapMaterial over WhiteShadingBitmapMaterial
How to group objects in RenderSession objects to solve sorting problems

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

Design by Eddie Carbin
http://www.carbin.com/

HDR pixel bender kernel by David Lenaerts
http://www.derschmale.com/
 
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

	import AS3s.*;
	
	import away3d.cameras.*;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.session.*;
	import away3d.core.utils.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.test.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.utils.*;
	
	[SWF(backgroundColor="#677999", frameRate="30", quality="LOW", width="800", height="600")]
	 
	public class Advanced_NormalmappedMustang extends MovieClip
	{
		//license plate texture
		[Embed(source="assets/licenseplate.jpg")]
    	public var LicenseTexture:Class;
    	
		//brakes texture for wheels
		[Embed(source="assets/discbrakes.png")]
    	public var BrakesTexture:Class;
    	
    	//tire texture for wheels
    	[Embed(source="assets/dragradial.jpg")]
    	public var TiresTexture:Class;
		
		//hubcap texture for wheels
		[Embed(source="assets/eleanor_hub.png")]
		private var HubTexture:Class;
		
		//shadow texture
		[Embed(source="assets/eleanor_shadow_256.png")]
		private var ShadowTexture:Class;
				
		//body texture
		[Embed(source="assets/Mustang_diffuse.jpg")]
		private var BodyTexture:Class;
		
		//normalmap for body
		[Embed(source="assets/MustangObject_NRM_512.png")]
		private var Normalmap:Class;
		
    	//signature swf
    	[Embed(source="assets/signature_eddie_david.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
    	
    	//pixel bender filter for HDR effect
    	[Embed(source="pbks/BloomBrightness.pbj", mimeType="application/octet-stream")]
		private var BloomBrightness:Class;
		
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		private var bloomShader:Shader;
		private var bloomFilter:ShaderFilter;
		private var bloomBitmap:Bitmap;
		private var bloom:Boolean = true;
				//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var f10Material:Dot3BitmapMaterialF10;
		private var f9Material:Dot3BitmapMaterial;
		private var flatMaterial:WhiteShadingBitmapMaterial;
		private var hubMaterial:WhiteShadingBitmapMaterial;
		private var brakesMaterial:WhiteShadingBitmapMaterial;
		private var tiresMaterial:WhiteShadingBitmapMaterial;
		private var licenseMaterial:WhiteShadingBitmapMaterial;
		private var shadowMaterial:BitmapMaterial;
		
		//scene objects
		private var mustang:MustangGT500;
		private var shadow:Mesh;
		private var bodyMesh:Mesh;
		
		//scene lights
		private var light:DirectionalLight3D;
		
		//button objects
		private var buttonGroup:Sprite;
		private var f10BloomButton:Button;
		private var f10Button:Button;
		private var f9Button:Button;
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
		public function Advanced_NormalmappedMustang()
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
			initLights();
			initButtons();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			//camera = new HoverCamera3D({zoom:20, focus:50, lens:new SphericalLens(), distance:600, maxtiltangle:70, mintiltangle:5});
			camera = new HoverCamera3D();
			camera.zoom = 20;
			camera.focus = 50;
			camera.lens = new SphericalLens();
			camera.distance = 600;
			camera.maxTiltAngle = 70;
			camera.minTiltAngle = 5;
			
			camera.panAngle = -140;
			camera.tiltAngle = 20;
			camera.hover(true);
			
			//view = new View3D({scene:scene, camera:camera, session:new BitmapRenderSession(1)});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.session = new BitmapSession(1);
			
			view.addSourceURL("srcview/index.html");
			addChild(view);
			
			//add signature
            Signature = Sprite(new SignatureSwf());
            SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
            stage.quality = StageQuality.HIGH;
            SignatureBitmap.bitmapData.draw(Signature);
            stage.quality = StageQuality.LOW;
            addChild(SignatureBitmap);
            
            //add filters
            bloomShader = new Shader(new BloomBrightness());
            bloomShader.data.threshold.value = [0.99];
            bloomShader.data.exposure.value = [1];
			bloomFilter = new ShaderFilter(bloomShader);
			bloomBitmap = new Bitmap();
			bloomBitmap.filters = [bloomFilter, new BlurFilter(20, 20, 3)];
			bloomBitmap.blendMode = BlendMode.ADD;
			addChild(bloomBitmap);
		}

		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			//f10Material = new Dot3BitmapMaterialF10(Cast.bitmap(BodyTexture), Cast.bitmap(Normalmap), {specular:0x1A1A1A, shininess:1000});
			f10Material = new Dot3BitmapMaterialF10(Cast.bitmap(BodyTexture), Cast.bitmap(Normalmap));
			f10Material.specular = 0x1A1A1A;
			f10Material.shininess = 1000;
			
			//f9Material = new Dot3BitmapMaterial(Cast.bitmap(BodyTexture), Cast.bitmap(Normalmap), {specular:0x1A1A1A, shininess:1000});
			f9Material = new Dot3BitmapMaterial(Cast.bitmap(BodyTexture), Cast.bitmap(Normalmap));
			f9Material.specular = 0x1A1A1A;
			f9Material.shininess = 1000;
			
			flatMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(BodyTexture));
			hubMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(HubTexture));
			brakesMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(BrakesTexture));
			tiresMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(TiresTexture));
			licenseMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(LicenseTexture));
			shadowMaterial = new BitmapMaterial(Cast.bitmap(ShadowTexture));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//create mustang model
			mustang = new MustangGT500({scaling:.06});
			
			var backLeftWheelSession:SpriteSession = new SpriteSession();
			var backRightWheelSession:SpriteSession = new SpriteSession();
			var frontLeftWheelSession:SpriteSession = new SpriteSession();
			var frontRightWheelSession:SpriteSession = new SpriteSession();
			
			var frontLeftTire:Mesh = mustang.meshes[0];
			frontLeftTire.material = tiresMaterial;
			frontLeftTire.ownSession = frontLeftWheelSession;
			frontLeftTire.screenZOffset = 10;
			frontLeftTire.centerPivot();
			
			var frontRightTire:Mesh = mustang.meshes[13];
			frontRightTire.material = tiresMaterial;
			frontRightTire.ownSession = frontRightWheelSession;
			frontRightTire.screenZOffset = 10;
			frontRightTire.centerPivot();
			
			var frontLeftBrake:Mesh = mustang.meshes[10];
			frontLeftBrake.material = brakesMaterial;
			frontLeftBrake.ownSession = frontLeftWheelSession;
			frontLeftBrake.screenZOffset = 10;
			frontLeftBrake.centerPivot();
			
			var frontRightBrake:Mesh = mustang.meshes[6];
			frontRightBrake.material = brakesMaterial;
			frontRightBrake.ownSession = frontRightWheelSession;
			frontRightBrake.screenZOffset = 10;
			frontRightBrake.centerPivot();
			
			var frontLeftHub:Mesh = mustang.meshes[9];
			frontLeftHub.material = hubMaterial;
			frontLeftHub.ownSession = frontLeftWheelSession;
			frontLeftHub.screenZOffset = 10;
			frontLeftHub.centerPivot();
			
			var frontRightHub:Mesh = mustang.meshes[7];
			frontRightHub.material = hubMaterial;
			frontRightHub.ownSession = frontRightWheelSession;
			frontRightHub.screenZOffset = 10;
			frontRightHub.centerPivot();
			
			var backLeftTire:Mesh = mustang.meshes[12];
			backLeftTire.material = tiresMaterial;
			backLeftTire.ownSession = backLeftWheelSession;
			backLeftTire.screenZOffset = 10;
			backLeftTire.centerPivot();
			
			var backRightTire:Mesh = mustang.meshes[1];
			backRightTire.material = tiresMaterial;
			backRightTire.ownSession = backRightWheelSession;
			backRightTire.screenZOffset = 10;
			backRightTire.centerPivot();
			
			var backLeftBrake:Mesh = mustang.meshes[2];
			backLeftBrake.material = brakesMaterial;
			backLeftBrake.ownSession = backLeftWheelSession;
			backLeftBrake.screenZOffset = 10;
			backLeftBrake.centerPivot();
			
			var backRightBrake:Mesh = mustang.meshes[5];
			backRightBrake.material = brakesMaterial;
			backRightBrake.ownSession = backRightWheelSession;
			backRightBrake.screenZOffset = 10;
			backRightBrake.centerPivot();
			
			var backLeftHub:Mesh = mustang.meshes[3];
			backLeftHub.material = hubMaterial;
			backLeftHub.ownSession = backLeftWheelSession;
			backLeftHub.screenZOffset = 10;
			backLeftHub.centerPivot();
			
			var backRightHub:Mesh = mustang.meshes[4];
			backRightHub.material = hubMaterial;
			backRightHub.ownSession = backRightWheelSession;
			backRightHub.screenZOffset = 10;
			backRightHub.centerPivot();
			
			shadow = mustang.meshes[8];
			shadow.material = shadowMaterial;
			shadow.ownCanvas = true;
			shadow.pushback = true;
			
			bodyMesh = mustang.meshes[11];
			bodyMesh.material = f10Material;
			
			bodyMesh.faces[0].material = licenseMaterial;
			bodyMesh.faces[1].material = licenseMaterial;
			
			scene.addChild(mustang);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			//light = new DirectionalLight3D({y:700, z:1000, color:0xFFFFFF, ambient:0.2, diffuse:0.7, debug:true});
			light = new DirectionalLight3D();
			light.direction = new Number3D(0, -700, -1000);
			light.color = 0xFFFFFF;
			light.ambient = 0.2;
			light.diffuse = 0.7;
			light.debug = true;
			
			scene.addLight(light);
		}
				
		/**
		 * Initialise the buttons
		 */
		private function initButtons():void
		{
			buttonGroup = new Sprite();
			addChild(buttonGroup);
			f10BloomButton = new Button("Flash 10 + HDR", 120);
            f10BloomButton.x = 170;
            f10BloomButton.y = 0;
            buttonGroup.addChild(f10BloomButton);
            f10Button = new Button("Flash 10", 75);
            f10Button.x = 310;
            f10Button.y = 0;
            buttonGroup.addChild(f10Button);
            f9Button = new Button("Flash 9", 65);
            f9Button.x = 405;
            f9Button.y = 0;
            buttonGroup.addChild(f9Button);
            flatButton = new Button("Flat Shading", 95);
            flatButton.x = 490;
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
			f10BloomButton.addEventListener(MouseEvent.CLICK, onF10BloomClick);
			f10Button.addEventListener(MouseEvent.CLICK, onF10Click);
			f9Button.addEventListener(MouseEvent.CLICK, onF9Click);
			flatButton.addEventListener(MouseEvent.CLICK, onFlatClick);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			tick(getTimer());
			
			if (move) {
				camera.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			camera.hover();  
			view.render();
			
			bloomBitmap.visible = bloom;
			
			if (bloom)
				bloomBitmap.bitmapData = view.getBitmapData().clone();
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
		 * button listener for viewing flash10 normalmapping with bloom HDR
		 */
		private function onF10BloomClick(event:MouseEvent):void
		{
			bodyMesh.material = f10Material;
			bloom = true;
		}
				
		/**
		 * button listener for viewing flash10 normalmapping
		 */
		private function onF10Click(event:MouseEvent):void
		{
			bodyMesh.material = f10Material;
			bloom = false;
		}
		
		/**
		 * button listener for viewing flash9 normalmapping
		 */
		private function onF9Click(event:MouseEvent):void
		{
			bodyMesh.material = f9Material;
			bloom = false;
		}
		
		/**
		 * button listener for viewing flat shading
		 */
		private function onFlatClick(event:MouseEvent):void
		{
			bodyMesh.material = flatMaterial;
			bloom = false;
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
            buttonGroup.x = stage.stageWidth - 700;
            buttonGroup.y = stage.stageHeight - 40;
		}
		
		/**
		 * Time function for updating time-based scene objects
		 */
        private function tick(time:int):void
	    {
	    	light.direction = new Number3D(-1000*Math.cos(time/2000), -700, -1000*Math.sin(time/2000));
	    	shadow.x = -20*Math.cos(time/2000);
	    	shadow.z = -20*Math.sin(time/2000);
	    }
	}
}
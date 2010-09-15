/*

Textfield extrusion example in Away3d

Demonstrates:

How to extrude a 3d textfield object to produce a solid mesh.

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
	import away3d.core.session.*;
	import away3d.extrusions.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	import wumedia.vector.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Intermediate_TextExtrusion extends Sprite
	{
    	//signature swf
    	[Embed(source="assets/signature_li.swf", symbol="Signature")]
    	public static var SignatureSwf:Class;
    	
    	[Embed(source="fonts/extrusionfonts.swf", mimeType="application/octet-stream")]
		public var FontBytes:Class;
		
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material1:WireColorMaterial;
		private var material2:ColorMaterial;
		private var material3:ShadingColorMaterial;
		private var material4:WireframeMaterial;
		
		//scene objects
		private var textfield1:TextField3D;
		private var textfield2:TextField3D;
		private var textfield3:TextField3D;
		private var textfield4:TextField3D;
		private var pointLight:PointLight3D;
		
		/**
		 * Constructor
		 */
		public function Intermediate_TextExtrusion() 
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initText();
			initMaterials();
			initLights();
			initObjects();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			
			//camera = new Camera3D({z:-1000});
			camera = new Camera3D();
			camera.z = -1000;
			
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
		private function initText():void
		{
			VectorText.extractFont(new FontBytes(), null, false);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			//material1 = new WireColorMaterial(0x8A0041, {wireColor:0xFFFFFF});
			material1 = new WireColorMaterial(0x8A0041);
			material1.wireColor = 0xFFFFFF;
			
			material2 = new ColorMaterial(0xA02860);
			
			material3 = new ShadingColorMaterial(0xD50065);
			
			material4 = new WireframeMaterial(0xEA69A6);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			pointLight = new PointLight3D();
			pointLight.color = 0xFFFFFF;
			pointLight.ambient = 0.25;
			pointLight.diffuse = 2;
			pointLight.specular = 10;
			scene.addLight(pointLight);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//textfield1 = new TextField3D("Impact", {material:material1, text:"WireColor", size:150, textWidth:2000});
			textfield1 = new TextField3D("Impact");
			textfield1.material = material1;
			textfield1.text = "WireColor";
			textfield1.size = 150;
			textfield1.width = 2000;
			
			textfield1.x -= textfield1.objectWidth/2;
			textfield1.y += textfield1.objectHeight/2 + 275;
			extrudeMesh(textfield1, 1, 2);
			
			scene.addChild(textfield1);
			
			//textfield2 = new TextField3D("Gill Sans Ultra Bold", {material:material2, text:"Color", size:150, textWidth:2000});
			textfield2 = new TextField3D("Gill Sans Ultra Bold");
			textfield2.material = material2;
			textfield2.text = "Color";
			textfield2.size = 150;
			textfield2.width = 2000;
			
			textfield2.x -= textfield2.objectWidth/2;
			textfield2.y += textfield2.objectHeight/2 + 100;
			extrudeMesh(textfield2, 3, 1);
			
			scene.addChild(textfield2);
			
			//textfield3 = new TextField3D("Bauhaus 93", {material:material3, text:"Shading", size:200, textWidth:2000});
			textfield3 = new TextField3D("Bauhaus 93");
			textfield3.material = material3;
			textfield3.text = "Shading";
			textfield3.size = 200;
			textfield3.width = 2000;
			
			textfield3.x -= textfield3.objectWidth/2;
			textfield3.y += textfield3.objectHeight/2 - 100;
			extrudeMesh(textfield3, 2, 1);
			
			scene.addChild(textfield3);
			
			//textfield4 = new TextField3D("Arial", {material:material4, text:"Wireframe", size:150, textWidth:2000});
			textfield4 = new TextField3D("Arial");
			textfield4.material = material4;
			textfield4.text = "Wireframe";
			textfield4.size = 150;
			textfield4.width = 2000;
			
			textfield4.x -= textfield4.objectWidth/2;
			textfield4.y += textfield4.objectHeight/2 - 275;
			extrudeMesh(textfield4, 1, 1, true);
			
			scene.addChild(textfield4);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Creates an extrusion on a mesh object
		 */
		private function extrudeMesh(mesh:Mesh, subdivisionsXY:uint = 1, subdivisionsZ:uint = 1, bothsides:Boolean = true):void
		{
			//push mesh to front
			var renderSession:SpriteSession = new SpriteSession();
			renderSession.screenZ = 10;
			mesh.ownSession = renderSession;
			
			var extrusion:TextExtrusion = new TextExtrusion(mesh, {subdivisionsXY:subdivisionsXY, subdivisionsZ:subdivisionsZ, bothsides:bothsides});
			scene.addChild(extrusion);
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			hoverCamera();
			hoverLight();
			view.render();
		}
		
		/**
		 * Update method for camera position
		 */
		private function hoverCamera():void
		{
			var mX:Number = this.mouseX > 0 ? this.mouseX : 0;
			var mY:Number = this.mouseY > 0 ? this.mouseY : 0;
			
			var tarX:Number = 3*(mX - stage.stageWidth/2);
			var tarY:Number = -2*(mY - stage.stageHeight/2);
			
			var dX:Number = camera.x - tarX;
			var dY:Number = camera.y - tarY;
			
			camera.x -= dX*0.25;
			camera.y -= dY*0.25;
			camera.lookAt(new Number3D(0, 0, 0));
		}
		
		/**
		 * Update method for light position
		 */
		private function hoverLight():void
		{
			pointLight.x = camera.x;
			pointLight.y = camera.y;
			pointLight.z = camera.z;
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
/*

Basic 3d text example in Away3d

Demonstrates:

How to import and process a font.
How to create a 3d textfield.
How to add a listener for mouse events to a 3d textfield.

Code by Rob Bateman & Alejandro Santander
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
palebluedot@gmail.com
http://www.lidev.com.ar

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
	import flash.utils.getTimer;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.events.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	import wumedia.vector.VectorText;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Basic_Text extends Sprite
	{
    	//signature swf
    	[Embed(source="assets/signature_li.swf", symbol="Signature")]
    	public static var SignatureSwf:Class;
    	
    	//font swf containing the embedded font Arial
    	[Embed(source="fonts/fonts.swf", mimeType="application/octet-stream")]
		public var FontBytes:Class;
		
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material:ColorMaterial;
		
		//scene objects
		private var textfield:TextField3D;
		
		/**
		 * Constructor
		 */
		public function Basic_Text() 
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initFonts();
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
			
			//camera = new Camera3D({z:-1250});
			camera = new Camera3D();
			camera.z = -1250;
			
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
		 * Initialise the fonts
		 */
		private function initFonts():void
		{
			VectorText.extractFont(new FontBytes(), null, false);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			material = new ColorMaterial(0xFF0000);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//textfield = new TextField3D("Arial", {material:material, text:"This is some text.", size:150, leading:150, kerning:0, textWidth:5000, align:"C"});
			textfield = new TextField3D("Arial");
			textfield.text = "This is some text.";
			textfield.material = material;
			textfield.size = 150;
			textfield.leading = 150;
			textfield.letterSpacing = 0;
			textfield.width = 5000;
			textfield.align = "C";
			
			scene.addChild(textfield);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			//textfield.addOnMouseUp(onClickText);
			textfield.addEventListener(MouseEvent3D.MOUSE_UP, onClickText);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Listener function for mouse click on text
		 */
	    private function onClickText(e:MouseEvent3D):void
	    {
	        if (e.object is Mesh) {
	            var mesh:Mesh = e.object as Mesh;
	            mesh.material = new ColorMaterial();
	        }
	    }
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			hoverCamera();
			view.render();
			
			for each (var vertex : Vertex in textfield.vertices)
    			vertex.z = 50*Math.sin(vertex.x/50 + getTimer()/200);
			
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
			camera.lookAt(textfield.position);
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
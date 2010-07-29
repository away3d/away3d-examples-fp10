/*

Filters example in Away3d with 2d sprites and bitmap rendering

Demonstrates:

How to create a torus knot with 2d sprites.
How to apply filters to a 3d object.
How to use BitmapRenderSession to speed up filter processing by doubling pixel size and halving pixel resolution.

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
	import away3d.core.math.*;
	import away3d.core.session.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.sprites.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Advanced_SupernovaVisualiser extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//footnote text
		private var TrackText:TextField;
		
		private var backBitmap:BitmapData;
		private var transBitmap:BitmapData;
		private var backShape:Shape;
		private var backGraphics:Graphics;
		
		//material objects
		private var tubeMaterial:BitmapMaterial;
		
		//scene objects
		private var cylinder:Cylinder;
		private var container:ObjectContainer3D;
		private var container2:ObjectContainer3D;
		private var sprite:Sprite3D;
		
		//sprite constants
		private var spheresNum:int = 100;
		private var spheresDistance:int = 400;
		
		//sound variables
		private var sound:Sound = new Sound();
		private var channel:SoundChannel;
		private var peak:Number;
		private var audioURL:String = "assets/03_The_Number_Song.mp3";
		private var addNum:Number = 0;
		private var distance:Number = 0;
		private var distancespeed:Number = 0;
		private var spectrum:ByteArray = new ByteArray();
		private var maxlevel:int = 20;
		private var minlevel:int = 10;
		
		/**
		 * Constructor
		 */
		public function Advanced_SupernovaVisualiser()
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
			initSound();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			//setup fullscreen rect
			stage.fullScreenSourceRect = new Rectangle(0,0,800,600);
			
			//setup bitmap for equaliser
			backBitmap = new BitmapData(512, 256, false, 0x000000);
			backShape = new Shape();
			backGraphics = backShape.graphics;
			
			//setup scene variables
			scene = new Scene3D();
			
			//camera = new Camera3D({z:-2000});
			camera = new Camera3D();
			camera.z = -2000;
			
			//view = new View3D({scene:scene, camera:camera, session:new BitmapRenderSession(2)});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.session = new BitmapSession(2);
			
			view.addSourceURL("srcview/index.html");
			addChild(view);
			
			//add signature
            Signature = Sprite(new SignatureSwf());
            SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
            stage.quality = StageQuality.HIGH;
            SignatureBitmap.bitmapData.draw(Signature);
            stage.quality = StageQuality.LOW;
            addChild(SignatureBitmap);
            
            //add track text
            TrackText = new TextField();
            var tf:TextFormat = new TextFormat();
            tf.color = 0xFFFFFF;
            tf.font = "Arial";
            tf.size = 11;
            TrackText.text = "Track: DJ Shadow: The Number Song";
            TrackText.autoSize = "left";
            TrackText.setTextFormat(tf);
            addChild(TrackText);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			tubeMaterial = new BitmapMaterial(Cast.bitmap(backBitmap));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//create filters
			var filter1:GlowFilter = new GlowFilter(0xFF0000, 1, 40, 40, 4, 1, false, false);
			var filter2:BevelFilter = new BevelFilter(5, 45, 0xCCFF00, 0.5, 0xFF6600, 0.5, 1, 1, 2, 1, BitmapFilterType.FULL, true);
			var filter3:BevelFilter = new BevelFilter(5, -45, 0xFF0000, 0.5, 0x000000, 0.5, 1, 1, 2, 1, BitmapFilterType.FULL, false);
			var filter4:BlurFilter = new BlurFilter();
			
			//create containers
			//container = new ObjectContainer3D({ownCanvas:true, filters:[filter1, filter2, filter3]});
			container = new ObjectContainer3D();
			container.ownCanvas = true;
			container.filters = [filter1, filter2, filter3];
			
			container2 = new ObjectContainer3D(container);
			container2.lookAt(new Number3D(1, 1, 1));
			scene.addChild(container2);
			
			//create cylinder
			//cylinder = new Cylinder({ownCanvas:true, filters:[filter4], material:tubeMaterial, z:12000, radius:200, height:2000, segmentsW:20, segmentsH:20, openEnded:true, yUp:false, rotationZ:90});
			cylinder = new Cylinder();
			cylinder.ownCanvas = true;
			cylinder.filters = [filter4];
			cylinder.material = tubeMaterial;
			cylinder.z = 12000;
			cylinder.radius = 200;
			cylinder.height = 2000;
			cylinder.segmentsW = 20;
			cylinder.segmentsH = 20;
			cylinder.openEnded = true;
			cylinder.yUp = false;
			cylinder.rotationZ = 90;
			
			cylinder.scale(-10);
			scene.addChild(cylinder);
			
			//create spheres
			var i:int = spheresNum;
			var red:int = 0xFF;
			var green:int = 0;
			var blue:int = 0;
			while (i--)
			{
				red = 0xFF*(1 + Math.cos(i*Math.PI/spheresNum));
				green = 0xFF*(1 + Math.sin(i*Math.PI/spheresNum));
				blue = 0xFF*(1 - Math.sin(i*Math.PI/spheresNum));
				sprite = getNucleicSprite(spheresDistance*Math.cos(i*Math.PI*4/spheresNum), spheresDistance*Math.sin(i*Math.PI*4/spheresNum), spheresDistance*Math.sin(i*Math.PI*20/spheresNum), 20, red, green, blue);
				container.addSprite(sprite);
			}
		}
		
		/**
		 * Initialise the sound
		 */
		private function initSound():void
		{
			sound.load(new URLRequest(audioURL));
			channel = sound.play();
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
        
		/**
		 * Creates a 2d sprite with the given arguments
		 */
        private function getNucleicSprite(x:Number, y:Number, z:Number, radius:Number, red:int, green:int, blue:int):Sprite3D
        {
        	var nucleicBitmap:BitmapData = new BitmapData(radius*2, radius*2, true, 0x00000000);
			var bitmapShape:Shape = new Shape();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(radius*2, radius*2, 0, 0, 0);
			var color:int = red << 16 | green << 8 | blue;
			bitmapShape.graphics.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, color, color], [1, 1, 0], [0, 127, 255], matrix);
			bitmapShape.graphics.drawCircle(radius, radius, radius);
			nucleicBitmap.draw(bitmapShape);
			
			//var sprite2D:Sprite2D = new Sprite2D(nucleicBitmap, {scaling:2, x:x, y:y, z:z});
			var sprite3D:Sprite3D = new Sprite3D(new BitmapMaterial(nucleicBitmap));
			sprite3D.scaling = 2;
			sprite3D.x = x;
			sprite3D.y = y;
			sprite3D.z = z;
			return sprite3D;
        }
        
		/**
		 * Render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			//rotate the container
			container.rotationX += 2;
			container.rotationY += 2;
			
			//advance the sprites
			addNum += 0.2;
			
			if (sound)
				SoundMixer.computeSpectrum(spectrum, true); 
			
			//draw the equaliser
			peak = 0;
			backGraphics.clear(); 
		    backGraphics.moveTo(255, 255); 
		    backGraphics.beginFill(0x006633); 
			var i:int = 512;
			while(i--)
			{
				var lev:Number = spectrum.readFloat();
				if ((i > 512 - maxlevel && i < 512 - minlevel) || (i > 256 - maxlevel && i < 256 - minlevel))
        			peak += lev;
				
        		var a:int;
        		if (i == 255) {
        			backGraphics.lineTo(511, 255);
        			backGraphics.lineTo(255, 255);
        		}
        		if (i < 256) {
        			a = i;
        			backGraphics.lineTo(a, 250 - lev*400*Math.pow(2,-a/256));
        		} else {
        			a = i - 256;
        			backGraphics.lineTo(511 - a, 250 - lev*400*Math.pow(2,-a/256));
        		}
			}
			backGraphics.lineTo(0, 255);
			backGraphics.endFill();
			
			var mat:Matrix = new Matrix();
			var col:ColorTransform = new ColorTransform(0.95, 0.95, 0.95);
			mat.translate(0, -5);
			transBitmap = backBitmap.clone();
			backBitmap.draw(transBitmap, mat, col);
			backBitmap.draw(backShape);
			
			tubeMaterial.bitmap = backBitmap;
			
			//calculate the sprite offset
			peak = spheresDistance*(channel.leftPeak + channel.rightPeak)/2;
			
			if (distance < peak) {
				distance = peak;
				distance += (peak - distance)/2;
				distancespeed = 0;
			} else if (distance) {
				distancespeed -= 10;
				distance += distancespeed;
				if (distance < 0)
					distance = 0;
			}
			
			//draw sprite torusknot
			var j:int = spheresNum;
			while (j--)
			{
				sprite = container.sprites[j];
				
				sprite.x = distance*Math.cos((j + addNum)*Math.PI*10/spheresNum);
				sprite.y = distance*Math.sin((j + addNum)*Math.PI*4/spheresNum);
				sprite.z = distance*Math.sin((j + addNum)*Math.PI*20/spheresNum);
			}
			
			view.render();
		}
		
		/**
		 * Key down listener for fullscreen
		 */
        private function onKeyDown(event:KeyboardEvent):void
        {
        	switch (event.keyCode)
            {
            	case Keyboard.ENTER:
            		if (stage.displayState == StageDisplayState.FULL_SCREEN)
                		stage.displayState = StageDisplayState.NORMAL;
                	else 
                		stage.displayState = StageDisplayState.FULL_SCREEN;
                	break;
            }
        }
		
		/**
		 * stage listener for resize events
		 */
        private function onResize(event:Event = null):void 
        {
            view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
            TrackText.y = stage.stageHeight - TrackText.height - 10;
            TrackText.x = stage.stageWidth - TrackText.width - 10;
        }
	}
}
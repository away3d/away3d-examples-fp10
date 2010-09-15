/*

Md2 animation example in Away3d

Demonstrates:

How to import and display an md2 file.
How to control the various animations contained within an md2 file.

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
	import away3d.core.utils.*;
	import away3d.debug.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.test.Button;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Intermediate_MD2Animation extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public static var SignatureSwf:Class;
    	
		//ogre md2 file
		[Embed(source="assets/ogre.md2",mimeType="application/octet-stream")]
		private var OgreMesh:Class;
		
		//ogre texture jpg
		[Embed(source="assets/ogre.jpg")]
		private var OgreTexture:Class;
		
		//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material:BitmapMaterial;
		
		//scene objects
		private var md2:Md2;
		private var model:Mesh;
		
		//button objects
		private var standButton:Button;
		private var runButton:Button;
		private var attackButton:Button;
		private var pain1Button:Button;
		private var pain2Button:Button;
		private var pain3Button:Button;
		private var jumpButton:Button;
		private var flipButton:Button;
		private var saluteButton:Button;
		private var flopButton:Button;
		private var waveButton:Button;
		private var sniffButton:Button;
		private var cstandButton:Button;
		private var cwalkButton:Button;
		private var crattackButton:Button;
		private var crpainButton:Button;
		private var crdeathButton:Button;
		private var death1Button:Button;
		private var death2Button:Button;
		private var death3Button:Button;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Intermediate_MD2Animation()
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
			initButtons();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			
			camera = new HoverCamera3D();
			
			camera.panAngle = 45;
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
			material = new BitmapMaterial(Cast.bitmap(OgreTexture));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//model = Md2.parse(OgreMesh, {material:material}) as Mesh;
			md2 = new Md2();
			md2.fps = 7;
			model = md2.parseGeometry(OgreMesh) as Mesh;
			model.material = material;
			
			model.scale(0.05);
			scene.addChild(model);
			
			//setup animations
			model.animationLibrary.getAnimation("deatha").animator.loop = false;
			model.animationLibrary.getAnimation("deathb").animator.loop = false;
			model.animationLibrary.getAnimation("deathc").animator.loop = false;
			
			model.animationLibrary.getAnimation("stand").animator.play();
		}
		
		/**
		 * Initialise the buttons
		 */
		private function initButtons():void
		{
			standButton = new Button("Stand", 100);
            standButton.x = 580;
            standButton.y = 40;
            addChild(standButton);
            runButton = new Button("Run", 100);
            runButton.x = 580;
            runButton.y = 80;
            addChild(runButton);
            attackButton = new Button("Attack", 100);
            attackButton.x = 580;
            attackButton.y = 120;
            addChild(attackButton);
            pain1Button = new Button("Pain 1", 100);
            pain1Button.x = 580;
            pain1Button.y = 160;
            addChild(pain1Button);
            pain2Button = new Button("Pain 2", 100);
            pain2Button.x = 580;
            pain2Button.y = 200;
            addChild(pain2Button);
            pain3Button = new Button("Pain 3", 100);
            pain3Button.x = 580;
            pain3Button.y = 240;
            addChild(pain3Button);
            jumpButton = new Button("Jump", 100);
            jumpButton.x = 580;
            jumpButton.y = 280;
            addChild(jumpButton);
            flipButton = new Button("Flip", 100);
            flipButton.x = 580;
            flipButton.y = 320;
            addChild(flipButton);
            saluteButton = new Button("Salute", 100);
            saluteButton.x = 580;
            saluteButton.y = 360;
            addChild(saluteButton);
            flopButton = new Button("Flop", 100);
            flopButton.x = 580;
            flopButton.y = 400;
            addChild(flopButton);
            waveButton = new Button("Wave", 100);
            waveButton.x = 580;
            waveButton.y = 440;
            addChild(waveButton);
            sniffButton = new Button("Sniff", 100);
            sniffButton.x = 580;
            sniffButton.y = 480;
            addChild(sniffButton);
            cstandButton = new Button("Stand", 100);
            cstandButton.x = 690;
            cstandButton.y = 40;
            addChild(cstandButton);
            cwalkButton = new Button("Run", 100);
            cwalkButton.x = 690;
            cwalkButton.y = 80;
            addChild(cwalkButton);
            crattackButton = new Button("Attack", 100);
            crattackButton.x = 690;
            crattackButton.y = 120;
            addChild(crattackButton);
            crpainButton = new Button("Pain", 100);
            crpainButton.x = 690;
            crpainButton.y = 160;
            addChild(crpainButton);
            crdeathButton = new Button("Death", 100);
            crdeathButton.x = 690;
            crdeathButton.y = 200;
            addChild(crdeathButton);
            death1Button = new Button("Death 1", 100);
            death1Button.x = 690;
            death1Button.y = 240;
            addChild(death1Button);
            death2Button = new Button("Death 2", 100);
            death2Button.x = 690;
            death2Button.y = 280;
            addChild(death2Button);
            death3Button = new Button("Death 3", 100);
            death3Button.x = 690;
            death3Button.y = 320;
            addChild(death3Button);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(MouseEvent.CLICK, onButtonClick);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * button listener for switching md2 animation
		 */
        private function onButtonClick(event:Event):void
        {
        	var button:Button = event.target as Button;
        	
        	switch(button) {
        		case standButton:
        			model.animationLibrary.getAnimation("stand").animator.play();
        			break;
        		case runButton:
        			model.animationLibrary.getAnimation("run").animator.play();
        			break;
        		case attackButton:
        			model.animationLibrary.getAnimation("attack").animator.play();
        			break;
        		case pain1Button:
        			model.animationLibrary.getAnimation("paina").animator.play();
        			break;
        		case pain2Button:
        			model.animationLibrary.getAnimation("painb").animator.play();
        			break;
        		case pain3Button:
        			model.animationLibrary.getAnimation("painc").animator.play();
        			break;
        		case jumpButton:
        			model.animationLibrary.getAnimation("jump").animator.play();
        			break;
        		case flipButton:
        			model.animationLibrary.getAnimation("flip").animator.play();
        			break;
        		case saluteButton:
        			model.animationLibrary.getAnimation("salute_alt").animator.play();
        			break;
        		case flopButton:
        			model.animationLibrary.getAnimation("bumflop").animator.play();
        			break;
        		case waveButton:
        			model.animationLibrary.getAnimation("wavealt").animator.play();
        			break;
        		case sniffButton:
        			model.animationLibrary.getAnimation("sniffsniff").animator.play();
        			break;
        		case death1Button:
        			model.animationLibrary.getAnimation("deatha").animator.gotoAndPlay(0);
        			break;
        		case death2Button:
        			model.animationLibrary.getAnimation("deathb").animator.gotoAndPlay(0);
        			break;
        		case death3Button:
        			model.animationLibrary.getAnimation("deathc").animator.gotoAndPlay(0);
        			break;
        		case cstandButton:
        			model.animationLibrary.getAnimation("cstand").animator.play();
        			break;
        		case cwalkButton:
        			model.animationLibrary.getAnimation("cwalk").animator.play();
        			break;
        		case crattackButton:
        			model.animationLibrary.getAnimation("crattack").animator.play();
        			break;
        		case crpainButton:
        			model.animationLibrary.getAnimation("crpain").animator.play();
        			break;
        		case crdeathButton:
        			model.animationLibrary.getAnimation("crdeath").animator.play();
        			break;
        		default:
        	}
        }
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (model)
				model.rotationY += 0.5;
			
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
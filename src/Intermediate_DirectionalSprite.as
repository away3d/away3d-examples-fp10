/*

Directional Sprite example in Away3d

Demonstrates:

How to use the DirSprite2D.
How to override the tick method on an ObjectContainer3D to provide individual custom functionality for 3d objects.

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
	import away3d.core.utils.Cast;
	import away3d.lights.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW", width="800", height="600")]
	
	public class Intermediate_DirectionalSprite extends Sprite
	{
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
    	//plane texture jpg
    	[Embed(source="assets/yellow.jpg")]
    	public static var YellowImage:Class;
    	
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
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Intermediate_DirectionalSprite()
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
			
			//camera = new HoverCamera3D({focus:50, distance:50, mintiltangle:0, maxtiltangle:90});
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.distance = 1000;
			camera.minTiltAngle = 0;
			camera.maxTiltAngle = 90;
			
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
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			planeMaterial = new BitmapMaterial(Cast.bitmap(YellowImage));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//plane = new Plane({material:planeMaterial, y:-40, width:1000, height:1000, pushback:true});
			plane = new Plane();
			plane.material = planeMaterial;
			plane.y = -40;
			plane.width = 1000;
			plane.height = 1000;
			plane.pushback = true;
			
			scene.addChild(plane);
			
			var iTotal:int = 3;
			var jTotal:int = 3;
			var lostSoul:LostSoul;
			for (var i:int = 0; i < iTotal; i++) {
				for (var j:int = 0; j < jTotal; j++) {
					//lostSoul = new LostSoul({x:i*600/(iTotal - 1) - 300, z:j*600/(jTotal - 1) - 300, rotationY:Math.random()*360});
					lostSoul = new LostSoul();
					lostSoul.x = i*600/(iTotal - 1) - 300;
					lostSoul.z = j*600/(jTotal - 1) - 300;
					lostSoul.rotationY = Math.random()*360;
					scene.addChild(lostSoul);
				}	
			}
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
			//update all tick methods
			scene.updateTime(getTimer());
			
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

import away3d.sprites.*;
import away3d.core.utils.*;
import away3d.events.*;
import flash.display.*;

/**
 * Class for creating moving lost soul sprite
 */
class LostSoul extends DirSprite2D
{
	
	[Embed(source="assets/ls_front.png")]
	private var LostSoulFrontImage:Class;
	
	[Embed(source="assets/ls_leftfront.png")]
	private var LostSoulLeftFrontImage:Class;
	
	[Embed(source="assets/ls_left.png")]
	private var LostSoulLeftImage:Class;
	
	[Embed(source="assets/ls_leftback.png")]
	private var LostSoulLeftBackImage:Class;
	
	[Embed(source="assets/ls_back.png")]
	private var LostSoulBackImage:Class;
	
    private var role:String;
    private var nextthink:int;
    private var lastmove:int;
	
	/**
	 * Constructor
	 */
    public function LostSoul(init:Object = null)
    {
        super(init);
        
        scaling = 2;
        
        add( 0  , 0,-1  , Cast.bitmap(LostSoulFrontImage));
        add(-0.7, 0,-0.7, Cast.bitmap(LostSoulLeftFrontImage));
        add(-1  , 0, 0  , Cast.bitmap(LostSoulLeftImage));
        add(-0.7, 0, 0.7, Cast.bitmap(LostSoulLeftBackImage));
        add( 0  , 0, 1  , Cast.bitmap(LostSoulBackImage));
        add( 0.7, 0, 0.7, flipX(Cast.bitmap(LostSoulLeftBackImage)));
        add( 1  , 0, 0  , flipX(Cast.bitmap(LostSoulLeftImage)));
        add( 0.7, 0,-0.7, flipX(Cast.bitmap(LostSoulLeftFrontImage)));
    }
    
    /**
    * Updates every frame
    */
    public override function tick(time:int):void
    {
        if ((role == null) || (nextthink < time)) {
            role = (["stop", "right", "left", "forward"])[int(Math.random()*4)];
            if ((Math.abs(x) > 300) || (Math.abs(z) > 300))
                role = "right";
                //role = (["right", "left"])[int(Math.random()*2)];
            nextthink = time + Math.random()*3000;
        }

        var delta:Number = (lastmove - time)/1000;
        
        switch (role) {
            case "stop":
            	rotationY += delta*(Math.random()*20-10);
            	break;
            case "right":
            	rotationY += delta*Math.random()*10; moveForward(delta*20);
            	break;
            case "left":
            	rotationY -= delta*Math.random()*10; moveForward(delta*20);
            	break;
            case "forward":
            	moveForward(delta*60)
            	break;
            default:
        }
        
        lastmove = time;
		
		//constrain position
        if (x > 500)
            x = 500;
        if (x < -500)
            x = -500;
        if (z > 500)
            z = 500;
        if (z < -500)
            z = -500;
    }
    
    /**
    * Creates a mirror bitmapData object from the input bitmapData argument
    */
    public function flipX(source:BitmapData):BitmapData
    {
        var bitmap:BitmapData = new BitmapData(source.width, source.height);
        for (var i:int = 0; i < bitmap.width; i++)
            for (var j:int = 0; j < bitmap.height; j++)
                bitmap.setPixel32(i, j, source.getPixel32(source.width-i-1, j));
        return bitmap;
    }
}
package 
{
	import away3d.debug.AwayStats;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.math.*;
	import away3d.core.utils.Cast;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Away3DSkyBall extends Sprite
	{
		[Embed(source="assets/sky.jpg")]
		private var Sky:Class;
		
		[Embed(source="assets/smiley.gif")]
		public static var SmileyImage:Class;
		
		private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		private var projectionNum:int = 6;
		
		private var skyMaterial:BitmapMaterial;
		private var sphereMaterial:CompositeMaterial;
        private var projectedMaterialArray:Array = new Array();
        private var projectedMaterial:TransformBitmapMaterial;
        
        private var projectionVectorArray:Array = new Array();
        private var projectionVector:Number3D;
        
		private var skysphere:Sphere;
		private var innersphere:Sphere;
		
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		public function Away3DSkyBall() 
		{
			init();
		}
		
		private function init():void
		{
			initEngine();
			initMaterials();
			initObjects();
			initListeners();
		}
		
		private function initEngine():void
		{
			scene = new Scene3D();
			
			camera = new HoverCamera3D({zoom:10, focus:40});
			camera.minTiltAngle = -80;
			camera.maxTiltAngle = 20;
			camera.panAngle = 90;
			camera.tiltAngle = 0;
			
			view = new View3D({scene:scene, camera:camera});
			view.x = 400;
			view.y = 300;
			addChild( view );
			
			addChild(new AwayStats(view));
		}
		
		private function initMaterials():void
		{
			skyMaterial = new BitmapMaterial( Cast.bitmap(Sky) );
			sphereMaterial = new CompositeMaterial({width:1024, height:512, materials:[Cast.material(Sky)], surfaceCache:true});
			
			
		}
		
		private function initObjects():void
		{
			skysphere = new Sphere({material:skyMaterial, radius:50000, rotationX:180, segmentsW:10, segmentsH:12});
			skysphere.scale(-1);
			innersphere = new Sphere({material:sphereMaterial, radius:250, segmentsW:10, segmentsH:12});
			scene.addChild( skysphere );
			scene.addChild( innersphere );
			var i:int = projectionNum;
			while (i--) {
				projectedMaterial = new TransformBitmapMaterial(Cast.bitmap(SmileyImage), {throughProjection:true});
				sphereMaterial.addMaterial(projectedMaterial);
				projectedMaterialArray.push(projectedMaterial);
				projectionVectorArray.push(new Number3D());
			}
			
			i = projectionNum;
			var time:int = getTimer();
			while (i--) {
				projectionVector = projectionVectorArray[i];
				projectedMaterial = projectedMaterialArray[i];
				switch(i)
				{
					case 0:
						projectionVector.x = (Math.sin(time/500));
				    	projectionVector.y = 1;
				    	projectionVector.z = (Math.cos(time/500));
				    	projectedMaterial.rotation = time/1000;
				    	break;
				    case 1:
				    	projectionVector.x = (Math.cos(-time/500));
				    	projectionVector.y = (Math.sin(time/500));
				    	projectionVector.z = 1;
				    	projectedMaterial.rotation = time/500;
				    	break;
				     case 2:
				    	projectionVector.x = 1;
				    	projectionVector.y = (Math.sin(-time/500));
				    	projectionVector.z = (Math.cos(-time/500));
				    	projectedMaterial.rotation = time/250;
				    	break;
				    case 3:
				    	projectionVector.x = (Math.cos(-time/500));
				    	projectionVector.y = 1;
				    	projectionVector.z = (Math.sin(-time/500));
				    	projectedMaterial.rotation = time/125;
				    	break;
				    case 4:
				    	projectionVector.x = 1;
				    	projectionVector.y = (Math.cos(-time/500));
				    	projectionVector.z = (Math.sin(-time/500));
				    	projectedMaterial.rotation = time/75;
				    	break;
				    case 5:
				    	projectionVector.x = 1;
				    	projectionVector.y = (Math.sin(time/500));
				    	projectionVector.z = (Math.cos(-time/500));
				    	projectedMaterial.rotation = time/250;
				}
				projectedMaterial.projectionVector = projectionVector;
			}
		}
		
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onEnterFrame(event:Event):void
		{
			if (move) {
				camera.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			var i:int = projectionNum;
			var time:int = getTimer();
			while (i--) {
				projectionVector = projectionVectorArray[i];
				projectedMaterial = projectedMaterialArray[i];
				switch(i)
				{
					case 0:
						projectionVector.x = (Math.sin(time/500));
				    	projectionVector.y = 1;
				    	projectionVector.z = (Math.cos(time/500));
				    	projectedMaterial.rotation = time/1000;
				    	break;
				    case 1:
				    	projectionVector.x = (Math.cos(-time/500));
				    	projectionVector.y = (Math.sin(time/500));
				    	projectionVector.z = 1;
				    	projectedMaterial.rotation = time/500;
				    	break;
				     case 2:
				    	projectionVector.x = 1;
				    	projectionVector.y = (Math.sin(-time/500));
				    	projectionVector.z = (Math.cos(-time/500));
				    	projectedMaterial.rotation = time/250;
				    	break;
				    case 3:
				    	projectionVector.x = (Math.cos(-time/500));
				    	projectionVector.y = 1;
				    	projectionVector.z = (Math.sin(-time/500));
				    	projectedMaterial.rotation = time/125;
				    	break;
				    case 4:
				    	projectionVector.x = 1;
				    	projectionVector.y = (Math.cos(-time/500));
				    	projectionVector.z = (Math.sin(-time/500));
				    	projectedMaterial.rotation = time/75;
				    	break;
				    case 5:
				    	projectionVector.x = 1;
				    	projectionVector.y = (Math.sin(time/500));
				    	projectionVector.z = (Math.cos(-time/500));
				    	projectedMaterial.rotation = time/250;
				}
				projectedMaterial.projectionVector = projectionVector;
			}
			
			camera.hover();  
			view.render();
		}
		
		private function onMouseDown(event:MouseEvent):void
        {
            lastPanAngle = camera.panAngle;
			lastTiltAngle = camera.tiltAngle;
			lastMouseX = stage.mouseX;
            lastMouseY = stage.mouseY;
        	move = true;
        	stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
		
        private function onMouseUp(event:MouseEvent):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
        
        private function onStageMouseLeave(event:Event):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
	}
}
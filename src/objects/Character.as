package objects 
{
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import screens.Animation;
	//
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Common.Math.b2Vec2;
	//
	import com.reyco1.physinjector.data.PhysicsObject;
	import com.reyco1.physinjector.data.PhysicsProperties;
	import com.reyco1.physinjector.PhysInjector;
	import com.reyco1.physinjector.contact.ContactManager;
	
	
	
	
	/**
	 * ...
	 * @author 
	 */
	public class Character extends Sprite
	{
		private var character_animation:Animation;
		public var dimension:Number = 128;
		private var charobject:PhysicsObject;
		private var LEFT:Boolean;
		private var RIGHT:Boolean;
		private var JUMP:Boolean;
		private var physics:PhysInjector;
		private var floor:PhysicsObject;
		private var vMaxX:Number = 5.7;
		private var lastDate:Date= new Date();
		private var currentDate:Date = new Date();
		//private var lastMS:Number=0;
		//private var newMS:Number = 101;
		private var OnFloor:Boolean = true;
		
		public function Character(fisicas:PhysInjector) 
		{
			super();
			physics = fisicas;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			trace("Carga Personaje");
			
			character_animation =  new Animation(Assets.getAtlas());
			character_animation.addAnimation("Idleanimation128_", 5,true);
			character_animation.addAnimation("JumpAnimation128_", 7,false);
			character_animation.play("Idleanimation128_");
			addChild(character_animation);
			
		/*	character = new MovieClip(Assets.getAtlas().getTextures("Idleanimation128_"), 7);
			character.width = dimension/2;
			character.height = dimension;
			character.x = (Starling.current.nativeStage.stageWidth - character.width) / 2;
			character.y = (Starling.current.nativeStage.stageHeight - character.height - 100);
			Starling.juggler.add(character);
			this.addChild(character);*/
			
			//charobject = physics.injectPhysics(character, PhysInjector.SQUARE, new PhysicsProperties( { isDynamic:true, friction:0.2, restitution: 0,linearDamping:1 } ));
			
			charobject = physics.injectPhysics(character_animation, PhysInjector.SQUARE, new PhysicsProperties( { isDynamic:true, friction:0.2, restitution: 0,linearDamping:1 } ));
			charobject.y = 635.4749999999999;
			charobject.physicsProperties.density = 1;
			charobject.body.SetFixedRotation(true);
			//charobject.physicsProperties.isDraggable = false;
			charobject.name = "char";
			
			addEventListener(KeyboardEvent.KEY_DOWN, Movement);
			addEventListener(KeyboardEvent.KEY_UP, Stop);
			addEventListener(EnterFrameEvent.ENTER_FRAME, updateMovement);
			//ContactManager.onContactBegin("char", "balloon", Rebound);
			ContactManager.onContactBegin("char", "floor", JumpFromFloor);
			//ContactManager.onContactEnd("char", "floor", 
	
			//
			
			//usar el bounds, intersects (cuerpo.bounds) 
			
			//
			
		}
			
		private function Movement(event:KeyboardEvent):void
		{
			
			switch (event.keyCode)
			{
			  case 39: //derecha
				RIGHT = true;
				break;
			  case 37: //izquierda
				LEFT = true;
				break;
			  case 32: //barra
				if (!JUMP)
				{
					lastDate = new Date(); //fecha de cuando apreto
					JUMP = true;
				}
				break;
			}
		}
		
		private function Stop(event:KeyboardEvent):void 
		{
			switch (event.keyCode)
			{
			  case 39: //derecha
				RIGHT = false;
				break;
			  case 37: //izquierda
				LEFT = false;
				break;
			  case 32: //barra
				JUMP = false;
				break;
			}
		}
		
		private function updateMovement():void
		{
			character_animation.y = charobject.y;
			
			if (charobject.x < 0) charobject.x = Starling.current.nativeStage.stageWidth;
			else if (charobject.x > Starling.current.nativeStage.stageWidth) charobject.x=0;

			if (LEFT)
			{
				if (charobject.body.GetLinearVelocity().x > -5.4) charobject.body.ApplyForce(new b2Vec2( -18, 0), charobject.body.GetLocalCenter());
				else (charobject.body.SetLinearVelocity(new b2Vec2(-vMaxX, charobject.body.GetLinearVelocity().y)));
			}
			if (RIGHT) 
			{
				if (charobject.body.GetLinearVelocity().x < 5.4) charobject.body.ApplyForce(new b2Vec2( 18, 0), charobject.body.GetLocalCenter());
				else (charobject.body.SetLinearVelocity(new b2Vec2(vMaxX, charobject.body.GetLinearVelocity().y)));
			}
			if (OnFloor && JUMP)
			{
				character_animation.play("JumpAnimation128_");

				OnFloor = false;
				charobject.body.ApplyImpulse(new b2Vec2( 0, -20), charobject.body.GetLocalCenter()); //impulso normal	
			}
		}
		
	/*	private function Rebound(ObjectA:PhysicsObject, ObjectB:PhysicsObject, contact:b2Contact):void
		{
			
			if (ObjectA.y + 64 <= ObjectB.y + 16)
			{
				//trace("entra");
				ObjectA.body.SetLinearVelocity(new b2Vec2(ObjectA.body.GetLinearVelocity().x, 0));
				if (!OnFloor && JUMP)
				{
					currentDate = new Date(); //fecha de cuando choca
					lastMS = lastDate.getMilliseconds(); //tiempo de cuando apreto boton JUMP
					newMS = currentDate.getMilliseconds(); // tiempo de choque
					
					if (newMS < lastMS) 
					{
						if (1000 + newMS - lastMS <= 100) ObjectA.body.ApplyImpulse(new b2Vec2( 0, -20), ObjectA.body.GetLocalCenter()); //impulso extra
					}
					else
					{
						if (newMS - lastMS <= 100) ObjectA.body.ApplyImpulse(new b2Vec2( 0, -20), ObjectA.body.GetLocalCenter()); //impulso extra
					}
					JUMP = false;
				}
				else
				{
					ObjectA.body.ApplyImpulse(new b2Vec2( 0, -15), ObjectA.body.GetLocalCenter()); //impulso normal
				}
				
			}
			else
			{
				// aqui intentaba hacer una colisión continua utilizando algunas funciones del contact, pero no he sabido como implementarlas
				
				//trace(contact.IsTouching());
				//if (contact.IsContinuous()) ContactManager.onContactBegin("char", "balloon", Rebound);
			}
		}*/
		
		private function JumpFromFloor(ObjectA:PhysicsObject, ObjectB:PhysicsObject, contact:b2Contact):void
		{
			OnFloor = true;
		}
		
		public function GetPosY():Number
		{
			return charobject.y;
		}
		
		public function GetInitPosY():Number
		{
			return 635.4749999999999;
		}
		
		public function GetJumpValue():Boolean
		{
			return JUMP;
		}
		
		public function GetOnFloorValue():Boolean
		{
			return OnFloor;
		}
		
		public function GetLastDate():Date
		{
			return lastDate;
		}
		
		public function Impulsed():void
		{
			JUMP = false;
		}
	}
}
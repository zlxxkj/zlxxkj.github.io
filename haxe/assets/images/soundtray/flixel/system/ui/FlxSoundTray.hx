package flixel.system.ui;

import openfl.Assets;
#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
#end

import funkin.backend.assets.Paths;
import funkin.backend.utils.CoolUtil;

class FlxSoundTray extends Sprite
{
	public var active:Bool;
	var _timer:Float;
	var _bars:Array<Bitmap>;
	var _width:Int = 80;
	var _defaultScale:Float = 2.0;
	var lerpYPos:Float = 0;
	var alphaTarget:Float = 0;

	//volume Sound path
	public var volumeUpSound:String = "soundtray/Voldown";
	public var volumeDownSound:String = 'soundtray/Volup';
	public var volumeMaxSound:String = 'soundtray/VolMAX';
	
	public var silent:Bool = false;
	public var visual:Bool = true;

	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		var tmp:Bitmap = new Bitmap(Assets.getBitmapData(Paths.getPath('images/soundtray/volumebox.png')));
		tmp.scaleY = 0.3;
		tmp.scaleX = 0.3;
		addChild(tmp);

		var backingBar:Bitmap = new Bitmap(Assets.getBitmapData(Paths.getPath('images/soundtray/bars_11.png')));
		backingBar.x = 9;
		backingBar.y = 5;
		backingBar.scaleX = 0.3;
		backingBar.scaleY = 0.3;
		//backingBar.alpha = 0.5;//I fix SoundTray Alpha problem!
		addChild(backingBar);

		var bx:Int = 9;
		var by:Int = 5;
		_bars = new Array();

		for (i in 1...11)
		{
			tmp = new Bitmap(Assets.getBitmapData(Paths.getPath('images/soundtray/bars_$i.png')));
			tmp.x = bx;
			tmp.y = by;
			tmp.scaleX = tmp.scaleY = 0.3;
			addChild(tmp);
			_bars.push(tmp);
		}

		y = -height;
		visible = false;
	}

	public function update(MS:Float):Void
	{
		y = CoolUtil.fpsLerp(y, lerpYPos, 0.1);
		alpha = CoolUtil.fpsLerp(alpha, alphaTarget, 0.25);
		
		// Animate sound tray thing
		if (_timer > 0)
		{
			_timer -= (MS / 1000);
			alphaTarget = 1;
		}
		else if (y >= -height)
		{
			lerpYPos = -height - 10;
			alphaTarget = 0;
		}
		
		if (y <= -height)
		{
			visible = false;
			active = false;
			
			#if FLX_SAVE
			// Save sound preferences
			if (FlxG.save.isBound)
			{
				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				FlxG.save.flush();
			}
			#end
		}	}

	public function show(up:Bool = false):Void
	{
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (!silent)
		{
			var sound = up ? volumeUpSound : volumeDownSound;
			
			if (globalVolume == 10) sound = volumeMaxSound;
			
			if (sound != null) FlxG.sound.play(Paths.sound(sound));
		}

		if (!visual) return;
		_timer = 1;
		lerpYPos = 10;
		visible = true;
		active = true;
		for (child in 0...numChildren) getChildAt(child).alpha = 1;

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		for (i in 0..._bars.length)
			_bars[i].visible = i < globalVolume;
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end
/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.chrome.controlbar.widgets
{
	import flash.events.Event;
	
	import org.osmf.events.DVREvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	public class LiveButton extends Button
	{
		[Embed("../assets/images/live_up.png")]
		public var liveUpType:Class;
		[Embed("../assets/images/live_down.png")]
		public var liveDownType:Class;
		[Embed("../assets/images/live_disabled.png")]
		public var liveDisabledType:Class;
		
		public function LiveButton(up:Class = null, down:Class = null, disabled:Class = null)
		{
			super
				( up || liveUpType
				, down || liveDownType
				, disabled || liveDisabledType
				);
		}
		
		// Overrides
		//
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			dvrTrait = element.getTrait(MediaTraitType.DVR) as DVRTrait;
			dvrTrait.addEventListener(DVREvent.IS_RECORDING_CHANGE, visibilityDeterminingEventHandler);
			
			timeTrait = element.getTrait(MediaTraitType.TIME) as TimeTrait;
			timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, visibilityDeterminingEventHandler);
			
			visibilityDeterminingEventHandler();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			if (dvrTrait)
			{
				dvrTrait.removeEventListener(DVREvent.IS_RECORDING_CHANGE, visibilityDeterminingEventHandler);
				dvrTrait = null;
			}
			
			if (timeTrait)
			{
				timeTrait = null;
				timeTrait.removeEventListener(TimeEvent.DURATION_CHANGE, visibilityDeterminingEventHandler);
			}
			
			visibilityDeterminingEventHandler();
		}
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		// Internals
		//
		
		private function visibilityDeterminingEventHandler(event:Event = null):void
		{
			visible
				=	dvrTrait != null
				&&	dvrTrait.isRecording == true
				&&	timeTrait
				&&	timeTrait.currentTime >= Math.max(0, dvrTrait.lastRecordedTime - 5);
		}
		
		private var dvrTrait:DVRTrait;
		private var timeTrait:TimeTrait;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.DVR;
		_requiredTraits[1] = MediaTraitType.TIME;
	}
}
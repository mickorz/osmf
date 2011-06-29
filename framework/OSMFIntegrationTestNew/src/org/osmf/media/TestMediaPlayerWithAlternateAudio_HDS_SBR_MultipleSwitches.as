/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.media
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.assertThat;
	import org.hamcrest.number.greaterThanOrEqualTo;
	import org.hamcrest.object.equalTo;

	/**
	 * Class tests late binding audio behavior when consecutive changes are
	 * requested.
	 */
	public class TestMediaPlayerWithAlternateAudio_HDS_SBR_MultipleSwitches extends TestMediaPlayerHelper
	{
		/**
		 * Tests the late-binding behavior when another switch command is issued without 
		 * waiting the completion of the first one. Once the player is ready, before we start 
		 * playing, we issue two consecutive switchAlternateAudioIndex commands.
		 */ 
		[Test(async, timeout="60000", order=1)]
		public function playLive_ConsecutiveSwitches_NoWait_BeforePlay():void
		{
			const testLenght:uint = DEFAULT_TEST_LENGTH;
			
			var expectedData:Object = new Object();
			expectedData["numAlternativeAudioStreams"] = 2;
			expectedData["selectedIndex_onReady"] = -1;
			expectedData["selectedIndex_onComplete"] = 0;
			
			runAfterInterval(this, testLenght, playerHelper.info, onComplete, onTimeout);
			
			function setUpEvents(playerHelper:MediaPlayerHelper, add:Boolean):void
			{
				if (add)
				{
					playerHelper.addEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.addEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.addEventListener(MediaPlayerHelper.ERROR, 		onError);
				}
				else
				{
					playerHelper.removeEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.removeEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.removeEventListener(MediaPlayerHelper.ERROR, 		onError);
				}
			}
			
			setUpEvents(playerHelper, true);
			playerHelper.mediaResource = new URLResource(ALTERNATE_AUDIO_HDS_SBR_WITH_LIVE);
			
			var switchInitiated:Boolean = false;
			function onReady(event:Event):void
			{
				assertThat("We should have access to alternatve audio information", playerHelper.actualPlayer.hasAlternativeAudio);
				assertThat("The number of alternative audio streams is equal with the expected one.", playerHelper.actualPlayer.numAlternativeAudioStreams, equalTo(expectedData.numAlternativeAudioStreams));				assertThat("No alternate audio stream change is in progress.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(false));
				assertThat("No alternate audio stream is selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onReady));
				
				if (!switchInitiated)
				{
					switchInitiated = true;
					playerHelper.actualPlayer.switchAlternativeAudioIndex(1);
					playerHelper.actualPlayer.switchAlternativeAudioIndex(0);
				}
				
				playerHelper.actualPlayer.play();
			}
			
			function onPlaying(event:Event):void
			{
			}
			
			function onComplete(passThroughData:Object):void
			{
				assertThat("Specified alternate audio stream is selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onComplete));
				
				setUpEvents(playerHelper, false);
			}
		}

		/**
		 * Tests the late-binding behavior when another switch command is issued without 
		 * waiting the completion of the first one. Once the player is ready, we start playing 
		 * the media element and when the player changes its state to playing state, we issue
		 * two consecutive switchAlternateAudioIndex commands.
		 */ 
		[Test(async, timeout="60000", order=2)]
		public function playLive_ConsecutiveSwitches_NoWait_AfterPlay():void
		{
			const testLenght:uint = DEFAULT_TEST_LENGTH;
			
			var expectedData:Object = new Object();
			expectedData["numAlternativeAudioStreams"] = 2;
			expectedData["selectedIndex_onReady"] = -1;
			expectedData["selectedIndex_onComplete"] = 1;
			
			runAfterInterval(this, testLenght, playerHelper.info, onComplete, onTimeout);

			function setUpEvents(playerHelper:MediaPlayerHelper, add:Boolean):void
			{
				if (add)
				{
					playerHelper.addEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.addEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.addEventListener(MediaPlayerHelper.ERROR, 		onError);
				}
				else
				{
					playerHelper.removeEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.removeEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.removeEventListener(MediaPlayerHelper.ERROR, 		onError);
				}
			}
			
			setUpEvents(playerHelper, true);
			playerHelper.mediaResource = new URLResource(ALTERNATE_AUDIO_HDS_SBR_WITH_LIVE);
				
			function onReady(event:Event):void
			{
				assertThat("We should have access to alternatve audio information", playerHelper.actualPlayer.hasAlternativeAudio);
				assertThat("The number of alternative audio streams is equal with the expected one.", playerHelper.actualPlayer.numAlternativeAudioStreams, equalTo(expectedData.numAlternativeAudioStreams));				assertThat("No alternate audio stream change is in progress.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(false));
				assertThat("No alternate audio stream is selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onReady));
				playerHelper.actualPlayer.play();
			}
			
			var switchInitiated:Boolean = false;
			function onPlaying(event:Event):void
			{
				if (!switchInitiated)
				{
					switchInitiated = true;
					playerHelper.actualPlayer.switchAlternativeAudioIndex(0);
					playerHelper.actualPlayer.switchAlternativeAudioIndex(1);
				}
			}
			
			function onComplete(passThroughData:Object):void
			{
				assertThat("Specified alternate audio stream is selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onComplete));
				
				setUpEvents(playerHelper, false);
			}
		}
		
		/**
		 * Tests the late-binding behavior when we switch back to the default audio track 
		 * after the switch to an alternate track was successful.
		 */ 
		[Test(async, timeout="60000", order=3, bugId="FM-1274")]
		public function playLive_BackToDefault_AfterSwitch():void
		{
			const testLenght:uint = DEFAULT_TEST_LENGTH;
			
			var expectedData:Object = new Object();
			expectedData["numAlternativeAudioStreams"] = 2;
			expectedData["selectedIndex_onReady"] = -1;
			expectedData["selectedIndex_onAudioSwitchEnd"] = 1;
			expectedData["selectedIndex_onComplete"] = -1;
			
			runAfterInterval(this, testLenght, playerHelper.info, onComplete, onTimeout);
			
			function setUpEvents(playerHelper:MediaPlayerHelper, add:Boolean):void
			{
				if (add)
				{
					playerHelper.addEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.addEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.addEventListener(MediaPlayerHelper.ERROR, 		onError);
					playerHelper.addEventListener(MediaPlayerHelper.AUDIO_SWITCH_BEGIN, onAudioSwitchBegin);
					playerHelper.addEventListener(MediaPlayerHelper.AUDIO_SWITCH_END, 	onAudioSwitchEnd);
				}
				else
				{
					playerHelper.removeEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.removeEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.removeEventListener(MediaPlayerHelper.ERROR, 		onError);
					playerHelper.removeEventListener(MediaPlayerHelper.AUDIO_SWITCH_BEGIN, onAudioSwitchBegin);
					playerHelper.removeEventListener(MediaPlayerHelper.AUDIO_SWITCH_END, 	onAudioSwitchEnd);
				}
			}
			
			setUpEvents(playerHelper, true);
			playerHelper.mediaResource = new URLResource(ALTERNATE_AUDIO_HDS_SBR_WITH_LIVE);
			
			var switchInitiated:Boolean = false;
			var switchedBackToDefault:Boolean = false;
			
			function onReady(event:Event):void
			{
				assertThat("We should have access to alternatve audio information", playerHelper.actualPlayer.hasAlternativeAudio);
				assertThat("The number of alternative audio streams is equal with the expected one.", playerHelper.actualPlayer.numAlternativeAudioStreams, equalTo(expectedData.numAlternativeAudioStreams));
				assertThat("No alternate audio stream change is in progress.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(false));
				assertThat("No alternate audio stream is selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onReady));
				
				playerHelper.actualPlayer.play();
			}
			
			function onPlaying(event:Event):void
			{
				if (!switchInitiated)
				{
					switchInitiated = true;
					playerHelper.actualPlayer.switchAlternativeAudioIndex(expectedData.selectedIndex_onAudioSwitchEnd);
				}
			}
			
			function onAudioSwitchBegin(event:Event):void
			{
				expectedData["currentTime_onAudioSwitchBegin"] = playerHelper.actualPlayer.currentTime;
				
				assertThat("An alternate audio stream switch is in progress.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(true));
			}
			
			function onAudioSwitchEnd(event:Event):void
			{
				expectedData["currentTime_onAudioSwitchEnd"] = playerHelper.actualPlayer.currentTime;
				
				assertThat("The alternative audio stream change is now completed.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(false));
				assertThat("The current time is still close to the previous time.", playerHelper.actualPlayer.currentTime, greaterThanOrEqualTo(expectedData.currentTime_onAudioSwitchBegin));
				
				if (!switchedBackToDefault)
				{
					assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onAudioSwitchEnd));
					
					switchedBackToDefault = true;
					playerHelper.actualPlayer.switchAlternativeAudioIndex(expectedData.selectedIndex_onComplete);
				}
				else
				{
					assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onComplete));
				}
			}
			
			function onComplete(passThroughData:Object):void
			{
				assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onComplete));
				
				setUpEvents(playerHelper, false);
			}
		}
			
		/**
		 * Tests the late-binding behavior when we switch back to the default audio track 
		 * after the switch to an alternate track was successful.
		 */ 
		[Test(async, timeout="60000", order=4)]
		public function playVOD_BackToDefault_AfterSwitch():void
		{
			const testLenght:uint = DEFAULT_TEST_LENGTH;
			
			var expectedData:Object = new Object();
			expectedData["numAlternativeAudioStreams"] = 2;
			expectedData["selectedIndex_onReady"] = -1;
			expectedData["selectedIndex_onAudioSwitchEnd"] = 1;
			expectedData["selectedIndex_onComplete"] = -1;
			
			runAfterInterval(this, testLenght, playerHelper.info, onComplete, onTimeout);
			
			function setUpEvents(playerHelper:MediaPlayerHelper, add:Boolean):void
			{
				if (add)
				{
					playerHelper.addEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.addEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.addEventListener(MediaPlayerHelper.ERROR, 		onError);
					playerHelper.addEventListener(MediaPlayerHelper.AUDIO_SWITCH_BEGIN, onAudioSwitchBegin);
					playerHelper.addEventListener(MediaPlayerHelper.AUDIO_SWITCH_END, 	onAudioSwitchEnd);
				}
				else
				{
					playerHelper.removeEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.removeEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.removeEventListener(MediaPlayerHelper.ERROR, 		onError);
					playerHelper.removeEventListener(MediaPlayerHelper.AUDIO_SWITCH_BEGIN, onAudioSwitchBegin);
					playerHelper.removeEventListener(MediaPlayerHelper.AUDIO_SWITCH_END, 	onAudioSwitchEnd);
				}
			}
			
			setUpEvents(playerHelper, true);
			playerHelper.mediaResource = new URLResource(ALTERNATE_AUDIO_HDS_SBR_WITH_VOD);
			
			var switchInitiated:Boolean = false;
			var switchedBackToDefault:Boolean = false;
			
			function onReady(event:Event):void
			{
				assertThat("We should have access to alternatve audio information", playerHelper.actualPlayer.hasAlternativeAudio);
				assertThat("The number of alternative audio streams is equal with the expected one.", playerHelper.actualPlayer.numAlternativeAudioStreams, equalTo(expectedData.numAlternativeAudioStreams));
				assertThat("No alternate audio stream change is in progress.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(false));
				assertThat("No alternate audio stream is selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onReady));
				
				playerHelper.actualPlayer.play();
			}
			
			function onPlaying(event:Event):void
			{
				if (!switchInitiated)
				{
					switchInitiated = true;
					playerHelper.actualPlayer.switchAlternativeAudioIndex(expectedData.selectedIndex_onAudioSwitchEnd);
				}
			}
			
			function onAudioSwitchBegin(event:Event):void
			{
				expectedData["currentTime_onAudioSwitchBegin"] = playerHelper.actualPlayer.currentTime;
				
				assertThat("An alternative audio stream switch is in progress.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(true));
			}
			
			function onAudioSwitchEnd(event:Event):void
			{
				expectedData["currentTime_onAudioSwitchEnd"] = playerHelper.actualPlayer.currentTime;
				
				assertThat("The alternative audio stream change is now completed.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(false));
				assertThat("The current time is still close to the previous time.", playerHelper.actualPlayer.currentTime, greaterThanOrEqualTo(expectedData.currentTime_onAudioSwitchBegin));
				
				if (!switchedBackToDefault)
				{
					assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onAudioSwitchEnd));
					
					switchedBackToDefault = true;
					playerHelper.actualPlayer.switchAlternativeAudioIndex(expectedData.selectedIndex_onComplete);
				}
				else
				{
					assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onComplete));
				}
			}
			
			function onComplete(passThroughData:Object):void
			{
				assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onComplete));
				
				setUpEvents(playerHelper, false)
			}
		}

		/**
		 * Tests the late-binding behavior when we switch back to the default audio track 
		 * after playing at least 5 seconds of main content with an alternate track selected.
		 */ 
		[Test(async, timeout="60000", order=5)]
		public function playVOD_BackToDefault_After5Sec():void
		{
			const testLenght:uint = DEFAULT_TEST_LENGTH;
			
			var expectedData:Object = new Object();
			expectedData["numAlternativeAudioStreams"] = 2;
			expectedData["selectedIndex_onReady"] = -1;
			expectedData["selectedIndex_onAudioSwitchEnd"] = 1;
			expectedData["selectedIndex_onComplete"] = -1;
			
			runAfterInterval(this, testLenght, playerHelper.info, onComplete, onTimeout);
			
			function setUpEvents(playerHelper:MediaPlayerHelper, add:Boolean):void
			{
				if (add)
				{
					playerHelper.addEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.addEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.addEventListener(MediaPlayerHelper.ERROR, 		onError);
					playerHelper.addEventListener(MediaPlayerHelper.AUDIO_SWITCH_BEGIN, onAudioSwitchBegin);
					playerHelper.addEventListener(MediaPlayerHelper.AUDIO_SWITCH_END, 	onAudioSwitchEnd);
				}
				else
				{
					playerHelper.removeEventListener(MediaPlayerHelper.READY, 		onReady);
					playerHelper.removeEventListener(MediaPlayerHelper.PLAYING, 	onPlaying);
					playerHelper.removeEventListener(MediaPlayerHelper.ERROR, 		onError);
					playerHelper.removeEventListener(MediaPlayerHelper.AUDIO_SWITCH_BEGIN, onAudioSwitchBegin);
					playerHelper.removeEventListener(MediaPlayerHelper.AUDIO_SWITCH_END, 	onAudioSwitchEnd);
				}
			}
			
			setUpEvents(playerHelper, true);
			playerHelper.mediaResource = new URLResource(ALTERNATE_AUDIO_HDS_SBR_WITH_VOD);
			
			const switchTimerInterval:Number = 6000;			
			var switchTimer:Timer = new Timer(switchTimerInterval, 1);
			switchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onSwitchTimerComplete);
			
			var switchInitiated:Boolean = false;
			var switchedBackToDefault:Boolean = false;
			
			function onReady(event:Event):void
			{
				assertThat("We should have access to alternatve audio information", playerHelper.actualPlayer.hasAlternativeAudio);
				assertThat("The number of alternative audio streams is equal with the expected one.", playerHelper.actualPlayer.numAlternativeAudioStreams, equalTo(expectedData.numAlternativeAudioStreams));
				assertThat("No alternate audio stream change is in progress.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(false));
				assertThat("No alternate audio stream is selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onReady));
				
				playerHelper.actualPlayer.play();
			}
			
			function onPlaying(event:Event):void
			{
				if (!switchInitiated)
				{
					switchInitiated = true;
					playerHelper.actualPlayer.switchAlternativeAudioIndex(expectedData.selectedIndex_onAudioSwitchEnd);
				}
			}
			
			function onAudioSwitchBegin(event:Event):void
			{
				expectedData["currentTime_onAudioSwitchBegin"] = playerHelper.actualPlayer.currentTime;
				
				assertThat("An alternative audio stream switch is in progress.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(true));
			}
			
			function onAudioSwitchEnd(event:Event):void
			{
				expectedData["currentTime_onAudioSwitchEnd"] = playerHelper.actualPlayer.currentTime;
				
				assertThat("The alternative audio stream change is now completed.", playerHelper.actualPlayer.alternativeAudioStreamSwitching, equalTo(false));
				assertThat("The current time is still close to the previous time.", playerHelper.actualPlayer.currentTime, greaterThanOrEqualTo(expectedData.currentTime_onAudioSwitchBegin));
				
				if (!switchedBackToDefault)
				{
					assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onAudioSwitchEnd));
					
					switchedBackToDefault = true;
					switchTimer.start();
				}
				else
				{
					assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onComplete));
				}
			}
			
			function onComplete(passThroughData:Object):void
			{
				assertThat("Specified alternate audio stream is currently selected.", playerHelper.actualPlayer.currentAlternativeAudioStreamIndex, equalTo(expectedData.selectedIndex_onComplete));
				
				setUpEvents(playerHelper, false);
			}
			
			function onSwitchTimerComplete(event:TimerEvent):void
			{
				playerHelper.actualPlayer.switchAlternativeAudioIndex(expectedData.selectedIndex_onComplete);
			}
		}

		/// Internals
		protected static const ALTERNATE_AUDIO_HDS_SBR_WITH_LIVE:String = "http://10.131.237.107/live/events/latebind/events/_definst_/liveevent.f4m";
		protected static const ALTERNATE_AUDIO_HDS_SBR_WITH_VOD:String = "http://10.131.237.104/vod/late_binding_audio/API_tests_assets/1_media_v_2_alternate_a/1_media_v_2_alternate_a.f4m";

	}
}
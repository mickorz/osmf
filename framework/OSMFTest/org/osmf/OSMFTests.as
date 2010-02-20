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
package org.osmf
{
	import flexunit.framework.TestSuite;
	
	import org.osmf.containers.*;
	import org.osmf.display.*;
	import org.osmf.elements.audioClasses.*;
	import org.osmf.elements.beaconClasses.*;
	import org.osmf.elements.compositeClasses.*;
	import org.osmf.elements.f4mClasses.*;
	import org.osmf.elements.htmlClasses.*;
	import org.osmf.elements.proxyClasses.*;
	import org.osmf.elements.*;
	import org.osmf.events.*;
	import org.osmf.layout.*;
	import org.osmf.logging.*;
	import org.osmf.media.*;
	import org.osmf.metadata.*;
	import org.osmf.net.*;
	import org.osmf.net.httpstreaming.*;
	import org.osmf.net.httpstreaming.f4f.*;
	import org.osmf.net.httpstreaming.flv.*;
	import org.osmf.net.rtmpstreaming.*;
	import org.osmf.plugin.*;
	import org.osmf.traits.*;
	import org.osmf.utils.*;

	public class OSMFTests extends TestSuite
	{
		public function OSMFTests(param:Object=null)
		{
			super(param);
			
			// change to true to run all tests against the network.
			NetFactory.neverUseMockObjects = false;

			// Logging
			//
			
			addTestSuite(TestLog);
			addTestSuite(TestTraceLogger);
			addTestSuite(TestTraceLoggerFactory);

			// Traits
			//
			
			addTestSuite(TestAudioTrait);
			addTestSuite(TestBufferTrait);
			addTestSuite(TestBufferTraitAsSubclass);
			addTestSuite(TestDRMTrait);
			addTestSuite(TestDynamicStreamTrait);
			addTestSuite(TestLoadTrait);
			addTestSuite(TestLoaderBaseAsSubclass);
			addTestSuite(TestLoadTraitAsSubclass);
			addTestSuite(TestPlayTrait);
			addTestSuite(TestPlayTraitAsSubclass);
			addTestSuite(TestSeekTrait);
			addTestSuite(TestSeekTraitAsSubclass);
			addTestSuite(TestTimeTrait);
			addTestSuite(TestTimeTraitAsSubclass);
			addTestSuite(TestDisplayObjectTrait);
			addTestSuite(TestDisplayObjectTraitAsSubclass);

			// Events
			//
			
			addTestSuite(TestMediaError);
			addTestSuite(TestMediaErrorAsSubclass);
			
			// Core Media
			//
			
			addTestSuite(TestURLResource);
			addTestSuite(TestMediaElement);
			addTestSuite(TestMediaElementAsSubclass);
			addTestSuite(TestLoadableElementBase);
			addTestSuite(TestMediaTraitResolver);
			addTestSuite(TestDefaultTraitResolver);
			addTestSuite(TestMediaFactoryItem);
			addTestSuite(TestMediaFactory);
			
			// Video
			//
			
			addTestSuite(TestVideoElement);
			addTestSuite(TestCuePoint);
			
			// Audio
			//
			
			addTestSuite(TestAudioElement);
			addTestSuite(TestAudioElementWithSoundLoader);
			addTestSuite(TestSoundLoader);
			
			addTestSuite(TestAudioAudioTrait);
			addTestSuite(TestAudioSeekTrait); 
			addTestSuite(TestSoundLoadTrait);

			// These tests fail intermittently on the build machine.
			//addTestSuite(TestAudioPlayTrait);
			//addTestSuite(TestAudioTimeTrait);
			
			// External
			//
			
			addTestSuite(TestHTMLElement);
			addTestSuite(TestHTMLPlayTrait);
			addTestSuite(TestHTMLLoadTrait);
			addTestSuite(TestHTMLTimeTrait);
			addTestSuite(TestHTMLAudioTrait);
			
			// Images & SWFs
			//
			
			addTestSuite(TestImageLoader);
			addTestSuite(TestImageElement);

			addTestSuite(TestSWFLoader);
			addTestSuite(TestSWFElement);
			
			// Composition
			//
			
			addTestSuite(TestTraitAggregator);
			addTestSuite(TestTraitLoader);

			addTestSuite(TestCompositeElement);
			addTestSuite(TestParallelElement);
			addTestSuite(TestSerialElement);

			addTestSuite(TestParallelElementWithAudioTrait);
			addTestSuite(TestParallelElementWithBufferTrait);
			addTestSuite(TestParallelElementWithDRMTrait); 
			addTestSuite(TestParallelElementWithDynamicStreamTrait);
			addTestSuite(TestParallelElementWithLoadTrait);
			addTestSuite(TestParallelElementWithPlayTrait);
			addTestSuite(TestParallelElementWithSeekTrait);
			addTestSuite(TestParallelElementWithTimeTrait);
			addTestSuite(TestParallelElementWithDisplayObjectTrait);
			
			addTestSuite(TestSerialElementWithAudioTrait);
			addTestSuite(TestSerialElementWithBufferTrait);
			addTestSuite(TestSerialElementWithDRMTrait);
			addTestSuite(TestSerialElementWithDynamicStreamTrait);
			addTestSuite(TestSerialElementWithLoadTrait);
			addTestSuite(TestSerialElementWithPlayTrait);
			addTestSuite(TestSerialElementWithSeekTrait);
			addTestSuite(TestSerialElementWithTimeTrait);
			addTestSuite(TestSerialElementWithDisplayObjectTrait);
			
			addTestSuite(TestCompositeAudioTrait);
			
			// Proxies
			//
			
			addTestSuite(TestProxyElement);
			addTestSuite(TestProxyElementAsDynamicProxy);
			addTestSuite(TestDurationElement);
			addTestSuite(TestListenerProxyElement);
			addTestSuite(TestListenerProxyElementAsSubclass);
			addTestSuite(TestLoadFromDocumentElement);
			addTestSuite(TestLoadFromDocumentLoadTrait);
			
			// Tracking
			//
			
			addTestSuite(TestBeacon);
			addTestSuite(TestBeaconElement);

			// MediaPlayer
			//
			
			addTestSuite(TestMediaPlayer);
			
			// Metadata
			//

			addTestSuite(TestMetadata);
			addTestSuite(TestObjectIdentifier);
			addTestSuite(TestMediaType);
			addTestSuite(TestKeyValueFacet);
			addTestSuite(TestFacetGroup);
			addTestSuite(TestMetadataUtils);
			addTestSuite(TestCompositeMetadata);
			addTestSuite(TestTemporalFacet);

			// NetStream
			//
			
			addTestSuite(TestNetLoader);
			addTestSuite(TestNetConnectionFactory);
 			addTestSuite(TestNetClient);
			addTestSuite(TestNetStreamUtils);
			addTestSuite(TestStreamingURLResource);

			addTestSuite(TestNetStreamAudioTrait);
			addTestSuite(TestNetStreamBufferTrait);
			addTestSuite(TestNetStreamLoadTrait);
			addTestSuite(TestNetStreamPlayTrait);
			addTestSuite(TestNetStreamSeekTrait);
			addTestSuite(TestNetStreamTimeTrait);
			addTestSuite(TestNetStreamDisplayObjectTrait);
			
			addTestSuite(TestManifestParser);
			addTestSuite(TestF4MLoader);		

			// Dynamic Streaming
			//
			
			addTestSuite(TestInsufficientBandwidthRule);
			addTestSuite(TestInsufficientBufferRule);
			addTestSuite(TestDroppedFramesRule);
			addTestSuite(TestSufficientBandwidthRule);
			addTestSuite(TestDynamicStreamingItem);
			addTestSuite(TestDynamicStreamingResource);
			
			addTestSuite(TestRTMPDynamicStreamingNetLoader);
			addTestSuite(TestNetStreamSwitchManager);
			addTestSuite(TestNetStreamDynamicStreamTrait);
			
			// HTTP Streaming
			//
			
			addTestSuite(TestDownloadRatioRule);
			addTestSuite(TestBoxParser);
			addTestSuite(TestAdobeBootstrapBox);
			addTestSuite(TestAdobeFragmentRunTable);
			addTestSuite(TestAdobeSegmentRunTable);
			addTestSuite(TestFLVHeader);
			
			// Plugins
			//
			
			addTestSuite(TestPluginElement);
			addTestSuite(TestStaticPluginLoader);
			addTestSuite(TestDynamicPluginLoader);
			addTestSuite(TestPluginManager);
			addTestSuite(TestPluginLoadingState);
						
			// Layout
			//			
				
			addTestSuite(TestAbsoluteLayoutFacet);
			addTestSuite(TestAnchorLayoutFacet);
			addTestSuite(TestLayoutRendererBase);
			addTestSuite(TestLayoutRenderer);
			addTestSuite(TestLayoutAttributesFacet);
			addTestSuite(TestMediaElementLayoutTarget);
			addTestSuite(TestPaddingLayoutFacet);
			addTestSuite(TestVerticalAlign);
			addTestSuite(TestHorizontalAlign);
			addTestSuite(TestRelativeLayoutFacet);
			addTestSuite(TestLayoutRendererProperties);
			
			// Containers
			//
			
			addTestSuite(TestMediaContainer);
			addTestSuite(TestHTMLMediaContainer);
			addTestSuite(TestMediaPlayerSprite);

			// Utils
			//
			
			addTestSuite(TestBinarySearch);
			addTestSuite(TestOSMFStrings);
			addTestSuite(TestVersion);		
			addTestSuite(TestURL);
			addTestSuite(TestFMSURL);
			addTestSuite(TestHTTPLoader);
			addTestSuite(TestTimeUtil);
			addTestSuite(TestTraitEventDispatcher);

			// Additional MediaPlayer Tests
			//
			
			addTestSuite(TestMediaPlayerWithAudioElement);
			addTestSuite(TestMediaPlayerWithVideoElement);
			addTestSuite(TestMediaPlayerWithVideoElementSubclip);
			addTestSuite(TestMediaPlayerWithDynamicStreamingVideoElement);
			addTestSuite(TestMediaPlayerWithDynamicStreamingVideoElementSubclip);
			addTestSuite(TestMediaPlayerWithProxyElement);
			addTestSuite(TestMediaPlayerWithDurationElement);
			addTestSuite(TestMediaPlayerWithBeaconElement);

			// This test fails intermittently on the build machine.
			//addTestSuite(TestMediaPlayerWithAudioElementWithSoundLoader);
		}
	}
}

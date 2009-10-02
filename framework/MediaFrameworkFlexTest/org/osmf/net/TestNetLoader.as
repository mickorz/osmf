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
package org.osmf.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoadableStateChangeEvent;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.loaders.TestILoader;
	import org.osmf.media.IMediaResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.KeyValueFacet;
	import org.osmf.metadata.MediaType;
	import org.osmf.metadata.ObjectIdentifier;
	import org.osmf.netmocker.DefaultNetConnectionFactory;
	import org.osmf.netmocker.MockNetLoader;
	import org.osmf.netmocker.MockNetNegotiator;
	import org.osmf.netmocker.NetConnectionExpectation;
	import org.osmf.traits.ILoadable;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadableTrait;
	import org.osmf.utils.FMSURL;
	import org.osmf.utils.MediaFrameworkStrings;
	import org.osmf.utils.NetFactory;
	import org.osmf.utils.NullResource;
	import org.osmf.utils.TestConstants;
	import org.osmf.utils.URL;

	public class TestNetLoader extends TestILoader
	{
		override public function setUp():void
		{
			netFactory = new NetFactory();
			eventDispatcher = new EventDispatcher();

			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			netFactory = null;
			eventDispatcher = null;
		}

		override public function testCanHandleResource():void
		{
			super.testCanHandleResource();
			
			// Verify some valid remote resources.
	    	assertTrue(loader.canHandleResource(new URLResource(new URL("http://example.com/test"))));	    	
		   	assertTrue(loader.canHandleResource(new URLResource(new URL("https://example.com/test"))));
		   	assertTrue(loader.canHandleResource(new URLResource(new URL("http://example.com:8080"))));
		   	assertTrue(loader.canHandleResource(new URLResource(new URL("file://example.com/test"))));
	    	assertTrue(loader.canHandleResource(new URLResource(new FMSURL("rtmp://example.com/test"))));	    	
	    	assertTrue(loader.canHandleResource(new URLResource(new FMSURL("rtmps://example.com/test"))));	    	
	    	assertTrue(loader.canHandleResource(new URLResource(new FMSURL("rtmpe://example.com/test"))));	    	    	
	    	assertTrue(loader.canHandleResource(new URLResource(new FMSURL("rtmpte://example.com/test"))));
	    	assertTrue(loader.canHandleResource(new URLResource(new FMSURL("rtmp://example.com:8080/appname/test"))));
	    	assertTrue(loader.canHandleResource(new URLResource(new FMSURL("rtmp://example.com/appname/filename.flv"))));
	    	assertTrue(loader.canHandleResource(new URLResource(new FMSURL("rtmpte://example.com:8080/appname/mp4:filename.mp4"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("example.com/test.flv"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("http://example.com/test.flv?param=value"))));
	    	
			// And some invalid ones.
	    	assertFalse(loader.canHandleResource(new URLResource(new URL("javascript://test.com/test.flv"))));
	    	assertFalse(loader.canHandleResource(new URLResource(new URL("rtmpet://example.com/test"))));	    	
			assertFalse(loader.canHandleResource(new URLResource(new URL("httpt://example.com/video.foo"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("example.com/test.mp3"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("foo"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL(""))));
			assertFalse(loader.canHandleResource(new URLResource(null)));
			assertFalse(loader.canHandleResource(new NullResource()));
			assertFalse(loader.canHandleResource(null));
			
			// Verify some valid local resources.
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.flv"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.f4v"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.mov"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.mp4"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.mp4v"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.m4v"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.3gp"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.3gpp2"))));
			assertTrue(loader.canHandleResource(new URLResource(new URL("file:///video.3g2"))));
			
			// And some invalid ones.
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.avi"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.mpeg"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.mpg"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.wmv"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("audio.mp3"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.flv1"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.f4v1"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.mov1"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.mp41"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.mp4v1"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.m4v1"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.3gp1"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.3gpp21"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("video.3g21"))));
			assertFalse(loader.canHandleResource(new URLResource(new URL("audio.mp31"))));
					
			// Verify some valid resources based on metadata information
			var metadata:KeyValueFacet = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.VIDEO);
			var resource:URLResource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));
			
			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/x-flv");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));
			
			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/x-f4v");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/mp4");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/mp4v-es");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/x-m4v");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/3gpp");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/3gpp2");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/quicktime");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.VIDEO);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/x-flv");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertTrue(loader.canHandleResource(resource));

			// Add some invalid cases based on metadata information
			//
			
			metadata = new KeyValueFacet();			
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.AUDIO);			
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "audio/mpeg");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));
			
			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.AUDIO);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "audio/mpeg");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.SWF);			
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "Invalid MIME Type");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.IMAGE);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "Invalid MIME Type");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.VIDEO);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "Invalid MIME Type");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.AUDIO);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "Invalid MIME Type");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.IMAGE);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/x-flv");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.IMAGE);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "audio/mpeg");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.VIDEO);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "audio/mpeg");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));

			metadata = new KeyValueFacet();
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MEDIA_TYPE), MediaType.AUDIO);
			metadata.addValue(new ObjectIdentifier(MediaFrameworkStrings.METADATA_KEY_MIME_TYPE), "video/x-flv");
			resource = new URLResource(new URL("http://example.com/test"));
			resource.metadata.addFacet(metadata);
			assertFalse(loader.canHandleResource(resource));
		}

		public function testMultipleConcurrentLoads():void
		{
			doTestMultipleConcurrentLoads();
		}
		
		public function testConnectionSharing():void
		{
			doTestConnectionSharing();
		}
		
		public function testAllowConnectionSharing():void
		{
			doTestAllowConnectionSharing();
		}
		
		public function testUnloadWithSharedConnections():void
		{
			doTestUnloadWithSharedConnections();
		}
		
		public function testNetConnectionFactoryArgument():void
		{
			doTestNetConnectionFactoryArgument();
		}
		
		private function doTestMultipleConcurrentLoads():void
		{
			eventDispatcher.addEventListener("testComplete",addAsync(mustReceiveEvent,TEST_TIME));
			
			var netLoader:MockNetLoader = new MockNetLoader();
			netLoader.netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
			var loadable1:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable1.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable1.load();
			var loadable2:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable2.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable2.load();
			var loadable3:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable3.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable3.load();
			var loadable4:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable4.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable4.load();
			var responses:int = 0;
			function onMultiLoad(event:LoadableStateChangeEvent):void
			{
					assertTrue(event.loadable != null);
					assertTrue(event.type == LoaderEvent.LOADABLE_STATE_CHANGE);
					
				if (event.newState == LoadState.LOADED)
				{
					responses++;
					if (responses == 4)
					{
						eventDispatcher.dispatchEvent(new Event("testComplete"));
					}
				}
			}
			
		}
		
		private function doTestConnectionSharing():void
		{
			var netLoader:MockNetLoader = new MockNetLoader();
			netLoader.netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
			var loadable1:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable1.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable1.load();
			var loadable2:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable2.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable2.load();

			var responses:int = 0;
			function onMultiLoad(event:LoadableStateChangeEvent):void
			{
					assertTrue(event.loadable != null);
					assertTrue(event.type == LoaderEvent.LOADABLE_STATE_CHANGE);
					
				if (event.newState == LoadState.LOADED)
				{
					var context:NetLoadedContext = event.loadable.loadedContext as NetLoadedContext;
					assertTrue(context.shareable);
				}
			}
			
		}
		
		private function doTestAllowConnectionSharing():void
		{
			var netLoader:MockNetLoader = new MockNetLoader(false);
			netLoader.netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
			var loadable1:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable1.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable1.load();
			var loadable2:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable2.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable2.load();

			var responses:int = 0;
			function onMultiLoad(event:LoadableStateChangeEvent):void
			{
					assertTrue(event.loadable != null);
					assertTrue(event.type == LoaderEvent.LOADABLE_STATE_CHANGE);
					
				if (event.newState == LoadState.LOADED)
				{
					var context:NetLoadedContext = event.loadable.loadedContext as NetLoadedContext;
					assertFalse(context.shareable);
				}
			}
			
		}
		
		private function doTestUnloadWithSharedConnections():void
		{
			var netLoader:MockNetLoader = new MockNetLoader();
			netLoader.netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
			var loadable1:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable1.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable1.load();
			var loadable2:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable2.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable2.load();

			var responses:int = 0;
			function onMultiLoad(event:LoadableStateChangeEvent):void
			{
					assertTrue(event.loadable != null);
					assertTrue(event.type == LoaderEvent.LOADABLE_STATE_CHANGE);
					
				if (event.newState == LoadState.LOADED)
				{
					var context:NetLoadedContext = event.loadable.loadedContext as NetLoadedContext;
					assertTrue(context.shareable);
					responses++;
					if (responses == 2)
					{
						loadable1.unload();
						
					}
				}
				if (event.newState == LoadState.CONSTRUCTED)
				{
					if (responses == 2)
					{
						assertStrictlyEquals(event.loadable,loadable1);
						assertTrue((loadable2.loadedContext as NetLoadedContext).connection.connected);
					}
				}
			}
			
		}
		
		private function doTestNetConnectionFactoryArgument():void
		{
			var negotiator:MockNetNegotiator = new MockNetNegotiator();
			var factory:DefaultNetConnectionFactory = new DefaultNetConnectionFactory(negotiator);
			var netLoader:MockNetLoader = new MockNetLoader(true,factory,negotiator);
			netLoader.netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
			var loadable1:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable1.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable1.load();
			var loadable2:LoadableTrait = new LoadableTrait(netLoader, successfulResource);
			loadable2.addEventListener(LoaderEvent.LOADABLE_STATE_CHANGE, onMultiLoad);
			loadable2.load();

			function onMultiLoad(event:LoadableStateChangeEvent):void
			{
					assertTrue(event.loadable != null);
					assertTrue(event.type == LoaderEvent.LOADABLE_STATE_CHANGE);
					
				if (event.newState == LoadState.LOADED)
				{
					var context:NetLoadedContext = event.loadable.loadedContext as NetLoadedContext;
					assertTrue(context.shareable);
				}
			}
			
		}
		
		//---------------------------------------------------------------------
				
		override protected function createInterfaceObject(... args):Object
		{
			return netFactory.createNetLoader();
		}
		
		override protected function createILoadable(resource:IMediaResource=null):ILoadable
		{
			var mockLoader:MockNetLoader = loader as MockNetLoader;
			if (mockLoader)
			{
				if (resource == successfulResource)
				{
					mockLoader.netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
				}
				else if (resource == failedResource)
				{
					mockLoader.netConnectionExpectation = NetConnectionExpectation.REJECTED_CONNECTION;
				}
				else if (resource == unhandledResource)
				{
					mockLoader.netConnectionExpectation = NetConnectionExpectation.REJECTED_CONNECTION;
				}
			}
			return new LoadableTrait(loader, resource);
		}
		
		override protected function get successfulResource():IMediaResource
		{
			return SUCCESSFUL_RESOURCE;
		}

		override protected function get failedResource():IMediaResource
		{
			return UNSUCCESSFUL_RESOURCE;
		}

		override protected function get unhandledResource():IMediaResource
		{
			return UNHANDLED_RESOURCE;
		}
		
		override protected function verifyMediaErrorOnLoadFailure(error:MediaError):void
		{
			assertTrue(error.errorCode == MediaErrorCodes.INVALID_URL_PROTOCOL ||
					   error.errorCode == MediaErrorCodes.NETCONNECTION_REJECTED ||
					   error.errorCode == MediaErrorCodes.NETCONNECTION_INVALID_APP ||
					   error.errorCode == MediaErrorCodes.NETCONNECTION_FAILED ||
					   error.errorCode == MediaErrorCodes.NETCONNECTION_TIMEOUT ||
					   error.errorCode == MediaErrorCodes.NETCONNECTION_SECURITY_ERROR ||
					   error.errorCode == MediaErrorCodes.NETCONNECTION_ASYNC_ERROR ||
					   error.errorCode == MediaErrorCodes.NETCONNECTION_IO_ERROR ||
					   error.errorCode == MediaErrorCodes.NETCONNECTION_ARGUMENT_ERROR);
		}
		
		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is received.
		}
		
		private var netFactory:NetFactory;
		private var eventDispatcher:EventDispatcher;
		
		private static const SUCCESSFUL_RESOURCE:URLResource = new URLResource(new FMSURL(TestConstants.REMOTE_STREAMING_VIDEO));
		private static const UNSUCCESSFUL_RESOURCE:URLResource = new URLResource(new FMSURL(TestConstants.INVALID_STREAMING_VIDEO));
		private static const UNHANDLED_RESOURCE:NullResource = new NullResource();
		private static const TEST_TIME:Number = 4000;
		private static const PORT_443:String = "443";
		private static const RTMPTE:String = "rtmpte";
		private static const DEFAULT_PORT_PROTOCOL_RESULT:String = TestConstants.DEFAULT_PORT_PROTOCOL_RESULT;
		private static const RTMPTE_443_RESULT:String = TestConstants.RESULT_FOR_RTMPTE_443;
		private static const RESOURCE_WITH_PORT_PROTOCOL:URLResource = new URLResource(new FMSURL(TestConstants.REMOTE_STREAMING_VIDEO_WITH_PORT_PROTOCOL));
		
	}
}
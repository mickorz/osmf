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
package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.osmf.composition.ParallelElement;
	import org.osmf.composition.SerialElement;
	import org.osmf.display.ScaleMode;
	import org.osmf.containers.RegionGateway;
	import org.osmf.image.ImageElement;
	import org.osmf.image.ImageLoader;
	import org.osmf.layout.LayoutUtils;
	import org.osmf.layout.RegistrationPoint;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.MetadataUtils;
	import org.osmf.net.NetLoader;
	import org.osmf.proxies.TemporalProxyElement;
	import org.osmf.utils.URL;
	import org.osmf.video.VideoElement;

	[SWF(backgroundColor='#333333', frameRate='30')]
	public class RegionsSample extends Sprite
	{
		public function RegionsSample()
		{
			// Setup the Flash stage:
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            runSample();
  		} 
        
        private function runSample():void
        {   
			// Construct a small tree of media elements:
			
			var rootElement:ParallelElement = new ParallelElement();
			
				var mainContent:VideoElement = constructVideo(REMOTE_PROGRESSIVE);
				rootElement.addChild(mainContent);
				
				var banners:SerialElement = new SerialElement();
					banners.addChild(constructBanner(BANNER_1));
					banners.addChild(constructBanner(BANNER_2));
					banners.addChild(constructBanner(BANNER_3));
				rootElement.addChild(banners);
					
				var skyScraper:MediaElement = constructImage(SKY_SCRAPER_1);
				rootElement.addChild(skyScraper);
				
			// DEBUG: add id's to the elements at hand:
			MetadataUtils.setElementId(rootElement.metadata, "rootElement");
			MetadataUtils.setElementId(banners.metadata, "banners");
			MetadataUtils.setElementId(skyScraper.metadata, "skyScraper");
			MetadataUtils.setElementId(banners.getChildAt(0).metadata, "banner1");
			MetadataUtils.setElementId(banners.getChildAt(1).metadata, "banner2");
			MetadataUtils.setElementId(banners.getChildAt(2).metadata, "banner3");
			
			// Next, decorate the content tree with attributes:
			
			LayoutUtils.setRelativeLayout(banners.metadata, 100, 100);
			LayoutUtils.setLayoutAttributes(banners.metadata, ScaleMode.NONE, RegistrationPoint.BOTTOM_MIDDLE);
			
			LayoutUtils.setRelativeLayout(mainContent.metadata, 100, 100);
			LayoutUtils.setLayoutAttributes(mainContent.metadata, ScaleMode.LETTERBOX, RegistrationPoint.TOP_MIDDLE);
			
			// Consruct 3 regions:

			var bannerRegion:RegionGateway = new RegionGateway();
			LayoutUtils.setAbsoluteLayout(bannerRegion.metadata, 600, 70);
			bannerRegion.backgroundColor = 0xFF0000;
			bannerRegion.backgroundAlpha = .2;
			addChild(bannerRegion);
			
			var mainRegion:RegionGateway = new RegionGateway();
			LayoutUtils.setAbsoluteLayout(mainRegion.metadata, 600, 400);
			mainRegion.backgroundColor = 0xFFFFFF;
			mainRegion.backgroundAlpha = .2;
			mainRegion.y = 80;
			addChild(mainRegion);
			
			var skyScraperRegion:RegionGateway = new RegionGateway();
			LayoutUtils.setAbsoluteLayout(skyScraperRegion.metadata, 120, 600);
			skyScraperRegion.backgroundColor = 0xFF00;
			skyScraperRegion.backgroundAlpha = .2;
			skyScraperRegion.x = 610;
			skyScraperRegion.y = 10;
			addChild(skyScraperRegion);
			
			// DEBUG: add id's to the elements at hand:
			MetadataUtils.setElementId(mainRegion.metadata, "mainRegion");
			MetadataUtils.setElementId(bannerRegion.metadata, "bannerRegion");
			MetadataUtils.setElementId(skyScraperRegion.metadata, "skyScraperRegion");
			
			// Bind media elements to their target regions:
			
			banners.container = bannerRegion;
			mainContent.container = mainRegion;
			skyScraper.container = skyScraperRegion; 
			
			// To operate playback of the content tree, construct a
			// media player. Assignment of the root element to its source will
			// automatically start its loading and playback:
			
			var player:MediaPlayer = new MediaPlayer();
			player.element = rootElement;
			
			// Next, to make things more interesting by adding some interactivity:
			// Let's create another region, at the bottom of the main content. Now,
			// if we click the top banner, let's have it moved to this region, and
			// vice-versa:
			
			var bottomBannerRegion:RegionGateway = new RegionGateway();
			LayoutUtils.setAbsoluteLayout(bottomBannerRegion.metadata, 600, 70);
			bottomBannerRegion.backgroundColor = 0xFF;
			bottomBannerRegion.backgroundAlpha = .2;
			bottomBannerRegion.y = 490;
			addChild(bottomBannerRegion);
			
			bannerRegion.addEventListener
				( MouseEvent.CLICK
				, function (event:MouseEvent):void
					{
						banners.container = bottomBannerRegion;		
					}
				);
				
			bottomBannerRegion.addEventListener
				( MouseEvent.CLICK
				, function (event:MouseEvent):void
					{
						banners.container = bannerRegion;		
					}
				);
				
			// Let's link to the IAB site on the sky-scraper being clicked:
			
			skyScraperRegion.addEventListener
				( MouseEvent.CLICK
				, function (event:MouseEvent):void	
					{
						navigateToURL(new URLRequest(IAB_URL));
					}
				);
		}
		
		// Utilities
		//
		
		private function constructBanner(url:String):MediaElement
		{
			return new TemporalProxyElement
					( BANNER_INTERVAL
					, constructImage(url)
					);
		}
		
		private function constructImage(url:String):MediaElement
		{
			return new ImageElement
					( new ImageLoader()
					, new URLResource(new URL(url))
					) 
				
		}
		
		private function constructVideo(url:String):VideoElement
		{
			return new VideoElement
					( new NetLoader
					, new URLResource(new URL(url))
					);
		}
		
		private static const BANNER_INTERVAL:int = 5;
		
		private static const REMOTE_PROGRESSIVE:String
			= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
			
		// IAB standard banners from:
		private static const IAB_URL:String
			= "http://www.iab.net/iab_products_and_industry_services/1421/1443/1452";
		
		private static const BANNER_1:String
			= "http://www.iab.net/media/image/468x60.gif";
			
		private static const BANNER_2:String
			= "http://www.iab.net/media/image/234x60.gif";
			
		private static const BANNER_3:String
			= "http://www.iab.net/media/image/120x60.gif";
			
		private static const SKY_SCRAPER_1:String
			= "http://www.iab.net/media/image/120x600.gif"
		
	}
}
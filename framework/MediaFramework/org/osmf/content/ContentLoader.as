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
package org.osmf.content
{
	import flash.display.ActionScriptVersion;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	import org.osmf.events.BytesTotalChangeEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.loaders.LoaderBase;
	import org.osmf.media.IURLResource;
	import org.osmf.traits.ILoadable;
	import org.osmf.traits.LoadState;
	import org.osmf.utils.*;

	/**
	 * Dispatched when total size in bytes of data being downloaded into the application has changed.
	 * 
	 * @eventType org.osmf.events.BytesTotalChangeEvent
	 */	
	[Event(name="bytesTotalChange",type="org.osmf.events.BytesTotalChangeEvent")]

	/**
	 * The ContentLoader class creates a flash.display.Loader object, 
	 * which it uses to load and unload content.
	 *
	 * @see ContentElement
	 * @see org.osmf.traits.ILoadable
	 * @see flash.display.Loader
	 */ 
	public class ContentLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param useCurrentSecurityDomain Indicates whether to load the SWF
		 * into the current security domain, or its natural security domain.
		 * If the loaded SWF does not live in the same security domain as the
		 * loading SWF, Flash Player will not merge the types defined in the two
		 * domains.  Even if it happens that there are two types with identical
		 * names, Flash Player will still consider them different by tagging them
		 * with different versions.  Therefore, it is mandatory to have the
		 * loaded SWF and loading SWF live in the same security domain if the
		 * types need to be merged.
		 */ 
		public function ContentLoader(useCurrentSecurityDomain:Boolean=false)
		{
			super();
			
			this.useCurrentSecurityDomain = useCurrentSecurityDomain;
		}
		
		public function get bytesLoaded():Number
		{
			return _loader ? _loader.contentLoaderInfo.bytesLoaded : NaN;
		}
		
		public function get bytesTotal():Number
		{
			return _bytesTotal;
		}
		
		// Overrides
		//
		
		/**
		 * Loads content using a flash.display.Loader object. 
		 * <p>Updates the ILoadable's <code>loadedState</code> property to LOADING
		 * while loading and to LOADED upon completing a successful load.</p> 
		 * 
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#load()
		 * @param ILoadable ILoadable to be loaded.
		 */ 
		override public function load(loadable:ILoadable):void
		{
			super.load(loadable);
			
			updateLoadable(loadable, LoadState.LOADING);
			
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			if (useCurrentSecurityDomain)
			{
				context.securityDomain = SecurityDomain.currentDomain;
			}
			
			var urlReq:URLRequest = new URLRequest((loadable.resource as IURLResource).url.toString());
			
			_loader = new Loader();
			toggleLoaderListeners(_loader, true);
			try
			{
				_loader.load(urlReq, context);
			}
			catch (ioError:IOError)
			{
				onIOError(null, ioError.message);
			}
			catch (securityError:SecurityError)
			{
				onSecurityError(null, securityError.message);
			}

			function toggleLoaderListeners(_loader:Loader, on:Boolean):void
			{
				if (on)
				{
					_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
					_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
					_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				}
				else
				{
					_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
					_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
					_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
					_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				}
			}

			function onLoadProgress(event:Event):void
			{
				_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				setBytesTotal(_loader.contentLoaderInfo.bytesTotal);
			}

			function onLoadComplete(event:Event):void
			{
				toggleLoaderListeners(_loader, false);
				
				if (LoaderInfo(event.target).contentType == SWF_MIME_TYPE &&
					LoaderInfo(event.target).actionScriptVersion == ActionScriptVersion.ACTIONSCRIPT2)
				{
					// The SWF's version is unsupported.  Force an unload
					// and dispatch an error event.
					
					_loader.unloadAndStop();
					_loader = null;
					setBytesTotal(NaN);
					
					updateLoadable(loadable, LoadState.LOAD_FAILED);
					loadable.dispatchEvent
						( new MediaErrorEvent
							( new MediaError(MediaErrorCodes.INVALID_SWF_AS_VERSION)
							)
						);
				}
				else
				{
					updateLoadable(loadable, LoadState.LOADED, new ContentLoadedContext(_loader));
				}
			}

			function onIOError(ioEvent:IOErrorEvent, ioEventDetail:String=null):void
			{	
				toggleLoaderListeners(_loader, false);
				_loader = null;
				setBytesTotal(NaN);
				
				updateLoadable(loadable, LoadState.LOAD_FAILED);
				loadable.dispatchEvent
					( new MediaErrorEvent
						( new MediaError
							( MediaErrorCodes.CONTENT_IO_LOAD_ERROR
							, ioEvent ? ioEvent.text : ioEventDetail
							)
						)
					);
			}

			function onSecurityError(securityEvent:SecurityErrorEvent, securityEventDetail:String=null):void
			{	
				toggleLoaderListeners(_loader, false);
				_loader = null;
				setBytesTotal(NaN);
				
				updateLoadable(loadable, LoadState.LOAD_FAILED);
				loadable.dispatchEvent
					( new MediaErrorEvent
						( new MediaError
							( MediaErrorCodes.CONTENT_SECURITY_LOAD_ERROR
							, securityEvent ? securityEvent.text : securityEventDetail
							)
						)
					);
			}
		}

		
		/**
		 * Unloads content using a flash.display.Loader object.  
		 * 
		 * <p>Updates the ILoadable's <code>loadedState</code> property to UNLOADING
		 * while unloading and to CONSTRUCTED upon completing a successful unload.</p>
		 *
		 * @param ILoadable ILoadable to be unloaded.
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#unload()
		 */ 
		override public function unload(loadable:ILoadable):void
		{
			super.unload(loadable);

			var context:ContentLoadedContext = loadable.loadedContext as ContentLoadedContext;
			updateLoadable(loadable, LoadState.UNLOADING, context);			
			context.loader.unloadAndStop();
			updateLoadable(loadable, LoadState.CONSTRUCTED);
		}
		
		// Internals
		//
		
		private function setBytesTotal(value:Number):void
		{
			if (value != _bytesTotal)
			{ 
				var event:BytesTotalChangeEvent = new BytesTotalChangeEvent(_bytesTotal, value);
				_bytesTotal = value;
				dispatchEvent(event);
			}
		}
		
		private var _loader:Loader;
		private var useCurrentSecurityDomain:Boolean;
		
		private var _bytesTotal:Number;
		
		private static const SWF_MIME_TYPE:String = "application/x-shockwave-flash";
	}
}
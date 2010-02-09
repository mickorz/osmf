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
package org.osmf.elements
{
	import __AS3__.vec.Vector;
	
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * A ProxyElement acts as a wrapper for another MediaElement.
	 * Its purpose is to control access to the wrapped element.
	 * <p>ProxyElement is not instantiated directly but rather used
	 * as the base class for creating wrappers for specific purposes. 
	 * ProxyElement can be subclassed for any trait type or set of trait types.
	 * The subclass controls access to the wrapped element either by overriding
	 * one or more of the wrapped element's traits or by blocking them.</p>
	 * <p>To override any of the wrapped element's traits, 
	 * the subclass creates its own trait instances,
	 * which it substitutes for the wrapped element's traits that it wishes to override.
	 * It uses the ProxyElement's <code>setupOverriddenTraits()</code> method to arrange for
	 * the wrapped element's traits to be overridden.</p>
	 * <p>To block traits, the subclass prevents the traits of
	 * the wrapped element from being exposed by calling the ProxyElement's
	 * <code>blocksTrait(type:MediaTraitType)</code> method for every trait
	 * type that it wants to block.
	 * This causes the wrapped element's <code>hasTrait()</code>
	 * method to return <code>false</code> and its
	 * <code>getTrait()</code> method to return <code>null</code>
	 * for the blocked trait types.</p>
	 * <p>A ProxyElement normally dispatches the wrapped element's
	 * MediaElementEvents, unless its <code>blocksTrait()</code> method returns 
	 * <code>false</code> for the trait that is the target of the
	 * MediaElementEvent.</p>
	 * <p>ProxyElement subclasses are useful for modifying the behavior of a
	 * MediaElement in a non-invasive way.  
	 * An example would be adding
	 * temporal capabilities to a set of ImageElements to present them in a slide show
	 * in which the images are displayed for a specified duration.
	 * The ProxyElement subclass would wrap the non-temporal ImageElements
	 * and override the wrapped element's TimeTrait to return a custom
	 * instance of that trait.
	 * A similar approach can be applied to other traits, either to provide an 
	 * alternate implementation of some of the wrapped element's underlying traits,
	 * to provide an implementation when a needed underlying trait does not exist,
	 * or to prevent an underlying trait from being exposed at all.</p>
	 * @see DurationElement
	 * @see org.osmf.events.MediaElementEvent
	 * @see org.osmf.traits
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class ProxyElement extends MediaElement
	{
		/**
		 * Constructor.
		 * 
		 * @param proxiedElement MediaElement to proxy.  Changes to the proxied
		 * element are reflected in the proxy element's properties and events,
		 * with the exception of those changes for which an override takes
		 * precedence.  If the param is null, then it must be set (via the
		 * proxiedElement setter) immediately after this constructor call, and
		 * before any other methods on this ProxyElement are called, or an
		 * IllegalOperationError will be thrown.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function ProxyElement(proxiedElement:MediaElement=null)
		{
			super();
			
			this.proxiedElement = proxiedElement;
		}
		
		/**
		 * The MediaElement for which this ProxyElement serves as a proxy,
		 * or wrapper.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set proxiedElement(value:MediaElement):void
		{
			var traitType:String;
			
			if (value != _proxiedElement)
			{
				if (_proxiedElement != null)
				{
					// Clear the listeners for the old wrapped element.
					toggleMediaElementListeners(_proxiedElement, false);

					// The wrapped element is changing, signal trait removal
					// for all traits.
					for each (traitType in _proxiedElement.traitTypes)
					{
						super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE, false, false, traitType));
					}
					
					// All traits that were overridden on the proxy must be
					// removed.
					removeOverriddenTraits();
				}
				
				_proxiedElement = value;
				
				if (_proxiedElement != null)
				{
					// Add listeners for the new wrapped element, so that
					// events from the wrapped element are also dispatched by
					// the proxy.
					toggleMediaElementListeners(_proxiedElement, true);
					
					// Set up the traits for the proxy, now that we're prepared
					// to respond to change events.  (Note that this class's
					// setupTraits prevents a call to the base class.)
					setupOverriddenTraits();
					
					// The wrapped element has changed, signal trait addition
					// for all traits.
					for each (traitType in _proxiedElement.traitTypes)
					{
						super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD, false, false, traitType));
					}
				}
			}
		}
		
		public function get proxiedElement():MediaElement
		{
			return _proxiedElement;
		}
		
		/**
		 * @private
		 */
		override public function get traitTypes():Vector.<String>
		{
			var results:Vector.<String> = new Vector.<String>();
			
			// Only return the traits reflected by the proxy. 
			for each (var traitType:String in MediaTraitType.ALL_TYPES)
			{
				if (hasTrait(traitType))
				{
					results.push(traitType);
				}
			}
			
			return results;
		}

		/**
		 * @private
		 */
		override public function hasTrait(type:String):Boolean
		{
			if (type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return getTrait(type) != null;
		}
		
		/**
		 * @private
		 */
		override public function getTrait(type:String):MediaTraitBase
		{
			if (type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}

			var trait:MediaTraitBase = null;
			
			// Don't return the trait if it's blocked.
			if (blocksTrait(type) == false)
			{				
				// Give precedence to a trait on the proxy.
				trait = super.getTrait(type) ||	(proxiedElement != null ? proxiedElement.getTrait(type) : null);
			}
			
			return trait;
		}
		
		/**
		 * @private
		 */
		override public function get resource():MediaResourceBase
		{		
			return proxiedElement ? proxiedElement.resource : null;
		}
		
		/**
		 * @private
		 */		
		override public function set resource(value:MediaResourceBase):void
		{	
			if (proxiedElement != null)
			{
				proxiedElement.resource = value;
			}
		}
		
		override protected function addTrait(type:String, instance:MediaTraitBase):void
		{
			// If we're adding a trait that already exists on the proxied
			// element (and isn't blocked), then we need to signal removal
			// of the base trait first.
			if (	blocksTrait(type) == false
				&&	proxiedElement != null
				&& 	proxiedElement.hasTrait(type) == true
			   )
			{
				super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE, false, false, type));
			}
			
			super.addTrait(type, instance);
		}

		override protected function removeTrait(type:String):MediaTraitBase
		{
			var result:MediaTraitBase = super.removeTrait(type);
			
			// If we're removing a trait that also exists on the proxied
			// element (and isn't blocked), then we need to signal addition
			// of the base trait immediately after the removal.
			if (	blocksTrait(type) == false
				&&	proxiedElement != null
				&& 	proxiedElement.hasTrait(type) == true
			   )
			{
				super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD, false, false, type));
			}
			
			return result;
		}
		
		/**
		 * @private
		 */
		override public function get metadata():Metadata
		{
			return proxiedElement.metadata;
		}
		
		/**
		 * @private
		 * 
		 * Don't create any metadata, since we will be using the wrapped element's data only.
		 */
		override protected function createMetadata():Metadata
		{
			return null;
		}

		/**
		 * Sets up overridden traits and finalizes them to ensure a consistent initialization
		 * process.  Clients should subclass <code>setupOverriddenTraits()</code>
		 * instead of this method.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final override protected function setupTraits():void
		{
		}
		
		/**
		 * Sets up the traits for this proxy.  The proxy's traits will always
		 * override (i.e. take precedence over) the traits of the wrapped
		 * element.
		 * 
		 * Subclasses can override this method to set up their own traits.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function setupOverriddenTraits():void
		{
			super.setupTraits();
		}
		
		/**
		 * Indicates whether the ProxyElement will prevent the trait of the specified
		 * type from being exposed when the wrapped element contains the trait
		 * and the proxy does not.  The default is <code>false</code> for all trait types.
		 * 
		 * Subclasses override this to selectively block access to the
		 * traits of the wrapped element on a per-type basis.
		 * @param type MediaTraitType to block or not block
		 * @return Returns <code>true</code> to block the trait of the specified type, 
		 * <code>false</code> not to block
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		protected function blocksTrait(traitType:String):Boolean
		{
			return false;
		}
		
		// Internals
		//
		
		private function removeOverriddenTraits():void
		{				
			var overriddenTraitTypes:Vector.<String> = super.traitTypes;
			for each (var traitType:String in overriddenTraitTypes)
			{
				removeTrait(traitType);
			}
		}
		
		private function toggleMediaElementListeners(mediaElement:MediaElement, add:Boolean):void
		{
			if (add)
			{
				_proxiedElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
				_proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				_proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
				_proxiedElement.addEventListener(ContainerChangeEvent.CONTAINER_CHANGE, onContainerChange);
			}
			else
			{
				_proxiedElement.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
				_proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				_proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
				_proxiedElement.removeEventListener(ContainerChangeEvent.CONTAINER_CHANGE, onContainerChange);
			}
		}
		
		private function onMediaError(event:MediaErrorEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function onTraitAdd(event:MediaElementEvent):void
		{
			processTraitsChangeEvent(event);
		}

		private function onTraitRemove(event:MediaElementEvent):void
		{
			processTraitsChangeEvent(event);
		}
		
		private function onContainerChange(event:ContainerChangeEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function processTraitsChangeEvent(event:MediaElementEvent):void
		{
			// We only redispatch the event if the change is for a non-blocked,
			// non-overridden trait.
			if	(	blocksTrait(event.traitType) == false
				&&	super.hasTrait(event.traitType) == false
				)
			{
				super.dispatchEvent(event.clone());
			}
		}
		
		private var _proxiedElement:MediaElement;
	}
}
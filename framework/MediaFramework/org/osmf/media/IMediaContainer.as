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
package org.osmf.media
{
	/**
	 * Defines the interface of objects within the OSMF that
	 * act as a gateway to a media object.
	 */	
	public interface IMediaContainer
	{
		/**
		 * Adds a MediaElement instance to the gateway.
		 * 
		 * @param element The MediaElementInstance to add to the gateway.
		 * @returns The added MediaElement instance.
		 * @throws IllegalOperationError if the specified element is null,
		 * or already a child of the gateway.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		function addMediaElement(element:MediaElement):MediaElement;
		
		
		/**
		 * Removes a MediaElement instance from the gateway.
		 * 
		 * @param element The element to remove from the gateway.
		 * @returns The removed MediaElement instance.
		 * @throws IllegalOperationError if the specified element isn't
		 * a child element, or is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		function removeMediaElement(element:MediaElement):MediaElement;
		
		/**
		 * Verifies if an element is a child of the gateway.
		 *  
		 * @param element Element to verify.
		 * @return True if the element if a child of the gateway.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		function containsMediaElement(element:MediaElement):Boolean;
	}
}
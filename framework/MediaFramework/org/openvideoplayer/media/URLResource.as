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
package org.openvideoplayer.media
{
	import org.openvideoplayer.utils.URL;
	
	/**
	 * Default implementation of IURLResource.
	 **/
	public class URLResource extends URL implements IURLResource
	{
		// Public interface
		//
		
		/**
		 * Constructor.
		 * 
		 * @param url The URL of the resource.
		 **/
		public function URLResource(url:String)
		{
			super(url);
		}
		
		/**
		 * Required by the IURLResource interface, returns a URL object.
		 */
		public function get url():URL
		{
			return this;
		}
	}
}

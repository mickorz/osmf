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
package org.openvideoplayer.layout
{
	import flash.events.IEventDispatcher;
	
	import org.openvideoplayer.media.MediaElement;
	
	/**
	 * ILayoutRenderer represents the interface within the OSMF for objects that
	 * can calculate and apply the size and position of a set of targets, given
	 * a context.
	 */	
	public interface ILayoutRenderer extends IEventDispatcher
	{
		/**
		 * Defines the context against which the renderer will calculate the size
		 * and position values of its targets. The renderer additionally manages
		 * targets being added and removed as children of the set context's
		 * display list.
		 * 
		 * @param value The context to assign.
		 */		
		function set context(value:ILayoutContext):void;
		
		/**
		 * Method for adding a target to the layout renderer's list of objects
		 * that it calculates the size and position for. Adding a target will
		 * result the associated display object to be placed on the display
		 * list of the renderer's context.
		 * 
		 * @param target The target to add.
		 */		
		function addTarget(target:ILayoutTarget):void;
		
		/**
		 * Method for removing a target from the layout render's list of objects
		 * that it will render. See addTarget for more information.
		 * 
		 * @param target The target to remove.
		 */		
		function removeTarget(target:ILayoutTarget):void;
		
		/**
		 * Method that will mark the renderer's last rendering pass invalid. At
		 * the descretion of the implementing instance, the renderer may either
		 * directly re-render, or do so at a later time.
		 */
		function invalidate():void;
		
		/**
		 * Method ordering the direct recalculation of the position and size
		 * of all of the renderer's assigned targets. The implementing class
		 * may still skip recalculation if the renderer has not been invalidated
		 * since the last rendering pass. 
		 */		
		function validateNow():void;
	}
}
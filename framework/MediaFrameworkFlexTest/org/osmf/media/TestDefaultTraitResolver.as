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
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TemporalTrait;

	public class TestDefaultTraitResolver extends MediaTraitResolverBaseTestCase
	{
		override public function constructResolver(type:MediaTraitType, traitOfType:IMediaTrait):MediaTraitResolver
		{
			return new DefaultTraitResolver(type, traitOfType);
		}
		
		public function testDefaultTraitResolver():void
		{
			// More constructor tests:
			
			var resolver:DefaultTraitResolver;
			
			try
			{
				resolver = new DefaultTraitResolver(MediaTraitType.AUDIBLE, new TemporalTrait());
				fail();
			}
			catch(_:*)
			{	
			}
			
			try
			{
				resolver = new DefaultTraitResolver(MediaTraitType.TEMPORAL, null);
				fail();
			}
			catch(_:*)
			{	
			}
			
			assertNull(resolver);
			
			// Resolved trait tests:
			
			var t1:TemporalTrait = new TemporalTrait();
			resolver = new DefaultTraitResolver(MediaTraitType.TEMPORAL, t1);
			
			assertEquals(MediaTraitType.TEMPORAL, resolver.type);
			assertEquals(t1, resolver.resolvedTrait);

			var t2:TemporalTrait = new TemporalTrait();
			resolver.addTrait(t2);
			assertEquals(t2, resolver.resolvedTrait);
			
			resolver.removeTrait(t2);
			assertEquals(t1, resolver.resolvedTrait);
		}
		
	}
}
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
package org.osmf.net.httpstreaming.f4f
{
	import flash.utils.ByteArray;
	
	import flexunit.framework.TestCase;
	
	import mx.utils.Base64Decoder;
	
	public class TestAdobeFragmentRunTable extends TestCase
	{
		override public function setUp():void
		{
			var decoder:Base64Decoder = new Base64Decoder();
			decoder.decode(ABST_BOX_DATA);
			var bytes:ByteArray = decoder.drain();

			var parser:BoxParser = new BoxParser();
			parser.init(bytes);
			var boxes:Vector.<Box> = parser.getBoxes();
			assertTrue(boxes.length == 1);
			
			var abst:AdobeBootstrapBox = boxes[0] as AdobeBootstrapBox;
			assertTrue(abst != null);
			
			assertTrue(abst.fragmentRunTables.length == 1);
			afrt = abst.fragmentRunTables[0] as AdobeFragmentRunTable;
		}
		
		public function testFindFragmentIdByTime():void
		{
			assertTrue(afrt.findFragmentIdByTime(0) == 1);
			assertTrue(afrt.findFragmentIdByTime(1000) == 1);
			assertTrue(afrt.findFragmentIdByTime(2000) == 1);
			assertTrue(afrt.findFragmentIdByTime(3000) == 1);
			assertTrue(afrt.findFragmentIdByTime(4000) == 1);
			assertTrue(afrt.findFragmentIdByTime(4399) == 1);
			assertTrue(afrt.findFragmentIdByTime(4400) == 2);
			assertTrue(afrt.findFragmentIdByTime(5000) == 2);
			assertTrue(afrt.findFragmentIdByTime(6000) == 2);
			assertTrue(afrt.findFragmentIdByTime(7000) == 2);
			assertTrue(afrt.findFragmentIdByTime(8000) == 2);
			assertTrue(afrt.findFragmentIdByTime(8799) == 2);
			assertTrue(afrt.findFragmentIdByTime(8800) == 3);
			assertTrue(afrt.findFragmentIdByTime(9000) == 3);
			assertTrue(afrt.findFragmentIdByTime(10000) == 3);
			assertTrue(afrt.findFragmentIdByTime(11000) == 3);
			assertTrue(afrt.findFragmentIdByTime(12000) == 3);
			assertTrue(afrt.findFragmentIdByTime(12100) == 3);
			assertTrue(afrt.findFragmentIdByTime(12107) == 3);
			assertTrue(afrt.findFragmentIdByTime(12108) == 4);
			
			// Jump to the end.
			assertTrue(afrt.findFragmentIdByTime(60000) == 15);
			assertTrue(afrt.findFragmentIdByTime(60800) == 15);
			assertTrue(afrt.findFragmentIdByTime(60922) == 15);
			assertTrue(afrt.findFragmentIdByTime(60923) == 16);
		}

		public function testTotalDuration():void
		{
			assertTrue(afrt.totalDuration == 60923);
		}
		
		// Internals
		//
		
		private var afrt:AdobeFragmentRunTable;

		private static const ABST_BOX_DATA:String = "AAABGmFic3QAAAAAAAAADwAAAAPoAAAAAAAA7ekAAAAAAAAAAAAAAAAAAQAAABlhc3J0AAAAAAAAAAABAAAAAQAAAA8BAAAA1WFmcnQAAAAAAAAD6AAAAAAMAAAAAQAAAAAAAAAAAAARMAAAAAMAAAAAAAAiaAAADOQAAAAEAAAAAAAAL1AAABEwAAAABgAAAAAAAFG4AAAM5AAAAAcAAAAAAABeoAAAETAAAAAJAAAAAAAAgSoAAAyAAAAACgAAAAAAAI3OAAARMAAAAAsAAAAAAACfAwAADtgAAAAMAAAAAAAArd8AABEwAAAADQAAAAAAAL8TAAAM5AAAAA4AAAAAAADL+gAAETAAAAAPAAAAAAAA3S8AABDM";
	}
}
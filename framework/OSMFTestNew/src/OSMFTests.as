/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package
{
	import flexunit.framework.Test;
	
	import org.osmf.containers.TestHTMLMediaContainer;
	import org.osmf.containers.TestMediaContainer;
	import org.osmf.media.TestMediaType;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class OSMFTests
	{
		public var testMediaType:TestMediaType;
		public var testMediaContainer:TestMediaContainer;
		public var testHTMLMediaContainer:TestHTMLMediaContainer;
	}
}
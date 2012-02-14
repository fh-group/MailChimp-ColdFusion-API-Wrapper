<cfcomponent displayname="testUser"  extends="mxunit.framework.TestCase">
  
  <!--- this will run before every single test in this test case --->
	<cffunction name="setUp" access="public" returntype="void">
		<cfscript>
			mc = CreateObject("component","includes.cf.mailchimp").init("5d5657aadb77fa90345e7e6c5932f084-us1","json");
		</cfscript>
	</cffunction>
  
  <!--- this will run after every single test in this test case --->
	<cffunction name="tearDown" access="public" returntype="void">
	    <cfscript>
	    	mc = "";
	    </cfscript>
	</cffunction>
	
	<cffunction name="testListSubscribeAndUnsubscribe" access="public" returnType="void">
		<cfscript>
			groupStruct = StructNew();
			groupStruct[1] = StructNew();
			groupStruct[1].group = "LORD.com";
			groupStruct[1].groups = "Panic";
			groupStruct[2] = StructNew();
			groupStruct[2].group = "LORD.com";
			groupStruct[2].groups = "Industrial";
			
			lists = mc.lists();
			assertIsDefined("lists");
			
			sub = mc.listSubscribe(lists.data[1].id,"mailtest@fh-group.com","Web","Master",groupStruct);
			assertIsDefined("sub");
			assertTrue(sub);
			
			mailtest = mc.listMemberInfo(lists.data[1].id,"mailtest@fh-group.com");
			assertIsDefined("mailtest");
			assertEquals("mailtest@fh-group.com",mailtest.data[1].email);
			assertEquals("Web",mailtest.data[1].merges["FNAME"]);
			assertEquals("Master",mailtest.data[1].merges["LNAME"]);
			assertEquals("Industrial, Panic",mailtest.data[1].merges["GROUPINGS"][1].groups);
			
			unsub = mc.listUnsubscribe(lists.data[1].id,"mailtest@fh-group.com","json",1,0,0);
			assertTrue(unsub);
		</cfscript>
	</cffunction>
	
	<cffunction name="testListInterestGroupAddAndDel" access="public" returnType="void">
		<cfscript>
			lists = mc.lists();
			assertIsDefined("lists");
			groupings = mc.listInterestGroupings(lists.data[1].id);
			jsonReturn = mc.listInterestGroupAdd(lists.data[1].id, "TestAdd","json", groupings[1].id);
			groupings2 = mc.listInterestGroupings(lists.data[1].id);
			assertIsDefined("groupings2");
			assertEquals("TestAdd",groupings2[1].groups[4].name);
			jsonReturn2 = mc.listInterestGroupDel(lists.data[1].id, "TestAdd","json", groupings2[1].id);
			assertTrue(jsonReturn2);
		</cfscript>
	</cffunction>
	
	<cffunction name="testListInterestGroupUpdate" access="public" returnType="void">
		<cfscript>
			lists = mc.lists();
			assertIsDefined("lists");
			groupings = mc.listInterestGroupings(lists.data[1].id);
			jsonReturn = mc.listInterestGroupAdd(lists.data[1].id, "TestAdd","json", groupings[1].id);
			groupings2 = mc.listInterestGroupings(lists.data[1].id);
			assertIsDefined("groupings2");
			assertEquals("TestAdd",groupings2[1].groups[4].name);
			mc.listInterestGroupUpdate(lists.data[1].id,"TestAdd","TestSub","json",groupings2[1].id);
			groupings3 = mc.listInterestGroupings(lists.data[1].id);
			assertIsDefined("groupings3");
			assertEquals("TestSub",groupings3[1].groups[4].name);
			jsonReturn2 = mc.listInterestGroupDel(lists.data[1].id, "TestSub","json", groupings3[1].id);
			assertTrue(jsonReturn2);
		</cfscript>
	</cffunction>
	
	<cffunction name="testListInterestGroupings" access="public" returnType="void">
		<cfscript>
			lists = mc.lists();
			assertIsDefined("lists");
			groupings = mc.listInterestGroupings(lists.data[1].id);
			assertEquals("LORD.com",groupings[1].name);
			assertEquals("Industrial",groupings[1].groups[1].name);
			assertEquals("Panic",groupings[1].groups[2].name);
			assertEquals("Test",groupings[1].groups[3].name);
		</cfscript>
	</cffunction>
	
	<cffunction name="testListMembers" access="public" returnType="void">
		<cfscript>
			lists = mc.lists();
			assertIsDefined("lists");
			members = mc.listMembers(lists.data[1].id, "subscribed");
			assertIsDefined("members");
			assertEquals(1,members.total);
			assertEquals("alexa@fh-group.com",members.data[1].email);
		</cfscript>
	</cffunction>
	
	<cffunction name="testListMemberInfo" access="public" returnType="void">
		<cfscript>
			lists = mc.lists();
			assertIsDefined("lists");
			alexa = mc.listMemberInfo(lists.data[1].id,"alexa@fh-group.com");
			assertIsDefined("alexa");
			assertEquals("alexa@fh-group.com",alexa.data[1].email);
			assertEquals("Alexander",alexa.data[1].merges["FNAME"]);
			assertEquals("Ambrose",alexa.data[1].merges["LNAME"]);
			assertEquals("DO NOT DELETE",alexa.data[1].merges["MMERGE3"]);
		</cfscript>
	</cffunction>
	
	<cffunction name="testDecodeOutput" access="public" returnType="void">
		<cfscript>
			output = mc.decodeOutput("json","{""decoded"":""true""}");
			assertIsStruct(output);
			assertEquals(true,output.decoded);
		</cfscript>
	</cffunction>
	
	<cffunction name="testReturnError" access="public" returnType="void">
		<cfscript>
			httpRes = StructNew();
			httpRes.statusCode = 500;
			httpRes.errorDetail = "Testing error details";
			error = mc.returnError(httpRes);
			assertIsStruct(error);
			assertEquals(500,error.error.statusCode);
			assertEquals("Testing error details",error.error.errorDetail);
		</cfscript>
	</cffunction>
</cfcomponent>
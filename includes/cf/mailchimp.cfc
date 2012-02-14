<cfcomponent displayname="MailChimp" hint="I use the Mail Chimp API">
	<cfscript>
		this.options = StructNew();
		this.options.serviceURL = "";
		this.options.output = "";
		this.options.apikey = "";
	</cfscript>

	<cffunction name="init" access="public" returntype="Any">
		<cfargument name="apikey" required="true">
		<cfargument name="output" required="false" default="json" type="string">
		
		<cfscript>
			this.options.apikey = arguments.apikey;
			this.options.output = arguments.output;
			this.options.serviceURL = "http://#ListLast(this.options.apikey,"-")#.api.mailchimp.com/1.3/";
		</cfscript>			
		<cfreturn this />
	</cffunction>

	<!-- 
		[listBatchSubscribe]
		Subscribe a batch of email addresses to a list at once.
		[Required]
			(string) id : ID of the list to list groupings for
			(query) subscribers : list of all subscribers (email, fname, lname, and interests)
			[Optional]
			(string) output : Type of output desired [ xml | json ]
			(bool) sendOptInConfirm : Send confirmation emails to the users being subscribed.
			(bool) updateExisting : Update existing emails with the attributes given in this API call.
			(bool) replaceGroups : Replace groups or interests user is current in with the groups given in this API call.
	-->
	<cffunction name="listBatchSubscribe" access="public" Returntype="Any" hint="I subscribe a set of members to a list">
		<cfargument name="id" required="true" type="string">
		<cfargument name="subscribers" required="true" type="query">
		<cfargument name="sendOptInConfirm" required="false" type="boolean" default="0">
		<cfargument name="updateExisting" required="false" type="boolean" default="1">
		<cfargument name="replaceGroups" required="false" type="boolean" default="0">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
			
		<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listBatchSubscribe" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="double_optin" value="#arguments.sendOptInConfirm#" type="url">
			<cfhttpparam name="update_existing" value="#arguments.updateExisting#" type="url">
			<cfhttpparam name="replaceInterests" value="#arguments.replaceGroups#" type="url">
		
			<cfloop query="arguments.subscribers">
				<cfhttpparam name="batch[#currentrow#][email]" value="#arguments.subscribers.e#" type="url">
				<cfhttpparam name="batch[#currentrow#][email_type]" value="html" type="url">
				<cfhttpparam name="batch[#currentrow#][fname]" value="#arguments.subscribers.f#" type="url">
				<cfhttpparam name="batch[#currentrow#][lname]" value="#arguments.subscribers.l#" type="url">
				<cfhttpparam name="batch[#currentrow#][interests]" value="#arguments.subscribers.g#" type="url">
			</cfloop>
		</cfhttp>
		
		<cfscript>
			return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>
	</cffunction>

	<!-- 
		[listBatchUnsubscribe]
		Unsubscribe a batch of email addresses from a list at once.
		Parameters:
			[Required]
			(string) id : ID of the list to list groupings for
			(query) subscribers : list of all subscribers (email, fname, lname, and interests)
			
			[Optional]
			(string) output : Type of output desired [ xml | json ]
			(bool) sendOptInConfirm : Send confirmation emails to the users being subscribed.
			(bool) updateExisting : Update existing emails with the attributes given in this API call.
			(bool) replaceGroups : Replace groups or interests user is current in with the groups given in this API call.
	-->
	<cffunction name="listBatchUnsubscribe" access="public" Returntype="Any">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
		<cfargument name="apikey" required="true" type="string">
		<cfargument name="id" required="true" type="string">
		<cfargument name="subscribers" required="true" type="query">
		<cfargument name="delete_member" required="false" type="boolean" default="0">
		<cfargument name="send_goodbye" required="false" type="boolean" default="1">
		<cfargument name="send_notify" required="false" type="boolean" default="0">
			
		<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listBatchUnsubscribe" type="URL">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="delete_member" value="#arguments.delete_member#" type="url">
			<cfhttpparam name="send_goodbye" value="#arguments.send_goodbye#" type="url">
			<cfhttpparam name="send_notify" value="#arguments.send_notify#" type="url">
		
			<cfloop query="arguments.subscribers">
				<cfhttpparam name="emails[#currentrow#]" value="#email#" type="url">
			</cfloop>
		</cfhttp>
		
		<cfscript>
			return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>	
	</cffunction>

	<!-- 
		[listSubscribe]
		Subscribe a user to a certain list.
		Parameters:
			[Required]
			(string) id : ID of the list to subscribe user to
			(string) email : Email of subscriber to subscribe
			(string) firstname : First name of subscriber
			(string) lastname : Last name of subscriber
			(struct) lists : Structure of the lists the member should be subscribed to
			
			[Optional]
			(string) output : Type of output desired [ xml | json ]
			(boolean) double_optin : Send a double opt-in email?
			(boolean) update_existing : Update any existing contact which may exist already?
			(boolean) send_welcome : Send a welcome email?
	-->
	<cffunction name="listSubscribe" access="public" returntype="any" hint="I subscribe the provided e-mail to a list">
		<cfargument name="id" required="true" type="string">
		<cfargument name="email" required="true" type="string">
		<cfargument name="firstname" required="true" type="string">
		<cfargument name="lastname" required="true" type="string">
		<cfargument name="lists" required="true" type="struct">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
		<cfargument name="double_optin" required="false" type="boolean" default="0">
		<cfargument name="update_existing" required="false" type="boolean" default="1">
		<cfargument name="replace_interests" required="false" type="boolean" default="1">
		<cfargument name="send_welcome" required="false" type="boolean" default="0">
	
	 	<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listSubscribe" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="email_address" value="#arguments.email#" type="url">
			<cfhttpparam name="double_optin" value="#arguments.double_optin#" type="url">
			<cfhttpparam name="update_existing" value="#arguments.update_existing#" type="url">
			<cfhttpparam name="send_welcome" value="#arguments.send_welcome#" type="url">
			<cfif trim(arguments.firstname) neq "">
				<cfhttpparam name="merge_vars[FNAME]" value="#arguments.firstname#" type="url">
			</cfif>
			<cfif trim(arguments.lastname) neq "">
				<cfhttpparam name="merge_vars[LNAME]" value="#arguments.lastname#" type="url">
			</cfif>
			<cfset count = 0 />
			<cfloop collection="#arguments.lists#" item="groupItem">
				<cfhttpparam name="merge_vars[GROUPINGS][#count#][name]" value="#arguments.lists[groupItem]["group"]#" type="url">
				<cfhttpparam name="merge_vars[GROUPINGS][#count#][groups]" value="#arguments.lists[groupItem]["groups"]#" type="url">
				<cfset count = count + 1 />
			</cfloop>
		</cfhttp>	
	
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>
	</cffunction>
	
	<!-- 
		[listUnsubscribe]
		Retrieve all of the lists defined for the user account associated with the api key.
		Parameters:
			[Required]
			(string) id : ID of the list to unsubscribe user from
			(string) email : Email of subscriber to unsubscribe
			[Optional]
			(string) output : Type of output desired [ xml | json ]
			(boolean) delete : True to completely delete subscriber from MailChimp, False to only unsubscribe them.
			(boolean) goodbye : True to send goodbye email, False to send no goodbye email
			(boolean) notify : True to send notification to email in settings to notify on unsubscribe, False to not send the email.
	-->
	<cffunction name="listUnsubscribe" access="public" hint="I subscribe the provided e-mail to a list">
		<cfargument name="id" required="true" type="string">
		<cfargument name="email" required="true" type="string">
		<cfargument name="output" required="false" type="string" default="json">
		<cfargument name="delete" required="false" type="boolean" default="0">
		<cfargument name="goodbye" required="false" type="boolean" default="1">
		<cfargument name="notify" required="false" type="boolean" default="1">
	
	 	<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="method" value="listUnsubscribe" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="email_address" value="#arguments.email#" type="url">
			<cfhttpparam name="delete_member" value="#arguments.delete#" type="url">
			<cfhttpparam name="send_goodbye" value="#arguments.goodbye#" type="url">
			<cfhttpparam name="send_notify" value="#arguments.notify#" type="url">
		</cfhttp>	
	
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>
	</cffunction>

	<!-- 
		[lists]
		Retrieve all of the lists defined for the user account associated with the api key.
		Parameters:
			[Optional]
			(string) output : Type of output desired [ xml | json ]
	-->
	<cffunction name="lists" access="public" returntype="any" hint="I get a list of lists, as query">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
		
	 	<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="lists" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
		</cfhttp>	
	
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>
	</cffunction>

	<!--
		[listInterestGroupings]
		Get the list of interest groupings for a given list, including the label, form information, and included groups for each
		Parameters:
			[Required]
			(string) id : ID of the list to list groupings for
			[Optional]
			(string) output : Type of output desired [ xml | json ]
	-->
	<cffunction name="listInterestGroupings" access="public" Returntype="Any" hint="I find all groupings of a list.">
		<cfargument name="id" required="true" type="string">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
	
		<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listInterestGroupings" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
		</cfhttp>
		 
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>	
	</cffunction>

	<!--
		[listInterestGroupAdd]
		Add a new "response" (group) to a "grouping" or parent group.
		Parameters:
			[Required]
			(string) id : ID of the list to list groupings for
			(string) group_name : Name of the group you are adding
			[Optional]
			(string) output : Type of output desired [ xml | json ]
			(int) grouping_id : The grouping to add the new group to. If not supplied, the first grouping on the list is used.
	-->
	<cffunction name="listInterestGroupAdd" access="public" Returntype="Any" hint="I add a grouping to a list.">
		<cfargument name="id" required="true" type="string">
		<cfargument name="group_name" required="true" type="string">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
		<cfargument name="grouping_id" required="false" type="string">
	
		<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listInterestGroupAdd" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="group_name" value="#arguments.group_name#" type="url">
			<cfif StructKeyExists(arguments,"grouping_id")>
				<cfhttpparam name="grouping_id" value="#arguments.grouping_id#" type="url">
			</cfif>
		</cfhttp>
		 
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>
	</cffunction>

	<!--
		[listInterestGroupDel]
		Delete a "response" (group) from a "grouping" or parent group.
		Parameters:
			[Required]
			(string) id : ID of the list to list groupings for
			(string) group_name : Name of the group you are deleting.
			[Optional]
			(string) output : Type of output desired [ xml | json ]
			(int) grouping_id : The grouping to delete the new group from. If not supplied, the first grouping on the list is used.
	-->
	<cffunction name="listInterestGroupDel" access="public" Returntype="Any" hint="I find all groupings of a list.">
		<cfargument name="id" required="true" type="string">
		<cfargument name="group_name" required="true" type="string">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
		<cfargument name="grouping_id" required="false" type="string">

	
		<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listInterestGroupDel" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="group_name" value="#arguments.group_name#" type="url">
			<cfif StructKeyExists(arguments,"grouping_id")>
				<cfhttpparam name="grouping_id" value="#arguments.grouping_id#" type="url">
			</cfif>
		</cfhttp>
		 
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>	
	</cffunction>
	
	<!--
		[listInterestGroupUpdate]
		Change the name of an Interest Group
		Parameters:
			[Required]
			(string) id : ID of the list to list groupings for
			(string) old_group_name : Name of the group you are changing.
			(string) new_group_name : Name you wish to change the group to.
			[Optional]
			(string) output : Type of output desired [ xml | json ]
			(int) grouping_id : The grouping to delete the new group from. If not supplied, the first grouping on the list is used.
	-->
	<cffunction name="listInterestGroupUpdate" access="public" Returntype="Any" hint="I update the name of an interest group.">
		<cfargument name="id" required="true" type="string">
		<cfargument name="old_group_name" required="true" type="string">
		<cfargument name="new_group_name" required="true" type="string">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
		<cfargument name="grouping_id" required="false" type="string">

	
		<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listInterestGroupUpdate" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="old_name" value="#arguments.old_group_name#" type="url">
			<cfhttpparam name="new_name" value="#arguments.new_group_name#" type="url">
			<cfif StructKeyExists(arguments,"grouping_id")>
				<cfhttpparam name="grouping_id" value="#arguments.grouping_id#" type="url">
			</cfif>
		</cfhttp>
		 
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>	
	</cffunction>
	
	<!-- 
		[listMembers]
		Get all of the list members for a list that are of a particular status.
		Parameters:
			[Required]
			(string) id : ID of the list to query.
			(string) status : Status of the members to find (subscribed, unsubscibed, etc).
			[Optional]
			(string) output : Type of output desired [ xml | json ]
	-->
	<cffunction name="listMembers" access="public" returntype="any" hint="I subscribe the provided e-mail to a list">
		<cfargument name="id" required="true" type="string">
		<cfargument name="status" required="true" type="string">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
		<cfargument name="limit" required="false" type="numeric" default="5000">
		<cfargument name="since" required="false" type="date">
		<cfargument name="start" required="false" type="numeric">
		
	 	<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listMembers" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="status" value="#arguments.status#" type="url">
			<cfhttpparam name="limit" value="#arguments.limit#" type="url">
		</cfhttp>	
	
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>
	</cffunction>	
	
	<!-- 
		[listMemberInfo]
		Get all the information for particular members of a list.
		Parameters:
			[Required]
			(string) id : ID of the list to query.
			(string) email : Email of the use to query for.				
			[Optional]
			(string) output : Type of output desired [ xml | json ]
	-->
	<cffunction name="listMemberInfo" access="public" returntype="any" hint="I subscribe the provided e-mail to a list">
		<cfargument name="id" required="true" type="string">
		<cfargument name="email" required="true" type="string">
		<cfargument name="output" required="false" type="string" default="#this.options.output#">
		
	 	<cfhttp url="#this.options.serviceURL#" method="post">
			<cfhttpparam name="output" value="#arguments.output#" type="url">
			<cfhttpparam name="method" value="listMemberInfo" type="url">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
			<cfhttpparam name="id" value="#arguments.id#" type="url">
			<cfhttpparam name="email_address" value="#arguments.email#" type="url">
		</cfhttp>	
	
		<cfscript>
			if(StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "") return returnError(cfhttp);
			else return decodeOutput(arguments.output,cfhttp.filecontent);
		</cfscript>
	</cffunction>	
	
	<!--
		UTILITY
	-->
	<!--
	[decodeOutput]
		Deserialize data based on the given output desired.
		Parameters:
			[Required]
			(string) data : Serialized XML or JSON to be deserialized.
			(string) output : Type of output desired [ xml | json ]
	-->
	<cffunction name="decodeOutput">
		<cfargument name="output" required="true" type="string">
		<cfargument name="data" required="true" type="any">

		<cfscript>
			if(LCase(arguments.output) == "json") return DeserializeJSON(arguments.data);
			else if(LCase(arguments.output) == "xml") return xmlParse(arguments.data);
		</cfscript>
	</cffunction>

	<!--
	[returnError]
		Returns an error struct based on the http status code and error returned.
		Parameters:
			[Required]
			(string) http : cfhttp object
	-->
	<cffunction name="returnError">
		<cfargument name="http" required="true">
		<cfscript>
			returnStruct = StructNew();
			returnStruct["error"] = StructNew();
			returnStruct["error"]["statusCode"] = arguments.http.statusCode;
			returnStruct["error"]["errorDetail"] = arguments.http.errorDetail;
			
			return returnStruct;
		</cfscript>
	</cffunction>

	<!--
		LORD SPECIFIC
	-->

</cfcomponent>